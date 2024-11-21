### 🚧 Work in progress

#### To do
---

- Create image for gha runners containing packages..
  - python 3.x
  - aws cli
- Add functional test(s) to run after staging and production deployment on both aws & k8s.
- Add staging-destroy job in case of successful production deployment.
- Add step to update coredns-lan/values.yaml file with cloudfront_distribution_domain_names.