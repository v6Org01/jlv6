'use strict';

export const handler = async (event) => {
    console.log('Lambda function triggered!');
    const request = event.Records[0].cf.request;
    console.log('Request:', JSON.stringify(request));

    // Check if the request is going to an S3 origin or a custom origin
    const origin = request.origin;

    // If the request is routed to an S3 origin (origin.s3 exists)
    if (origin && origin.s3) {
        // Set the Host header to the S3 bucket's endpoint
        request.headers['host'] = [{
            key: 'Host',
            value: 'jlv6-www.s3.eu-central-1.amazonaws.com'
        }];
    }
    // Example: Output the modified request before returning
    console.log('Modified request:', JSON.stringify(request));
    // Return the modified request
    return request;
};