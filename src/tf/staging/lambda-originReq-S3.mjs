'use strict';

export const handler = async (event) => {
    console.log('Lambda function triggered!');
    const request = event.Records[0].cf.request;
    const uri = request.uri;
    console.log('Original Request:', JSON.stringify(request));

    // Check if the request is going to an S3 origin
    const origin = request.origin;

    if (origin && origin.s3) {
        // Modify the Host header for the S3 origin
        request.headers['host'] = [{
            key: 'Host',
            value: 'jlv6-www-staging.s3.eu-central-1.amazonaws.com'
        }];

        // URL rewrite logic: Append index.html if the request URI ends with '/'
        // or if it doesn't include a file extension (no '.' in the URI)
        if (uri.endsWith('/')) {
            request.uri += 'index.html';
        } else if (!uri.includes('.')) {
            request.uri += '/index.html';
        }

        console.log('Rewritten URI for S3 origin:', request.uri);
    } else {
        console.log('Request not routed to S3 origin, no rewrite applied.');
    }

    // Output the modified request
    console.log('Modified Request:', JSON.stringify(request));
    return request;
};