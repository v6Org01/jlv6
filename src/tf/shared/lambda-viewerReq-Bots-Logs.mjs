const https = require('https');

// OpenObserve configuration
const OO_CONFIG = {
    url: "PLACEHOLDER_URL",
    token: "PLACEHOLDER_TOKEN"
};

// Banned AI User Agents
const BANNED_AGENTS = [
    'AdsBot-Google', 'AI2Bot', 'Amazonbot', 'anthropic-ai', 'Applebot', 'AwarioRssBot',
    'AwarioSmartBot', 'Bytespider', 'CCBot', 'ChatGPT-User', 'ClaudeBot', 'Claude-Web',
    'cohere-ai', 'DataForSeoBot', 'Diffbot', 'FacebookBot', 'FriendlyCrawler',
    'Google-Extended', 'GoogleOther', 'GPTBot', 'img2dataset', 'ImagesiftBot',
    'magpie-crawler', 'Meltwater', 'Meta-ExternalAgent', 'Meta-ExternalFetcher', 'omgili',
    'omgilibot', 'peer39_crawler', 'peer39_crawler/1.0', 'PerplexityBot', 'PiplBot',
    'scoop.it', 'Seekr', 'YouBot'
];

export const handler = async (event) => {
    console.log("Lambda@Edge Viewer Request Triggered");
    
    try {
        const request = event.Records[0].cf.request;
        const headers = request.headers || {};
        const userAgent = headers["user-agent"] ? headers["user-agent"][0].value : "";

        // Check if the user agent is banned
        if (BANNED_AGENTS.some(bot => userAgent.includes(bot))) {
            return {
                status: "403",
                statusDescription: "Forbidden",
                body: ""
            };
        }

        const response = event.Records[0].cf.response;

        // Create log entry
        const logEntry = {
            timestamp: new Date().toISOString(),
            client_ip: request.clientIp || "-",
            uri: request.uri || "-",
            method: request.method || "-",
            status_code: parseInt(response.status, 10) || 0,
            user_agent: userAgent,
            edge_location: headers.host ? headers.host[0].value : "-",
            referer: headers.referer ? headers.referer[0].value : "-",
            edge_response_result_type: response.status >= 200 && response.status < 300 ? "Hit" : "Miss"
        };

        // Attempt to send log entry to OpenObserve but do not block request
        try {
            await sendToOpenObserve([logEntry]);
        } catch (logError) {
            console.error(`Failed to send logs to OpenObserve: ${logError}`);
        }
    
    } catch (error) {
        console.error(`Error processing request: ${error}`);
    }
    
    return event.Records[0].cf.request;
};

const sendToOpenObserve = async (logs) => {
    return new Promise((resolve, reject) => {
        const url = `${OO_CONFIG.url}`;
        const jsonData = JSON.stringify(logs);
        const options = {
            method: "POST",
            headers: {
                "Content-Type": "application/json",
                "Authorization": `Bearer ${OO_CONFIG.token}`
            }
        };

        const req = https.request(url, options, (res) => {
            if (res.statusCode < 200 || res.statusCode >= 300) {
                reject(new Error(`OpenObserve returned status code ${res.statusCode}`));
            } else {
                console.log("Successfully sent logs to OpenObserve");
                resolve();
            }
        });

        req.on("error", (error) => reject(error));
        req.write(jsonData);
        req.end();
    });
};