'use strict';

import https from 'https';
import { Buffer } from 'buffer';

// OpenObserve configuration
const CONFIG = {
    url: "PLACEHOLDER_URL",
    token: "PLACEHOLDER_TOKEN"
};

export const handler = async (event) => {
    console.log('Lambda@Edge Origin Response Triggered');

    try {
        const request = event.Records[0].cf.request;
        const response = event.Records[0].cf.response;

        const logEntry = {
            timestamp: new Date().toISOString(),
            client_ip: request.clientIp || '-',
            uri: request.uri || '-',
            method: request.method || '-',
            status_code: parseInt(response.status, 10) || 0,
            user_agent: request.headers['user-agent'] ? request.headers['user-agent'][0].value : '-',
            edge_location: request.headers['host'] ? request.headers['host'][0].value : '-',
            referer: request.headers['referer'] ? request.headers['referer'][0].value : '-',
            edge_response_result_type: response.status >= 200 && response.status < 300 ? 'Hit' : 'Miss'
        };

        await sendToOpenObserve([logEntry]);

    } catch (error) {
        console.error('Error logging to OpenObserve:', error);
    }

    return response;
};

const sendToOpenObserve = async (logs) => {
    return new Promise((resolve, reject) => {
        const url = new URL(CONFIG.url);
        const jsonData = JSON.stringify(logs);
        const options = {
            hostname: url.hostname,
            path: url.pathname + url.search,
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${CONFIG.token}`
            }
        };

        const req = https.request(options, (res) => {
            let responseBody = '';
            res.on('data', (chunk) => {
                responseBody += chunk;
            });
            res.on('end', () => {
                if (res.statusCode >= 200 && res.statusCode < 300) {
                    console.log('Successfully sent logs to OpenObserve');
                    resolve();
                } else {
                    console.error(`OpenObserve returned status code ${res.statusCode}: ${responseBody}`);
                    reject(new Error(`Failed to log: ${responseBody}`));
                }
            });
        });

        req.on('error', (error) => {
            console.error('Error sending logs to OpenObserve:', error);
            reject(error);
        });

        req.write(jsonData);
        req.end();
    });
};