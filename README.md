### 🚧 Work in progress

#### To do
---

- Create image for gha runners containing packages..
  - python 3.x
  - aws cli
- Add functional test(s) to run after staging and production deployment on both aws & k8s.
- Add staging-destroy job in case of successful production deployment.
- Add revert-to-previous job in case of failed production deployment.
- Add step to update coredns-lan/values.yaml file with cloudfront_distribution_domain_names.
- Add workflow to populate traefik ipAllowList middleware with IP addresses from AWS-managed CloudFront prefix list.
- Write go plugin for Traefik to replace Cloudfront IP address in X-Real-Ip header by value of Cloudfront-Viewer-Address header.