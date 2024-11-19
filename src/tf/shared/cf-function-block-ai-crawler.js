function handler(event) {
  const banned_agents = ['AdsBot-Google', "AI2Bot", 'Amazonbot', 'anthropic-ai', 'Applebot', 'AwarioRssBot', 'AwarioSmartBot', 'Bytespider', 'CCBot', 'ChatGPT-User', 'ClaudeBot', 'Claude-Web', 'cohere-ai', 'DataForSeoBot', 'Diffbot', 'FacebookBot', 'FriendlyCrawler', 'Google-Extended', 'GoogleOther', 'GPTBot', 'img2dataset', 'ImagesiftBot', 'magpie-crawler', 'Meltwater', 'Meta-ExternalAgent', 'Meta-ExternalFetcher', 'omgili', 'omgilibot', 'peer39_crawler', 'peer39_crawler/1.0', 'PerplexityBot', 'PiplBot', 'scoop.it', 'Seekr', 'YouBot']
  var request = event.request;
  console.log(request.headers);
  console.log(request.headers['user-agent']['value']);
  const user_agent = request.headers['user-agent']['value'];
  for (var i=0; i < banned_agents.length; i++){
      var agent = banned_agents[i];
      console.log(agent)
      if (user_agent.includes(agent)){
          var error_response = {
              statusCode: 403,
              statusDescription: 'Forbidden',
              headers: {
                  'cloudfront-functions': { value: 'generated-by-CloudFront-Functions' },
                  'content-type': {value: 'text/html' },
              },
              body: {
                  encoding: 'text',
                  data: ''
              }
          }
          return error_response;
      }
  }
  return request;
}