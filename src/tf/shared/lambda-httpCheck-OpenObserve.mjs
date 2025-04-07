'use strict';

import https from 'https';
import { URL } from 'url';
import { performance } from 'perf_hooks';
import dns from 'dns';

// OpenObserve configuration
const CONFIG = {
    url: "PLACEHOLDER_URL",
    username: "PLACEHOLDER_USERNAME",
    password: "PLACEHOLDER_PASSWORD"
};

// URLs to monitor
const URLS_TO_MONITOR = PLACEHOLDER_URLS_TO_MONITOR;

// Helper function to measure DNS lookup time
const measureDnsTime = (hostname) => {
    return new Promise((resolve, reject) => {
        const startTime = performance.now();
        dns.lookup(hostname, (err, address, family) => {
            if (err) {
                reject(err);
            } else {
                const endTime = performance.now();
                resolve(Math.round(endTime - startTime));  // DNS resolution time in ms
            }
        });
    });
};

const checkUrl = (targetUrl) => {
    return new Promise(async (resolve) => {
        const parsedUrl = new URL(targetUrl);
        
        try {
            // Measure DNS resolution time
            const dnsTime = await measureDnsTime(parsedUrl.hostname);
            
            const startTime = performance.now();
            const options = {
                method: 'GET',
                timeout: 5000,
                headers: {
                    'X-Monitor-Origin': `lambda-${process.env.AWS_REGION}`
                }
            };

            // Start the HTTP request
            const req = https.request(parsedUrl, options, (res) => {
                res.on('data', () => {});  // No need to capture the body

                res.on('end', () => {
                    const endTime = performance.now();  // End time after receiving full response
                    resolve({
                        timestamp: new Date().toISOString(),
                        url: targetUrl,
                        status_code: res.statusCode,
                        response_time_ms: Math.round(endTime - startTime),  // Total time for DNS, connection, and response
                        dns_time_ms: dnsTime  // DNS lookup time
                    });
                });
            });

            req.on('error', (error) => {
                const endTime = performance.now();
                resolve({
                    timestamp: new Date().toISOString(),
                    url: targetUrl,
                    status_code: 0,
                    response_time_ms: Math.round(endTime - startTime),
                    dns_time_ms: dnsTime,
                    error: error.message
                });
            });

            req.on('timeout', () => {
                req.destroy();
                const endTime = performance.now();
                resolve({
                    timestamp: new Date().toISOString(),
                    url: targetUrl,
                    status_code: 0,
                    response_time_ms: Math.round(endTime - startTime),
                    dns_time_ms: dnsTime,
                    error: "Timeout"
                });
            });

            req.end();
        } catch (err) {
            resolve({
                timestamp: new Date().toISOString(),
                url: targetUrl,
                status_code: 0,
                error: `DNS Error: ${err.message}`
            });
        }
    });
};

const sendToOpenObserve = async (logs) => {
    const url = new URL(CONFIG.url);
    const jsonData = JSON.stringify(logs);
    const auth = 'Basic ' + Buffer.from(CONFIG.username + ':' + CONFIG.password).toString('base64');

    const options = {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
            'Authorization': auth
        }
    };

    return new Promise((resolve, reject) => {
        const req = https.request(url, options, (res) => {
            let responseBody = '';
            res.on('data', (chunk) => responseBody += chunk);
            res.on('end', () => {
                if (res.statusCode >= 200 && res.statusCode < 300) {
                    console.log('Successfully sent logs to OpenObserve');
                    resolve();
                } else {
                    reject(new Error(`OpenObserve error ${res.statusCode}: ${responseBody}`));
                }
            });
        });

        req.on('error', (error) => reject(error));

        req.setTimeout(5000, () => {
            req.destroy(new Error('Request timed out'));
            reject(new Error('Request timed out'));
        });

        req.write(jsonData);
        req.end();
    });
};

export const handler = async () => {
    try {
        const results = await Promise.all(URLS_TO_MONITOR.map(checkUrl));
        console.log('Health check results:', results);
        await sendToOpenObserve(results);
    } catch (error) {
        console.error('Monitoring failed:', error);
    }
};