'use strict';

import https from 'https';
import { URL } from 'url';
import { performance } from 'perf_hooks';
import dns from 'dns/promises';

// OpenObserve configuration
const CONFIG = {
    url: "PLACEHOLDER_URL",
    username: "PLACEHOLDER_USERNAME",
    password: "PLACEHOLDER_PASSWORD"
};

// URLs to monitor
const URLS_TO_MONITOR = PLACEHOLDER_URLS_TO_MONITOR;

const encodeBasicAuth = (username, password) =>
    'Basic ' + Buffer.from(`${username}:${password}`).toString('base64');

// Function to send metrics to OpenObserve
const sendMetrics = async (metricString) => {
    const parsedUrl = new URL(CONFIG.url);
  
    const options = {
      method: 'POST',
      hostname: parsedUrl.hostname,
      path: parsedUrl.pathname,
      port: parsedUrl.port || 443,
      headers: {
        'Content-Type': 'text/plain',
        'Authorization': encodeBasicAuth(CONFIG.username, CONFIG.password)
      }
    };
  
    return new Promise((resolve, reject) => {
      const req = https.request(options, (res) => {
        res.on('data', () => {});
        res.on('end', () => {
          if (res.statusCode >= 200 && res.statusCode < 300) {
            console.log('✅ Metrics sent successfully');
            resolve();
          } else {
            console.error(`❌ Failed to send metrics: ${res.statusCode}`);
            reject(new Error(`OpenObserve returned status ${res.statusCode}`));
          }
        });
      });
  
      req.on('error', reject);
      req.write(metricString);
      req.end();
    });
  };
  
  // Function to check the URL response time and status code
  const checkUrl = async (targetUrl) => {
    const parsedUrl = new URL(targetUrl);
    const region = process.env.AWS_REGION || 'unknown';
    const monitorOrigin = `lambda-${region}`;
  
    let dnsTime = 0;
    const startTime = performance.now();
  
    // Measure DNS lookup time
    try {
      const dnsStart = performance.now();
      await dns.lookup(parsedUrl.hostname);  // This triggers DNS lookup
      const dnsEnd = performance.now();
      dnsTime = Math.round(dnsEnd - dnsStart); // DNS response time
    } catch (e) {
      console.error(`DNS lookup failed for ${parsedUrl.hostname}`);
    }
  
    // Measure total request/response time
    const result = await new Promise((resolve) => {
      const req = https.request(parsedUrl, { method: 'GET', timeout: 5000, headers: { 'X-Monitor-Origin': monitorOrigin } }, (res) => {
        res.on('data', () => {});
        res.on('end', () => {
          const endTime = performance.now();
          resolve({
            url: targetUrl,
            statusCode: res.statusCode,
            responseTimeMs: Math.round(endTime - startTime) // Total response time
          });
        });
      });
  
      req.on('error', () => {
        const endTime = performance.now();
        resolve({
          url: targetUrl,
          statusCode: 0, // Use 0 for unreachable/error
          responseTimeMs: Math.round(endTime - startTime)
        });
      });
  
      req.end();
    });
  
    return { ...result, dnsTime };
  };
  
  export const handler = async () => {
    const metricLines = [];
  
    for (const url of URLS_TO_MONITOR) {
      const result = await checkUrl(url);
      const region = process.env.AWS_REGION || 'unknown';
  
      // Push total response time
      metricLines.push(`# TYPE http_check_response_time gauge`);
      metricLines.push(`http_check_response_time{url="${url}",region="${region}"} ${result.responseTimeMs}`);
  
      // Push HTTP status code
      metricLines.push(`# TYPE http_check_status_code gauge`);
      metricLines.push(`http_check_status_code{url="${url}",region="${region}"} ${result.statusCode}`);
  
      // Push DNS lookup time
      metricLines.push(`# TYPE http_check_dns_time gauge`);
      metricLines.push(`http_check_dns_time{url="${url}",region="${region}"} ${result.dnsTime}`);
    }
  
    // Combine all metric lines into a single string payload
    const fullMetricPayload = metricLines.join('\n') + '\n';
  
    // Send the metrics to OpenObserve
    await sendMetrics(fullMetricPayload);
  };