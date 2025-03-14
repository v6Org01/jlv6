'use strict';

import https from 'https';
import { URL } from 'url';

// OpenObserve configuration
const CONFIG = {
    url: "PLACEHOLDER_URL",
    username: "PLACEHOLDER_USERNAME",
    password: "PLACEHOLDER_PASSWORD"
};

export const handler = async (event) => {
    console.log('Lambda@Edge Viewer Response Triggered');

    try {
        const response = event.Records[0].cf.response;
        const request = event.Records[0].cf.request;

        // Access useful headers (Viewer-Response specific)
        const cacheStatus = response.headers['x-cache'] ? response.headers['x-cache'][0].value : '-';
        const contentLength = response.headers['content-length'] ? response.headers['content-length'][0].value : '-';
        const cacheControl = headers['cache-control'] ? headers['cache-control'][0].value : '-';
        const age = headers['age'] ? headers['age'][0].value : '-';
        const edgeLocation = headers['x-amz-cf-pop'] ? headers['x-amz-cf-pop'][0].value : '-';

        // Access useful headers (Viewer-Request) - INLINED for performance!
        const uri = request.uri || '-';
        const method = request.method || '-';
        const clientIp = request.clientIp || '-';
        const host = request.headers.host && request.headers.host[0] && request.headers.host[0].value ? request.headers.host[0].value : '-';
        const userAgent = request.headers['user-agent'] && request.headers['user-agent'][0] && request.headers['user-agent'][0].value ? request.headers['user-agent'][0].value : '-';
        const referer = request.headers.referer && request.headers.referer[0] && request.headers.referer[0].value ? request.headers.referer[0].value : '-';
        const viewerCountry = request.headers['cloudfront-viewer-country'] && request.headers['cloudfront-viewer-country'][0] && request.headers['cloudfront-viewer-country'][0].value ? request.headers['cloudfront-viewer-country'][0].value : '-';
        const viewerCity = request.headers['cloudfront-viewer-city'] && request.headers['cloudfront-viewer-city'][0] && request.headers['cloudfront-viewer-city'][0].value ? request.headers['cloudfront-viewer-city'][0].value : '-';
        const isMobileViewer = request.headers['cloudfront-is-mobile-viewer'] && request.headers['cloudfront-is-mobile-viewer'][0] && request.headers['cloudfront-is-mobile-viewer'][0].value ? request.headers['cloudfront-is-mobile-viewer'][0].value : '-';
        const isTabletViewer = request.headers['cloudfront-is-tablet-viewer'] && request.headers['cloudfront-is-tablet-viewer'][0] && request.headers['cloudfront-is-tablet-viewer'][0].value ? request.headers['cloudfront-is-tablet-viewer'][0].value : '-';
        const isDesktopViewer = request.headers['cloudfront-is-desktop-viewer'] && request.headers['cloudfront-is-desktop-viewer'][0] && request.headers['cloudfront-is-desktop-viewer'][0].value ? request.headers['cloudfront-is-desktop-viewer'][0].value : '-';
        const forwardedProto = request.headers['cloudfront-forwarded-proto'] && request.headers['cloudfront-forwarded-proto'][0] && request.headers['cloudfront-forwarded-proto'][0].value ? request.headers['cloudfront-forwarded-proto'][0].value : '-';
        const viewerTls = request.headers['cloudfront-viewer-tls'] && request.headers['cloudfront-viewer-tls'][0] && request.headers['cloudfront-viewer-tls'][0].value ? request.headers['cloudfront-viewer-tls'][0].value : '-';
        const cookieValue = request.headers.cookie && request.headers.cookie[0] && request.headers.cookie[0].value ? request.headers.cookie[0].value : '-';
        const acceptEncoding = request.headers['accept-encoding'] && request.headers['accept-encoding'][0] && request.headers['accept-encoding'][0].value ? request.headers['accept-encoding'][0].value : '-';

        const logEntry = {
            timestamp: new Date().toISOString(),
            uri: uri,
            method: method,
            client_ip: clientIp,
            host: host,
            x_cache: cacheStatus,
            age: age,
            cache_control: cacheControl,
            content_length: contentLength,
            referer: referer,
            cloudfront_viewer_country: viewerCountry,
            cloudfront_viewer_city: viewerCity,
            cloudfront_is_mobile_viewer: isMobileViewer,
            cloudfront_is_tabletViewer: isTabletViewer,
            cloudfront_is_desktopViewer: isDesktopViewer,
            cloudfront_forwarded_proto: forwardedProto,
            cloudfront_viewer_tls: viewerTls,
            edge_location: edgeLocation,
            cookie: cookieValue,
            accept_encoding: acceptEncoding,
            status: response.status // CloudFront's status code
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
        },
        timeout: 5000 //Explicitly set the timeout (best practice)
    };

    return new Promise((resolve, reject) => {
        const req = https.request(url, options, (res) => {
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