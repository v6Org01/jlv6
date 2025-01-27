---
# Introduction
introduction:
  titleP1: Host
  titleP2: Hub
  subtitle: Your hub for services hosted @jlv6.com
  mvp_title: "🚧 This is an MVP 🚧"
  mvp_text: <span class="title-explanation">Welcome! This is the early version of the site. Most features are broken and pratically all content is missing. New builds are being released regularly to fix and improve things.</span>
  arrow_text: Features
  image_light: /images/arrow_down_02_light_40x40.webp
  image_dark: /images/arrow_down_02_dark_40x40.webp
  bulletpoints:
    - point: /index.html has been served directly from <img src="https://img.shields.io/badge/Kubernetes%20(onPremise)-326CE5?logo=kubernetes&logoColor=fff" alt="K8S Badge"> .
    - point: <img src="https://img.shields.io/badge/AWS%20CloudFront-%23FF9900.svg?logo=amazon-web-services&logoColor=white" alt="AWS Cloudfront Badge"> handles caching and delivery of all other content, with these specific details... 
      subpoints:
        - "Distribution pulls content from 2 Origins: An on-premise Kubernetes cluster  (primary) or a EU-hosted AWS S3 bucket (secondary)."
        - Function to return 403 Forbidden if user-agent = known AI crawler bot.
        - Function to rewrite URI when Orgin = S3; needed for in-bucket versioning.
        - Lambda@Edge Function to modify host header on origin-request to Origin = S3.
        - Custom headers for on-premise routing and showing /index.html location.
        - _Blog entries will be created shortly to describe ingress for this static site and its CI/CD pipeline._ 
    - point: Website development and deployment are fully driven by Infrastructure as Code (IaC). Project code is stored in GitHub repository <a href="https://github.com/v6Org01/jlv6" target="_blank" rel="noopener"><img src="https://img.shields.io/badge/v6Org01%2Fjlv6-%23000000.svg?logo=github&logoColor=white" alt="GitHub/jlv6 Badge"></a>.
      subpoints:
        - "<u>Main branch</u>: GitHub Action workflows, Terraform config files, Docker files,  ArgoCD application manifests and /public dir."
        - "<u>Development branch</u>: Hugo theme files and script to push /public to main."
      badges: # Rendered after subpoints
        - badge_url: "https://img.shields.io/github/actions/workflow/status/v6Org01/jlv6/ci-cd-pipeline.yaml?label=wf-ci-cd-pipeline&logo=github"
          url: "https://github.com/v6Org01/jlv6/actions/workflows/ci-cd-pipeline.yaml"
          label: "wf_ci-cd-pipeline"
        - badge_url: "https://img.shields.io/github/last-commit/v6Org01/jlv6?branch=main&logo=github"
          url: ""
          label: "last-commit"
        - badge_url: "https://img.shields.io/github/v/tag/v6Org01/jlv6?label=version&color=4c1&logo=github"
          url: ""
          label: "tag"

# Sections
sections:
  - title: "Dashboard"
    subtitle: "Req. multi-factor authentication | only available on-premise"
    image_light: "/images/stock_homepage.png"
    image_dark: "/images/stock_homepage.png"
    image_text: 'img src: <a href="https://gethomepage.dev" class="a1" target="_blank" rel="noopener">homepage.dev</a>'
    content: The excellent Homepage.dev dashboard provides quick access to all hosted applications, presenting their statuses in a single view. Information widgets for Kubernetes, Longhorn & the Unifi Controller provide a quick glance at some of the infrastructure. Additionally, it functions as a simple and efficient bookmark manager.
    button:
      enable: true
      label: "Dashboard"
      link: "https://dashboard-www.jlv6.com"
  - title: "Tech Blog"
    subtitle:  "Documenting Tech, One Post at a Time"
    image_light: "/images/diag_network_01_light.png"
    image_dark: "/images/diag_network_01_dark.png"
    content: "The technology blog serves as a comprehensive resource for in-depth articles, complete with diagrams to enhance understanding. Each post is categorized and tagged, making it easy to navigate and find relevant content."
    button:
      enable: true
      label: "Start Reading"
      link: "http://localhost:1313/blog"
  - title: "Wiki"
    subtitle: "Req. multi-factor authentication | only available on-premise"
    image_light: "/images/stock_dokuwiki.png"
    image_dark: "/images/stock_dokuwiki.png"
    content: "This private wiki, powered by DokuWiki and its Bootstrap3 template, offers a simple no-database solution for organizing personal notes, project documentation and sensitive data."
    button:
      enable: true
      label: "Enter Wiki"
      link: "https://wiki-www.jlv6.com"
---