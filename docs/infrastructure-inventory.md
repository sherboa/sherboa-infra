# Sherboa Infrastructure Inventory

**Snapshot date:** 2026-11-06
**Environment:** AWS
**Status:** Existing manually provisioned production infrastructure
**Purpose:** Document the current infrastructure as a baseline for the Terraform migration.

---

## 1. Overview

Sherboa currently runs on a single AWS EC2 instance hosting the backend API and its reverse proxy.

The frontend is hosted separately through GitHub Pages, while Cloudflare provides DNS management, proxying, and edge security for the public domains.

The backend consists of a FastAPI application running inside Docker, with Caddy acting as the HTTPS reverse proxy.

The current infrastructure was provisioned and configured manually. This inventory records its architecture, configuration, security controls, and operational limitations before migrating to Infrastructure as Code (IaC).

### High-level architecture

```text
                         Internet
                            |
                            v
                       Cloudflare
                    DNS / Proxy / TLS
                            |
                            v
                       AWS Security
                         Group
                            |
                            v
                     EC2 Instance
                       Ubuntu ARM64
                            |
                            v
                      Caddy Proxy
                       Ports 80/443
                            |
                            v
                   Docker Bridge Network
                            |
                            v
                    Sherboa Engine
                      FastAPI :8000
                            |
                            v
                   FFmpeg / libvmaf
                   VMAF / PSNR / SSIM
                            |
                            v
                    Persistent Storage
                     SQLite Usage DB
```

The frontend is hosted independently:

```text
User Browser
     |
     v
GitHub Pages
     |
     v
sherboa.com
     |
     v
Cloudflare
```

The frontend communicates with the backend API through its public HTTPS endpoint.

---

## 2. Compute

| Property | Current configuration |
|---|---|
| Service | Amazon EC2 |
| Instance type | `t4g.small` |
| Architecture | ARM64 |
| vCPU | 2 |
| Memory | 2 GiB |
| Region | `us-east-1` |
| Availability Zone | `us-east-1f` |
| Operating system | Ubuntu 26.04.1 LTS |
| Kernel | Linux 7.0 AWS kernel |
| Instance state | Running |
| CPU credit mode | Standard |
| EBS optimization | Enabled |
| Detailed monitoring | Disabled |
| Public IPv4 | Dynamic |
| IAM instance profile | Attached |
| Instance metadata | IMDSv2 required |

### Initial observations

- CPU utilization was very low during the sampled observation period.
- CPU credit balance remained at its maximum during the same period.
- These observations are not a substitute for load testing or a capacity benchmark.
- The current instance has limited memory headroom for concurrent video-processing workloads.

The next infrastructure iteration should evaluate instance sizing based on real FFmpeg and libvmaf measurements.

---

## 3. Storage

### Root volume

| Property | Current configuration |
|---|---|
| Type | Amazon EBS |
| Volume type | gp3 |
| Capacity | 20 GiB |
| Provisioned IOPS | 3,000 |
| Throughput | 125 MiB/s |
| Encryption | Disabled |
| Delete on termination | Enabled |
| Filesystem | ext4 |

### Persistent application data

The Engine container uses a host bind mount:

```text
Host:      /srv/sherboa-data
Container: /data
Access:    Read/write
```

The directory contains the SQLite database used by the daily per-IP usage quota system.

```text
/data/usage.db
```

The directory is owned by the application user (UID/GID 10001), with restricted directory permissions.

### Storage considerations

- The SQLite database persists outside the Engine container.
- It currently resides on the EC2 root EBS volume.
- The root volume is not encrypted and is configured for deletion when the instance is terminated.
- The database must be backed up and migrated consistently during infrastructure replacement.
- A future deployment should use encrypted storage and an explicit backup strategy for persistent application data.

---

## 4. Networking

### Network architecture

The current deployment uses the default AWS VPC.

Its networking configuration includes:

- Public subnets.
- An Internet Gateway.
- A main route table with a default route to the Internet Gateway.
- A dedicated Security Group for the Sherboa instance.
- No IPv6 ingress configuration.

### Security Group

Inbound access is restricted as follows:

| Protocol | Port | Source | Purpose |
|---|---:|---|---|
| TCP | 80 | Cloudflare IPv4 ranges | HTTP / certificate validation and redirection |
| TCP | 443 | Cloudflare IPv4 ranges | HTTPS traffic |
| TCP | 22 | Trusted administrative IP | SSH administration |

Outbound traffic is currently allowed to all IPv4 destinations.

The exact administrative source IP and AWS resource identifiers are intentionally excluded from this public inventory.

### Traffic flow

```text
Internet
   |
   v
Cloudflare
   |
   v
AWS Security Group
   |
   v
EC2 / Caddy
   |
   v
Docker Network
   |
   v
Sherboa Engine
```

Only Caddy exposes public HTTP/HTTPS ports.

The FastAPI application listens on port 8000 inside the Docker network and is not directly published on the EC2 host.

### Cloudflare trusted proxies

Caddy is configured to trust Cloudflare's published proxy IP ranges.

It uses the `CF-Connecting-IP` header to identify the original client IP and forwards the resolved client address to the backend.

This is important because the backend applies request limits and daily usage quotas based on the visitor's IP address.

The Uvicorn configuration trusts forwarded headers only from the Caddy container's Docker network address.

---

## 5. Docker Runtime

### Host configuration

| Property | Current configuration |
|---|---|
| Docker Engine | 29.8.1 |
| Docker Compose plugin | 5.5.1 |
| Architecture | ARM64 |
| Storage driver | overlayfs |
| Cgroup version | v2 |
| Cgroup driver | systemd |
| Firewall backend | iptables |
| Logging driver | json-file |
| Docker daemon configuration | Default; no custom `daemon.json` |
| Docker service | Enabled and active |

Docker Compose is installed, but the current deployment is managed using individual Docker commands.

No Docker Compose YAML file is currently used in production.

### Docker networks

A dedicated bridge network connects the two containers.

| Property | Configuration |
|---|---|
| Driver | bridge |
| IPv6 | Disabled |
| Internal network | No |
| Attachability | Disabled |

The containers use fixed addresses within this network:

| Container | Role |
|---|---|
| Caddy | Reverse proxy |
| Sherboa Engine | Backend API |

The backend trusts forwarded headers only from the Caddy container's address. Any future Compose configuration must preserve this trust relationship or deliberately redesign it.

### Container configuration

#### Sherboa Engine

| Property | Configuration |
|---|---|
| Image source | Amazon ECR |
| Image tag | Git commit SHA |
| Network | Dedicated Sherboa bridge |
| Host port mapping | None |
| Internal port | 8000 |
| Restart policy | `unless-stopped` |
| Privileged mode | Disabled |
| Persistent mount | `/srv/sherboa-data:/data` |
| Runtime user | Non-root, UID 10001 |

The application runs using Uvicorn with proxy-header support.

#### Caddy

| Property | Configuration |
|---|---|
| Image | `caddy:2` |
| Network | Dedicated Sherboa bridge |
| Published ports | 80/TCP, 443/TCP, 443/UDP |
| Restart policy | `unless-stopped` |
| Privileged mode | Disabled |
| Configuration | Host-mounted Caddyfile |
| Persistent data | Host-mounted Caddy data and config directories |

Caddy manages HTTPS certificates and proxies requests to the Engine container.

### Docker runtime considerations

The current containers do not have explicit CPU, memory, or PID limits.

Docker uses the default `json-file` logging driver without configured rotation.

The future deployment should introduce:

- Container resource limits based on measurements.
- Docker log rotation using `max-size` and `max-file`.
- A version-controlled Compose configuration.
- Explicit container health checks.
- A deployment strategy that supports rollback.

---

## 6. Operating System and Host Services

The EC2 host runs Ubuntu LTS on ARM64.

Relevant host configuration:

- Docker service enabled at boot.
- Unattended security updates enabled.
- NTP synchronization active.
- UFW inactive.
- AppArmor active.
- Seccomp enabled with Docker's default profile.
- Docker Live Restore disabled.
- Swarm inactive.
- System timezone set to UTC.

Standard system maintenance timers are active, including:

- APT package updates.
- Log rotation.
- Temporary-file cleanup.
- Filesystem trimming.
- System statistics collection.

The future infrastructure deployment should explicitly document host hardening, patching, firewall responsibilities, and reboot behavior.

UFW should not be enabled without first reviewing its interaction with Docker-managed firewall rules.

---

## 7. IAM and Access Management

### EC2 instance role

The EC2 instance uses an IAM instance profile associated with a dedicated role.

Its permissions include:

- AWS Systems Manager managed-instance functionality.
- Authentication to Amazon ECR.
- Pulling container images from the Sherboa Engine repository.

ECR pull permissions are scoped to the application repository wherever supported.

### GitHub Actions deployment role

GitHub Actions authenticates to AWS using OpenID Connect (OIDC).

The trust relationship is restricted to the Sherboa repository's deployment branch.

The role's permissions include:

- ECR authentication.
- Pushing container images to the application repository.
- Sending deployment commands through AWS Systems Manager.
- Retrieving command execution status.

The deployment does not rely on long-lived AWS access keys stored in GitHub.

### IAM considerations

The current design follows least-privilege principles in several important areas:

- Separate roles for the EC2 instance and GitHub Actions.
- OIDC-based CI/CD authentication.
- Repository-scoped ECR image permissions.
- Instance-scoped deployment command permissions where supported.

The permission scope for retrieving SSM command invocation results should be reviewed and tightened where possible.

---

## 8. CI/CD Pipeline

The backend CI/CD workflow is defined in:

```text
.github/workflows/sherboa-ci-cd.yml
```

It runs on pushes to the `main` branch.

### Current deployment flow

1. Checkout the repository.
2. Authenticate to AWS using GitHub Actions OIDC.
3. Authenticate to Amazon ECR.
4. Build the Docker image on an ARM64 runner.
5. Tag the image using the Git commit SHA.
6. Push the image to ECR.
7. Send a deployment command through AWS Systems Manager.
8. Pull the new image on the EC2 instance.
9. Replace the existing Engine container.
10. Run a health-check loop.
11. Remove unused local Docker images.

### Current strengths

- ARM-native build runner.
- Immutable Git-SHA image tags.
- OIDC authentication instead of static AWS credentials.
- Deployment through SSM rather than an exposed SSH-based CI/CD connection.
- Basic post-deployment health validation.

### Current limitations

- The old container is removed before the new container is confirmed healthy.
- There is no automated rollback mechanism.
- Docker image pruning removes local images that could otherwise be useful for rollback.
- The health check currently validates only the API root endpoint.
- Deployment configuration is coupled to the existing EC2 instance.
- The workflow deploys the Engine but does not manage Caddy.

These limitations should be addressed as part of the Terraform and deployment automation work.

---

## 9. Amazon ECR

The backend container image is stored in Amazon Elastic Container Registry.

| Property | Current configuration |
|---|---|
| Service | Amazon ECR |
| Repository | Sherboa Engine |
| Region | `us-east-1` |
| Image tagging | Git commit SHA |
| Tag mutability | Immutable |
| Image encryption | AES-256 |
| Scan on push | Disabled |
| Lifecycle policy | Not configured |

### Considerations

- Enable image vulnerability scanning.
- Configure a lifecycle policy that retains enough images for operational rollback.
- Review image retention and storage costs.
- Keep image tags immutable.
- Evaluate the OCI Container Registry equivalent during the future OCI deployment stage.

---

## 10. Security Controls

The current production environment includes the following controls:

| Area | Current implementation |
|---|---|
| Public HTTPS | Cloudflare and Caddy |
| Origin access | Cloudflare-restricted inbound HTTP/HTTPS |
| Administrative access | SSH restricted to a trusted source IP |
| Backend exposure | Internal Docker network only |
| Container user | Non-root |
| Container privilege | Disabled |
| Forwarded client IP | Cloudflare → Caddy → Uvicorn |
| Request rate limiting | Application-level limits |
| Daily usage quota | Persistent SQLite database |
| Analysis concurrency | Application-level concurrency lock |
| Instance management | AWS Systems Manager |
| CI/CD authentication | GitHub Actions OIDC |
| Container image access | IAM-scoped ECR permissions |

### Application-level limits

The backend implements:

- General request rate limiting.
- Analysis-specific request limits.
- A daily per-IP analysis quota.
- A concurrency limit that prevents multiple simultaneous analyses within the current application process.

The daily usage database persists outside the container.

These controls are intended to protect the free public service from excessive usage and resource exhaustion.

---

## 11. Observability and Monitoring

### Current state

The infrastructure currently relies primarily on standard EC2 CloudWatch metrics.

| Capability | Current state |
|---|---|
| EC2 basic metrics | Available |
| Detailed EC2 monitoring | Disabled |
| RAM metrics | Not configured |
| Disk usage metrics | Not configured |
| CloudWatch Agent | Not installed |
| Sherboa application logs | Not centralized |
| Caddy logs | Local Docker logs |
| Engine logs | Local Docker logs |
| CloudWatch alarms | None configured |
| Application-level metrics | Not centralized |

Some CloudWatch log groups exist in the AWS account, but they appear unrelated to Sherboa and are not considered part of the current application monitoring setup.

### Future monitoring requirements

The Terraform-managed environment should introduce:

- CloudWatch Agent for memory and disk metrics.
- CPU, memory, disk, and instance-health alarms.
- Centralized Caddy and Engine logs with explicit retention.
- Docker log rotation.
- Monitoring of analysis counts, durations, failures, and HTTP 429 responses.
- A notification mechanism for important operational events.
- Cost-aware retention and monitoring configuration.

Monitoring thresholds should be established after observing real application workloads.

---

## 12. Infrastructure Gaps and Migration Priorities

The current deployment is functional, but several areas should be improved before considering the infrastructure fully reproducible.

| Area | Current limitation | Planned improvement |
|---|---|---|
| Provisioning | Manual EC2 configuration | Terraform |
| Deployment | Individual Docker commands | Docker Compose |
| Storage encryption | Root volume unencrypted | Encrypted EBS |
| Database backup | No formal backup strategy | Consistent backup and recovery |
| Container resources | No explicit limits | Measured CPU, memory, and PID limits |
| Docker logs | No rotation | Bounded log rotation |
| Image security | Scan on push disabled | Enable vulnerability scanning |
| ECR retention | No lifecycle policy | Lifecycle management |
| Rollback | No automated rollback | Safe deployment and rollback |
| Monitoring | Basic EC2 metrics only | CloudWatch Agent and alarms |
| Application metrics | Not centralized | Application observability |
| Infrastructure documentation | Partially manual | Version-controlled IaC and documentation |

---

## 13. Terraform Migration Strategy

The first IaC stage will target AWS.

The goal is to provision a new infrastructure environment from scratch using Terraform, without importing or modifying the existing production resources.

### Planned approach

1. Define the AWS infrastructure in Terraform.
2. Create the required networking and security resources.
3. Provision a new EC2 instance.
4. Configure storage, IAM, and host prerequisites.
5. Deploy Docker, Caddy, and Sherboa Engine.
6. Configure monitoring and operational safeguards.
7. Validate the new environment independently.
8. Migrate persistent application data consistently.
9. Switch the public API DNS target through Cloudflare.
10. Keep the existing infrastructure available until the migration is confirmed successful.

### Terraform state

Terraform state will be stored separately from the source repository.

The AWS state backend should use:

- Amazon S3.
- Versioning.
- Encryption.
- Restricted access permissions.

Terraform state files and credentials must never be committed to Git.

### Future OCI stage

OCI will be treated as a separate IaC implementation.

The AWS and OCI Terraform configurations will have independent provider-specific resources and state.

Portable deployment components, such as Docker Compose, Caddy configuration, bootstrap scripts, and application configuration conventions, should be shared where practical.

---

## 14. Final Assessment

The existing Sherboa infrastructure provides a working production baseline with several important security and deployment foundations already in place.

Its main strengths are:

- Cloudflare-protected public access.
- Caddy-managed HTTPS.
- Internal-only backend networking.
- Non-root container execution.
- Persistent application quota storage.
- IAM-based access to ECR.
- GitHub Actions OIDC authentication.
- SSM-based deployment.

The primary objective of the next stage is to make the infrastructure reproducible, observable, recoverable, and easier to operate.

**Terraform will become the source of truth for AWS infrastructure, while container deployment components will remain as portable as possible for the later OCI implementation.**