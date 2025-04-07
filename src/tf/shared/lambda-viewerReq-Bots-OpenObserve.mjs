'use strict';

import https from 'https';
import { URL } from 'url';

// OpenObserve configuration
const CONFIG = {
    url: "PLACEHOLDER_URL",
    username: "PLACEHOLDER_USERNAME",
    password: "PLACEHOLDER_PASSWORD"
};

// Banned AI User Agents
const BANNED_AGENTS = [
    'AdsBot-Google', 'AI2Bot', 'Amazonbot', 'anthropic-ai', 'Applebot', 'AwarioRssBot',
    'AwarioSmartBot', 'bingbot', 'Bytespider', 'CCBot', 'ChatGPT-User', 'ClaudeBot', 'Claude-Web',
    'cohere-ai', 'DataForSeoBot', 'Diffbot', 'FacebookBot', 'FriendlyCrawler',
    'Google-Extended', 'Googlebot', 'GoogleOther', 'GPTBot', 'img2dataset', 'ImagesiftBot',
    'magpie-crawler', 'Meltwater', 'Meta-ExternalAgent', 'Meta-ExternalFetcher', 'omgili',
    'omgilibot', 'peer39_crawler', 'peer39_crawler/1.0', 'PerplexityBot', 'PiplBot', 
    'SemrushBot', 'scoop.it', 'Seekr', 'YouBot'
];

// Generate a lightweight random ID (without external dependencies)
const generateRequestId = () => {
    return Date.now().toString(36) + Math.random().toString(36).substr(2, 8);
};

export const handler = async (event) => {
    console.log("Lambda@Edge Viewer Request Triggered");

    try {
        const request = event.Records[0].cf.request;
        const headers = request.headers || {};
        const userAgent = headers["user-agent"] ? headers["user-agent"][0].value : "";
        const hostHeader = headers["host"] ? headers["host"][0].value : "";
        const monitorOriginHeader = headers["x-monitor-origin"] ? headers["x-monitor-origin"][0].value: "";
        const refererHeader = headers["referer"] ? headers["referer"][0].value : ""; // Extract Referer

        const requestId = generateRequestId();
        request.headers['x-request-id'] = [{ key: 'x-request-id', value: requestId }];

        const isBotRequest = BANNED_AGENTS.some(bot => userAgent.includes(bot));

        const logEntry = {
            timestamp: new Date().toISOString(),
            request_id: requestId,
            stage: "viewer-request",
            client_ip: request.clientIp || '-',
            method: request.method || '-',
            uri: request.uri || '-',
            host: hostHeader || '-', 
            referer: refererHeader || '-',
            user_agent: userAgent || '-',
            bot_blocked: isBotRequest || '-',
            monitor_origin: monitorOriginHeader || '-'
        };

        await sendToOpenObserve([logEntry]);

        if (isBotRequest) {
            return {
                status: "403",
                statusDescription: "Forbidden",
                body: ""
            };
        }

    } catch (error) {
        console.error(`Error processing request: ${error}`);
    }

    return event.Records[0].cf.request;
};

const sendToOpenObserve = async (logs) => {
    const url = new URL(CONFIG.url);
    const jsonData = JSON.stringify(logs);

    // Create the Authorization header
    const auth = 'Basic ' + Buffer.from(CONFIG.username + ':' + CONFIG.password).toString('base64');

    const options = {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
            'Authorization': auth
        }
    };

    return new Promise((resolve, reject) => {
        const req = https.request(url, options, (res) => { // Pass the URL directly
            let responseBody = '';

            res.on('data', (chunk) => {
                responseBody += chunk;
            });

            res.on('end', () => {
                if (res.statusCode >= 200 && res.statusCode < 300) {
                    console.log('Successfully sent logs to OpenObserve');
                    resolve();
                } else {
                    const errorMessage = `OpenObserve returned status code ${res.statusCode}: ${responseBody}`;
                    console.error(errorMessage);
                    reject(new Error(`Failed to log: ${errorMessage}`));
                }
            });
        });

        req.on('error', (error) => {
            console.error('Error sending logs to OpenObserve:', error);
            reject(error);
        });

        req.setTimeout(5000, () => { // Set a timeout
            console.error('Request to OpenObserve timed out');
            req.destroy(new Error('Request timed out')); // Terminate the request
            reject(new Error('Request timed out'));
        });

        req.write(jsonData);
        req.end();
    });
};