
async function handler(event) {
    var request = event.request;
    var uri = request.uri;
    var headers = request.headers;
    // Block AI Crawler
    // https://www.andrlik.org/dispatches/til-block-ai-bots-cloudfront-function/
    const banned_agents = [
        'AdsBot-Google', 'AI2Bot', 'Amazonbot', 'anthropic-ai', 'Applebot', 'AwarioRssBot', 
        'AwarioSmartBot', 'Bytespider', 'CCBot', 'ChatGPT-User', 'ClaudeBot', 'Claude-Web', 
        'cohere-ai', 'DataForSeoBot', 'Diffbot', 'FacebookBot', 'FriendlyCrawler', 
        'Google-Extended', 'GoogleOther', 'GPTBot', 'img2dataset', 'ImagesiftBot', 
        'magpie-crawler', 'Meltwater', 'Meta-ExternalAgent', 'Meta-ExternalFetcher', 'omgili', 
        'omgilibot', 'peer39_crawler', 'peer39_crawler/1.0', 'PerplexityBot', 'PiplBot', 
        'scoop.it', 'Seekr', 'YouBot'
    ];
    const user_agent = headers['user-agent'] ? headers['user-agent'].value : '';
    for (var i = 0; i < banned_agents.length; i++) {
        var agent = banned_agents[i];
        if (user_agent.includes(agent)) {
            return {
                statusCode: 403,
                statusDescription: 'Forbidden',
                headers: {
                    'cloudfront-functions': { value: 'generated-by-CloudFront-Functions' },
                    'content-type': { value: 'text/html' }
                },
                body: {
                    encoding: 'text',
                    data: ''
                }
            };
        }
    }
}