'use strict';

import https from 'https';
import { URL } from 'url';

// OpenObserve configuration
const CONFIG = {
    url: "PLACEHOLDER_URL",
    username: "PLACEHOLDER_USERNAME",
    password: "PLACEHOLDER_PASSWORD"
};

// Helper function to safely extract header values
const getHeaderValue = (headers, headerName, defaultValue = '-') => {
    const header = headers[headerName];
    return header && header[0] && header[0].value ? header[0].value : defaultValue;
};

export const handler = async (event) => {
    console.log('Lambda@Edge Origin Response Triggered');

    try {
        const request = event.Records[0].cf.request;
        const response = event.Records[0].cf.response;

        // Extract headers once and reuse.
        const host = getHeaderValue(request.headers, 'host');
        const userAgent = getHeaderValue(request.headers, 'user-agent');
        const referer = getHeaderValue(request.headers, 'referer');
        const contentLength = getHeaderValue(response.headers, 'content-length');
        const viewerCountry = getHeaderValue(request.headers, 'cloudfront-viewer-country');
        const viewerCity = getHeaderValue(request.headers, 'cloudfront-viewer-city');
        const isMobileViewer = getHeaderValue(request.headers, 'cloudfront-is-mobile-viewer');
        const isTabletViewer = getHeaderValue(request.headers, 'cloudfront-is-tablet-viewer');
        const isDesktopViewer = getHeaderValue(request.headers, 'cloudfront-is-desktop-viewer');
        const forwardedProto = getHeaderValue(request.headers, 'cloudFront-forwarded-proto');
        const viewerTls = getHeaderValue(request.headers, 'cloudfront-viewer-tls');
        const cookie = getHeaderValue(request.headers, 'cookie'); // Get the cookie

        // Additional headers for performance insights:
        const acceptEncoding = getHeaderValue(request.headers, 'accept-encoding');
        const cacheControl = getHeaderValue(response.headers, 'cache-control');

        const logEntry = {
            timestamp: new Date().toISOString(),
            client_ip: request.clientIp || '-',
            uri: request.uri || '-',
            method: request.method || '-',
            host: host,
            status_code: parseInt(response.status, 10) || 0,
            user_agent: userAgent,
            referer: referer,
            content_length: contentLength, //Bandwidth info
            cloudfront_viewer_country: viewerCountry,
            cloudfront_viewer_city: viewerCity,
            cloudfront_is_mobile_viewer: isMobileViewer,
            cloudfront_is_tablet_viewer: isTabletViewer,
            cloudfront_is_desktop_viewer: isDesktopViewer,
            cloudfront_forwarded_proto: forwardedProto,
            cloudfront_viewer_tls: viewerTls,
            cookie: cookie, // ***HANDLE WITH EXTREME CARE!***
            accept_encoding: acceptEncoding,
            cache_control: cacheControl,
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