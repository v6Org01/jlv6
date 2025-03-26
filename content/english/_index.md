---
# Introduction
introduction:
  title: Welcome to my hobby site!
  subtitle: <span class="title-explanation">Technical Specs. Scroll down for an overview of the site's features.</span>
  arrow_text: Features
  image_light: /images/arrow_down_02_light_40x40.webp
  image_dark: /images/arrow_down_02_dark_40x40.webp
  bulletpoints:
    - point: Built using the <a href="https://gohugo.io/" target="_blank" rel="noopener"><img src="https://img.shields.io/badge/Hugo-FF4088?logo=hugo&logoColor=white" alt="Hugo Badge"></a> framework and a forked version of the <a href="https://github.com/zeon-studio/hugoplate" target="_blank" rel="noopener"><img src="https://img.shields.io/badge/Hugoplate-%23000000.svg?logo=github&logoColor=white" alt="GitHub/Hugoplate Badge"></a> theme by <a href="https://zeon.studio/" class="a1" target="_blank" rel="noopener">Zeon Studio</a>.
    - point: New builds and AWS/Kubernetes infrastructure deployed with <a href="https://github.com/features/actions" target="_blank" rel="noopener"><img src="https://img.shields.io/badge/GitHub_Actions-2088FF?logo=github-actions&logoColor=white" alt="Github Actions Badge"></a>, <a href="https://www.terraform.io/" target="_blank" rel="noopener"><img src="https://img.shields.io/badge/Terraform-844FBA?&logo=Terraform&logoColor=white" alt="Terraform Badge"></a> and <a href="https://argo-cd.readthedocs.io/en/stable/" target="_blank" rel="noopener"><img src="https://img.shields.io/badge/ArgoCD-EF7B4D?&logo=Argo&logoColor=white" alt="Argo Badge"></a>.
    - point: Hosted on geo-redundant <a href="https://kubernetes.io/" target="_blank" rel="noopener"><img src="https://img.shields.io/badge/Kubernetes-326CE5?logo=kubernetes&logoColor=fff" alt="Kubernetes Badge"></a> clusters, on <a href="https://static-web-server.net/" class="a1" target="_blank" rel="noopener">Static Web Server</a> pods fronted by <a href="https://traefik.io/traefik/" target="_blank" rel="noopener"><img src="https://img.shields.io/badge/Traefik%20Proxy-24A1C1?logo=traefikproxy&logoColor=fff" alt="Traefik Badge"></a>.
    - point: <a href="https://aws.amazon.com/cloudfront/" target="_blank" rel="noopener"><img src="https://img.shields.io/badge/AWS%20CloudFront-%23FF9900.svg?logo=amazon-web-services&logoColor=white" alt="AWS Cloudfront Badge"></a> handles caching and delivery of all content, with these specific details... 
      subpoints:
        - "Distributions: Staging(S), Production(P), Dashboard(D), Grafana(G)."
        - "Geographic restrictions (limited to): BE, CA, FR, DE, LU, NL, UK, US."
        - Lambda@Edge Function to return 403 Forbidden on viewer-request if user-agent = bot and ship logs in real-time with a unique identifier to OpenObserve for the production distribution.
        - Standard access logs for all distributions stored in jlv6-logs S3 bucket with prefix /{distribution_name}.
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
    subtitle: "Req. multi-factor authentication"
    image_light: "/images/stock_homepage.png"
    image_dark: "/images/stock_homepage.png"
    image_text: 'img src: <a href="https://gethomepage.dev" class="a1" target="_blank" rel="noopener">homepage.dev</a>'
    content: The excellent Homepage.dev dashboard provides quick access to all hosted applications and functions as a simple and efficient bookmark manager. Interested in a personal dashboard? Contact admin@jlv6.com.
    button:
      enable: true
      label: "Dashboard"
      link: "https://dashboard.jlv6.com"
  - title: "Blog"
    subtitle:  "Documenting Tech, One Post at a Time"
    image_light: "/images/diag_network_01_light.png"
    image_dark: "/images/diag_network_01_dark.png"
    image_text: 'diag: network infrastructure'
    content: "The technology blog serves as a comprehensive resource for in-depth articles, complete with diagrams to enhance understanding. Each post is categorized and tagged, making it easy to navigate and find relevant content."
    button:
      enable: true
      label: "Start Reading"
      link: "http://localhost:1313/blog"
  - title: "Status Page"
    subtitle: "Observability at a Glance"
    image_light: "/images/stock_grafana.png"
    image_dark: "/images/stock_grafana.png"
    image_text: 'img src: <a href="https://grafana.com/products/cloud" class="a1" target="_blank" rel="noopener">grafana.com</a>'
    content: "The status page provides real-time insights into the health and performance of this website, infrastructure and hosted applications. Powered by OpenObserve and Grafana, it features multiple dashboards, providing pre-configured visualizations for system metrics, application performance, and network health—ensuring transparency and reliability."
    button:
      enable: true
      label: "Status Page"
      link: "http://localhost:1313/status"
---