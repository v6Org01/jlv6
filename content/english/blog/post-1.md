---
title: "Using OpenTelemetry, OpenObserve, and Grafana to collect, transform, and visualize Logs, Metrics, and Traces"
meta_title: ""
description: ""
date: 2025-03-21T05:00:00Z
image_light: "/images/diag_observability_01_light.png"
image_dark: "/images/diag_observability_01_dark.png"
categories: ["Observability"]
tags: ["AWS Lambda", "HAProxy", "Grafana", "Kubernetes", "Logs", "Metrics", "Minio", "OpenObserve", "OpenTelemetry", "PostgreSQL", "Traces", "Traefik", "Code:Terraform"]
draft: false
---
<br>

##### 1. Introduction

Since I’m hosting critical services—like a home automation platform, file storage, and photo storage—for people close to me, monitoring the health and performance of these systems is essential. With so many tools and services available today for logging, metrics, and tracing, it was quite a journey to select the individual components that eventually came together to form this observability stack. What began as a solution using the kube-prometheus-stack Helm chart and a wonky relay to forward AlertManager notifications to nfty.sh, eventually evolved into a more robust and scalable stack. The core of it consists of OpenTelemetry collectors, OpenObserve as the central monitoring hub, and Grafana to visualize and share the collected data.

##### 2. OpenTelemetry

The OpenTelemetry Operator has been deployed with ArgoCD using its Helm chart. The Operator manages OpenTelemetry Collector instances, which are created via the opentelemetrycollectors.opentelemetry.io Custom Resource Definition (CRD). I maintain manifests for the collectors and apply them manually. All collectors use the otel/opentelemetry-collector-contrib image and are configured to use the same exporter for sending the collected data.

```yaml{linenos=inline hl_lines=[0] style=nordic}
spec:
  env:
    - name: OPENOBSERVE_TOKEN
      valueFrom:
        secretKeyRef:
          name: opentelemetry-o2token
          key: o2token
  config:
    ...
    exporters:
      otlp/openobserve:
        endpoint: openobserve-router.ns.svc.cluster.local:5081
        headers:
          Authorization: "Basic ${env:OPENOBSERVE_TOKEN}"
          organization: default
        tls:
          insecure: true
```
A separate OpenTelemetry collector is created for each receiver, so as to help spread the load of collecting data:
- httpcheck: Collects health and performance metrics for HTTP endpoints.
- k8s_cluster: Collects cluster-level metrics and entity events from the Kubernetes API server.
- k8sobjects: Collects objects from the Kubernetes API server.
- k8slog: Collects pod logs across all nodes (in daemonset-stdout mode).
- kubeletstats: Collects node, pod, container, and volume metrics  from the kubelet endpoint on each node.

There isn’t much more to it to get started. I'll create separate blog posts to provide more details on how the collectors are configured and used.

##### 3. OpenObserve

OpenObserve serves as the central hub of my observability stack, offering a powerful, all-in-one solution for storing, querying, transforming and visualizing logs, metrics, and traces. While similar solutions offer feature parity with OpenObserve, it’s the ease of setup, simplicity in use, and fantastic out-of-the-box experience that truly sold me on it.

Another thing I appreciate about it is its scalability and performance. Its microservices-based architecture, with separate pods for the ingester, querier, router, alertmanager, NATS cluster, and compactor, allows each component to scale independently. Its ability to process and transform data using Pipelines and Functions is another big plus as it lets me filter, enrich, and reformat the incoming data before storing it.

![img](/images/scr_openobserve_logs_cloudfront_01.png)
*OpenObserve UI*


###### 3.1 Environment Variables

Here is the list of environment variables for which I changed the default values in the Helm chart values.yaml file:
```bash{linenos=inline hl_lines=[0] style=nordic}
ZO_CLUSTER_NAME: "o2-pluto"
ZO_CLUSTER_COORDINATOR: "nats"
ZO_COMPACT_DATA_RETENTION_DAYS: "30"
ZO_LOCAL_MODE: "false"  ## false indicates cluster mode deployment which supports multiple nodes with different roles.
ZO_META_STORE: "postgres"
ZO_NATS_ADDR: "nats://openobserve-nats.ns.svc.cluster.local:4222"
ZO_S3_PROVIDER: "minio"
ZO_S3_SERVER_URL: "http://a-hl.ns.svc.cluster.local:9000"
ZO_S3_REGION_NAME: "eu-west-01"
ZO_S3_BUCKET_NAME: "openobserve"
ZO_SMTP_ENABLED: "true"
ZO_SMTP_HOST: "in-v3.mailjet.com"
ZO_SMTP_PORT: "587"
ZO_SMTP_FROM_EMAIL: "admin_noreply@jlv6.com"
ZO_SMTP_ENCRYPTION: "starttls"
ZO_TELEMETRY: "false"
ZO_WEB_URL: "https://<subdomain>.jlv6.com"
```

The following keys exist in a Kubernetes secret named openobserve-secrets:

```bash{linenos=inline hl_lines=[0] style=nordic}
ZO_META_POSTGRES_DSN
ZO_REPORT_USER_EMAIL
ZO_REPORT_USER_PASSWORD
ZO_ROOT_USER_EMAIL
ZO_ROOT_USER_PASSWORD
ZO_S3_ACCESS_KEY
ZO_S3_SECRET_KEY
ZO_SMTP_PASSWORD
ZO_SMTP_USER_NAME
ZO_TRACING_HEADER_KEY
ZO_TRACING_HEADER_VALUE
```

###### 3.2 RBAC & SSO limitations

One of the more noticeable limitations with OpenObserve is that RBAC (Role-Based Access Control) and SSO (Single Sign-On) are enterprise-only features. While I understand that this is a common business model in the industry and that there needs to be a value-add for paying customers, it makes access management significantly more cumbersome in my setup. Because of this limitation:

- All the OpenObserve user accounts I've created for authentication—including those for collectors, AWS services, and Grafana—have access to all data streams and other resources in the instance, as accounts can only be assigned the Admin role.

- The Traefik Forward Auth middleware needs to be added to OpenObserve's UI IngressRoute to fulfill the Multi-Factor Authentication (MFA) requirement I have for all the core services I'm hosting. As a result, users must authenticate twice: first by logging in via Authelia, which authenticates against an [LLDAP](https://github.com/lldap/lldap) backend, and then by authenticating again with a local OpenObserve user.

##### 4. Grafana

The only reason Grafana is part of the stack is because OpenObserve does not (yet) provide a secure way to share its dashboards with anonymous viewers or embed them in an iframe. Accessing the Grafana UI can only be done as an authenticated user from a device with an RFC1918 IP address, additional Traefik ingressRoutes have been created to allow access to public-dashboards from anywhere.

###### 4.1 Configuration file (grafana.ini)   

```bash{linenos=inline hl_lines=[0] style=nordic}
[analytics]
reporting_enabled = false
check_for_updates = false  ## Updates managed via its Helm chart.

[date_formats]
default_timezone = UTC

[server]
enable_gzip = true
protocol = http
http_addr = 0.0.0.0
http_port = 3000
root_url = https://<subdomain>.jlv6.com
```

Grafana’s generic OAuth authentication method is used to enable Single Sign-On (SSO) for jlv6.com's LDAP users through its integration with the Authelia OIDC Provider. Authelia authenticates users against the LLDAP backend and provides Grafana with relevant details, such as group membership, allowing Grafana to assign roles to LDAP users based on this information.

```bash{linenos=inline hl_lines=[0] style=nordic}
[auth.generic_oauth]
enabled = true
name = Authelia
icon = signin
auto_login = false
client_id = grafana
client_secret = <secret>
scopes = openid profile email groups
empty_scopes = false
auth_url = https://.../api/oidc/authorization
token_url = https://.../api/oidc/token
api_url = https://.../api/oidc/userinfo
login_attribute_path = preferred_username
name_attribute_path = name
groups_attribute_path = groups
role_attribute_path = contains(groups, 'GrafanaAdmins') && 'Admin' || 'Viewer'
role_attribute_strict = true
allow_assign_grafana_admin = false
skip_org_role_sync = false
use_pkce = true
```

When using Grafana -> PgBouncer -> PostgreSQL, it’s important to set binary_parameters=yes in the connection string. Without this setting, Grafana may log errors like "unnamed prepared statement does not exist".

```bash{linenos=inline hl_lines=[0] style=nordic}
[database]
url = postgres://<db_user>:<db_user_password>@cloudnative-pg-black-pooler-rw.ns.svc.cluster.local:5432/<database>?sslmode=disable&binary_parameters=yes
```

Set allow_embedding to true in the security section to allow embedding dashboards in an iframe.

```bash{linenos=inline hl_lines=[0] style=nordic}
[security]
disable_initial_admin_creation = true
allow_embedding = true
```

I go into more detail about the plugin section in the next blog section: **Querying OpenObserve logs**.

```bash{linenos=inline hl_lines=[0] style=nordic}
[plugins]
enable_alpha = true
app_tls_skip_verify_insecure = false
allow_loading_unsigned_plugins = zinclabs_openobserve
```

###### 4.2 Querying OpenObserve logs  

The team behind OpenObserve has dedicated a [documentation page](https://openobserve.ai/docs/operator-guide/grafana_plugin/#explore-logs) to installing and configuring their Grafana plugin. Looking through its GitHub repository’s issues tab, there are some longstanding open issues, but none of them are affecting me. To set it up, I added an initContainer to the Grafana deployment that pulls the plugin and installs it at /var/lib/grafana/plugins.

Once the plugin was installed, I added it in the Grafana UI as a new data source…
![img-50per](/images/scr_grafana_plugin_openobserve_01.png)
![img-50per](/images/scr_grafana_plugin_openobserve_02.png)

###### 4.3 Querying OpenObserve metrics

Since OpenObserve exposes metrics by default, all I had to do was add a data source of type Prometheus in Grafana, point it at OpenObserve's metric endpoint (http://openobserve-router.ns.svc.cluster.default:5080/api/default/prometheus), and configure basic authentication.
![img-75per](/images/scr_grafana_openobserve_metrics_01.png)

##### 5. Why not use these alternatives?  

As is often the case, there’s more than one way to skin a cat. Below, you’ll find a list of alternatives I’ve considered at various points during this process.

###### 5.1 OpenTelemetry-eBPF

I wish I could have used OpenTelemetry-eBPF's kernel collector to gather low-level telemetry directly from the Linux kernel using eBPF. Unfortunately, the project doesn’t provide ARM64 images for its collectors, preventing me from deploying it across all nodes in my primary Kubernetes cluster. That said, [the project](https://github.com/open-telemetry/opentelemetry-network) is defintely worth checking out, as it also includes a Kubernetes and cloud collector, which enhance the collected telemetry with workload-specific metadata.

###### 5.2 AWS CloudWatch

Although CloudWatch supports all the collectors I’m running, the costs associated with ingesting and storing logs, metrics, and traces from non-AWS services—along with the expenses for custom dashboards—make it too cost-prohibitive to be the central hub for monitoring activities.

###### 5.3 AWS CloudFront standard access or real-time logs

While I collect standard access logs for all CloudFront distributions in a centralized S3 bucket, I rarely use them. They’re nice to have for occasional queries, but from a monitoring perspective, I’m primarily interested in real-time logs.

Which brings us to the option of streaming real-time logs from CloudFront to OpenObserve using AWS Kinesis Firehose. It is the approach I’d recommend, as it provides all the essential data and is relatively easy to set up. Unfortunately, the cost of running even the smallest Firehose configuration (mode=provisioned, shard=1, retention_period=24hr) made it too cost-prohibitive for a hobby project. Even when limiting it to this site’s production distribution—with minimal traffic—I was accumulating an average cost of $5/day. For comparison, my total monthly AWS bill is less than $0.30.  

If you’re interested in implementing this approach, I highly recommend checking out [this blog post](https://openobserve.ai/blog/monitor-cloudfront-access-logs-kinesis-streams-amazon-data-firehose-guide/). These are the code snippets I've used to enable real-time logging according to the post, with Terraform...

<details close>
<summary><b>Code snippets</b></summary>

```tf{linenos=inline hl_lines=[148] style=nordic}
resource "aws_kinesis_stream" "kinesis_stream_xx" {
  provider         = aws.us_east_1
  name             = "cf-logs-jlv6-production"
  shard_count      = 1
  retention_period = 24

  stream_mode_details {
    stream_mode = "PROVISIONED"
  }
}

resource "aws_kinesis_firehose_delivery_stream" "kinesis_firehose_stream_xx" {
  provider    = aws.us_east_1

  name        = "cf-logs-jlv6-production"
  destination = "http_endpoint"

  kinesis_source_configuration {
    role_arn           = aws_iam_role.iam_role_xx.arn
    kinesis_stream_arn = aws_kinesis_stream.kinesis_stream_xx.arn
  }

  http_endpoint_configuration {
    url                = "https://openobserve.jlv6.com/aws/default/cloudwatch_metrics/_kinesis_firehose"
    name               = "OpenObserve instance on Pluto"
    access_key         = "<ACCESS_KEY>"
    buffering_size     = 1
    buffering_interval = 60
    role_arn           = aws_iam_role.iam_role_xx.arn
    s3_backup_mode     = "FailedDataOnly"

    s3_configuration {
      role_arn           = aws_iam_role.iam_role_xx.arn
      bucket_arn         = module.s3_bucket_xx.s3_bucket_arn
      buffering_size     = 5
      buffering_interval = 300
      compression_format = "GZIP"
    }

    processing_configuration {
      enabled = "true"
      processors {
        type = "Lambda"
        parameters {
          parameter_name  = "LambdaArn"
          parameter_value = "${module.lambda_xx.lambda_function_qualified_arn}"
        }
        parameters {
          parameter_name  = "BufferSizeInMBs"
          parameter_value = "3"
        }
        parameters {
          parameter_name  = "BufferIntervalInSeconds"
          parameter_value = "45"
        }
      }
    }
    request_configuration {
      content_encoding = "NONE" 
    }
  }
}

resource "aws_cloudfront_realtime_log_config" "cf_realtime_log_config_xx" {
  provider = aws.us_east_1
  depends_on = [
    aws_iam_role.iam_role_xx,
    aws_kinesis_stream.kinesis_stream_xx
  ]
 
  name          = "jlv6-www"
  sampling_rate = 100
 
  fields = [
    "timestamp",
    "c-ip",
    "cs-method",
    "cs-uri-stem",
    "sc-status",
    "x-edge-result-type",
    "x-edge-response-result-type",
    "cs-user-agent",
    "cs-referer"
  ]
 
  endpoint {
    stream_type = "Kinesis"
 
    kinesis_stream_config {
      role_arn   = aws_iam_role.iam_role_xx.arn
      stream_arn = aws_kinesis_stream.kinesis_stream_xx.arn
    }
  }
}

module "cf_distribution_xx" {
  source = "terraform-aws-modules/cloudfront/aws"
  providers = {
    aws = aws.us_east_1
  }

  aliases = ["www.jlv6.com"]

  comment             = "Production distribution for www.jlv6.com"
  enabled             = true
  is_ipv6_enabled     = false
  price_class         = "PriceClass_100"
  retain_on_delete    = false
  wait_for_deployment = true

  geo_restriction = {
    restriction_type = "whitelist"
    locations        = ["US", "CA", "GB", "DE", "FR", "BE", "NL", "LU"]
  }

  create_origin_access_identity = false
  create_origin_access_control = false

  logging_config = {
    bucket = data.terraform_remote_state.shared.outputs.module_s3_bucket_xx_s3_bucket_bucket_domain_name
    prefix = "cf_production"
  }

  origin = {
    primaryK8S = {
      domain_name = <subdomain>.jlv6.com
      custom_origin_config = {
        http_port              = 80
        https_port             = 443
        origin_protocol_policy = "https-only"
        origin_ssl_protocols   = ["TLSv1.2"]
      }
    }
  }

  default_cache_behavior = {
    target_origin_id       = "primaryK8S"
    viewer_protocol_policy = "https-only"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    compress               = true

    use_forwarded_values         = false
    cache_policy_id              = "658327ea-f89d-4fab-a63d-7e88639e58f6" # Managed-CachingOptimized
    origin_request_policy_id     = "33f36d7e-f396-46d9-90e0-52428a34d9dc" # Managed-AllViewerAndCloudFrontHeaders-2022-06
    response_headers_policy_id   = "67f7725c-6f97-4210-82d7-5512b31e9d03" # Managed-SecurityHeadersPolicy

    realtime_log_config_arn = aws_cloudfront_realtime_log_config.cf_realtime_log_config_xx.arn
    
    lambda_function_association = {
      viewer-request = {
        include_body = false
        lambda_arn   = data.terraform_remote_state.shared.outputs.module_lambda_at_edge_xx_lambda_function_qualified_arn
      }
    }
  }

  viewer_certificate = {
    cloudfront_default_certificate = false
    acm_certificate_arn            = data.terraform_remote_state.shared.outputs.aws_acm_certificate_certxx_arn
    ssl_support_method             = "sni-only"
    minimum_protocol_version       = "TLSv1.2_2021"
  }
}
```  

</details><br /> 

###### 5.4 Grafana Cloud (free tier)

While the free tier is quite generous, I quickly hit its 10K Metrics limit after choosing Grafana Cloud as the aggregator for all logs, metrics, and traces. I considered keeping it as part of the stack solely to share dashboards publicly, but the free hosted offering doesn’t seem to support that option. As a result, I opted to run an instance of Grafana OSS on Kubernetes, which allows me to set `allow_embedding = true` in its configuration file.

This concludes the blog post. If you have any questions, feel free to reach out at [admin@jlv6.com](mailto:admin@jlv6.com).