'use strict';

const https = require('https');
const { URL } = require('url'); // Use the built-in URL class

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
        return response;

    } catch (error) {
        console.error('Error logging to OpenObserve:', error);
        // Return an error response to prevent further processing
        return {
            status: '500',
            statusDescription: 'Internal Server Error',
            body: 'Failed to log to OpenObserve',
            headers: { 'content-type': [{ key: 'Content-Type', value: 'text/plain' }] },
        };
    }
};

const sendToOpenObserve = async (logs) => {
    const url = new URL(CONFIG.url);
    const jsonData = JSON.stringify(logs);

    const options = {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${CONFIG.token}`
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