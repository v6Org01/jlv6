'use strict';

exports.handler = (event, context, callback) => {
    
    const response = event.Records[0].cf.response;
    const statusCode = response.status;

    response.headers['set-cookie'] = [{
        key: 'Set-Cookie',
        value: `originStatusCode=${statusCode}; Path=/; Secure; HttpOnly`
    }];

    callback(null, response);
};