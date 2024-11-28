---
# Introduction
introduction:
  titleP1: Host
  titleP2: Hub
  subtitle: Your hub for services hosted @jlv6.com
  mvp_title: "🚧 This is an MVP 🚧"
  mvp_text: <span class="title-explanation">Welcome! This is the early version of the site. Most features are broken and pratically all content is missing. New builds are being released daily to fix and improve things.</span>
  arrow_text: Features
  image_light: /images/arrow_down_02_light_40x40.webp
  image_dark: /images/arrow_down_02_dark_40x40.webp
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
    - point: Not SEO-optimized, no advertisements, no third-party cookies, no user profiling, no data collection. The Private Policy can be found <a href="http://localhost:1313/privacy-policy" class="a1">here</a>.
    - point: A huge thank you! This website would not have been possible without the incredible contributions to the Hugo framework and the Hugoplate theme, developed by Zeon Studio.
  github_status:
    - label: "wf_ci-cd-pipeline"
      url: "https://github.com/v6Org01/jlv6/actions/workflows/ci-cd-pipeline.yaml"
      badge_url: "https://img.shields.io/github/workflow/status/v6Org01/jlv6/ci-cd-pipeline?label=workflow&logo=github"
    - label: "git-tag"
      url: ""
      badge_url: "https://img.shields.io/github/v/tag/v6Org01/jlv6?label=version&color=4c1&logo=github"

# Sections
sections:
  - title: "Dashboard" 
    content: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua."

  - title: "Tech Blog"
    image_light: "/images/diag_network.png"
    image_dark: "/images/diag_network_darkmode.png"
    content: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua."
    button:
      enable: true
      label: "Start Reading"
      link: "http://localhost:1313/techblog"

  - title: "Tech Wiki"
    content: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua."
---