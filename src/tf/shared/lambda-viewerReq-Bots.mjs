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

    } catch (error) {
        console.error(`Error processing request: ${error}`);
    }

    return event.Records[0].cf.request;
};