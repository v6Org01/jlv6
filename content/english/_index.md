---
# Introduction
introduction:
  titleP1: Host
  titleP2: Hub
  subtitle: The hub for services hosted @jlv6.com
  mvp_title: "🚧 This is an MVP 🚧"
  mvp_text: <span class="title-explanation">Welcome! This is the early version of the site. Most features are broken and pratically all content is missing. New builds are being released daily to fix and improve things.</span>
  arrow_text: Features
  image_light: /images/arrow_down_01_light.webp
  image_dark: /images/arrow_down_01_dark.webp
  bulletpoints:
    - point: /index.html has been served directly from <img src="https://img.shields.io/badge/AWS%20S3-%23FF9900.svg?logo=amazon-web-services&logoColor=white" alt="AWS Badge"> .
    - point: <img src="https://img.shields.io/badge/AWS%20CloudFront-%23FF9900.svg?logo=amazon-web-services&logoColor=white" alt="AWS Cloudfront Badge"> handles caching and delivery of all other content, with these specific details.. 
      subpoints:
        - "Distribution pulls content from 2 Origins: An on-premise Kubernetes cluster <br> (primary) or a EU-hosted AWS S3 bucket (secondary)."
        - Function to return 403 Forbidden if user-agent = known AI crawler bot.
        - Function to rewrite URI when Orgin = S3; needed for in-bucket versioning.
        - Lambda@Edge Function to modify host header on origin-request to Origin = S3.
        - Custom headers for on-premise routing and showing /index.html location.
        - _Blog entries will be created shortly to describe ingress for this static site and its <br> CI/CD pipeline._ 
    - point: Website development and deployment are fully driven by Infrastructure as Code (IaC). Project code is stored in GitHub repository <a href="https://github.com/v6Org01/jlv6"><img src="https://img.shields.io/badge/v6Org01%2Fjlv6-%23000000.svg?logo=github&logoColor=white" alt="GitHub/jlv6 Badge"></a>.
      subpoints:
        - "<u>Main branch</u>: GitHub Action workflows, Terraform config files, Docker files,  ArgoCD application manifests and /public dir."
        - "<u>Development branch</u>: Hugo theme files and script to push /public to main."
    - point: Not SEO-optimized, no advertisements, no third-party cookies, no user profiling, no data collection. The Private Policy can be found <a href="https://www.jlv6.com/privacy-policy" class="a1">here</a>.
    - point: A huge thank you! This website would not have been possible without the incredible contributions to the Hugo framework and the Hugoplate theme, developed by Zeon Studio.
  button:
    enable: false
    label: "PLACEHOLDER"
    link: "PLACEHOLDER"

# Sections
sections:
  - title: "PLACEHOLDER"
    image_light: "/images/diag_network.png"
    image_dark: "/images/diag_network_darkmode.png"
    content: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua."
    bulletpoints:
      - "Item 1"
      - "Item 2"
      - "Item 3"
      - "Item 4"
      - "Item 5"
    button:
      enable: true
      label: "Start Reading"
      link: "http://localhost:1313/techblog"

  - title: "Accessing the applications.."
    image: "/images/homepage_demo.png"
    content: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua."
    bulletpoints:
      - "Item 1"
      - "Item 2"
      - "Item 3"

  - title: "PLACEHOLDER"
    content: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua."
---
