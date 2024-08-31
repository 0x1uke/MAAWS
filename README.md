# Malware Analysis - AWS (MAAWS)

MAAWS is a modular, infrastructure-as-code framework to provision a malware analysis lab in AWS using Terraform.

## Setup

* Install Terraform
* Install AWS CLI
* Submit "Simulated Event" Form and receive authorization to conduct malware analysis in AWS
  * https://support.console.aws.amazon.com/support/contacts#/simulated-events

### AWS Credentials

#### SSO

* Follow AWS documentation: https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-sso.html
* To create local profile:`aws configure sso`
* If profile already created:
```commandline
aws sso login --profile terraform
vim ~/.aws/config
```
* Comment out `sso_session` and `[sso-session ...]` lines (your config may look different):
```text
[profile ...]
# sso_session = ...
sso_account_id = ...
sso_role_name = ...
region = ...
output = ...
# [sso-session ...]
sso_start_url = ...
sso_region = ...
sso_registration_scopes = ...
```
* Update `profile` variable in `terraform.tfvars` to with profile name

### SSH Key

* Add your SSH key pair to your AWS account
  * https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/create-key-pairs.html 
* For encrypted private key, load decrypted key for set period for Terraform `remote-exec` provisioner:
```commandline
ssh-add -t 1h ~/.ssh/id_rsa
```

### Tailscale

* Create Tailscale account and generate auth key
  * https://login.tailscale.com/start
  * https://tailscale.com/kb/1085/auth-keys
* Export auth key as local environment variable
```commandline
export TF_VAR_tailscale_auth_key=tskey-auth...
```
* Install and authenticate Tailscale client
  * https://tailscale.com/download
* In Tailscale portal:
  * Replace ACLs in ACL tab with contents of `tailscale_acl.template` file (update <tailscale_user_email>)
  * Apply `client` tag to your machine in Machines tab

## Provision the Lab with Terraform

### Variables

1. Rename `terraform_tfvars.template` file to `terraform.tfvars`
2. Fill variables with desired values

### Build

1. `cd terraform`
2. `terraform init`
3. `terraform plan`
  * Confirm configuration and resources to be provisioned
4. `terraform apply`
5. Delete SSH inbound rule in `MAAWS-tailscale_router`'s security group
  * Rule limits SSH access to your public IP at time of deployment
  * Used to allow Terraform `remote-exec` provisioner to install Tailscale
  * Optional, but no longer needed due to access with Tailscale
6. In Tailscale portal, add `lab` tag to the new machine (Tailscale router for lab)
7. [Approve routes for Tailscacle router in Tailscale](https://tailscale.com/kb/1019/subnets#enable-subnet-routes-from-the-admin-console)
8. When finished, `terraform destroy` to remove all resources for MAAWS lab
9. Remove Tailscale router machine from Tailscale Machines tab

## Accessing Lab

* Enable Tailscale client
* For Tailscale router, use SSH with your specified SSH private key (in Terraform and AWS console), the `ec2-user` username, and the Tailscale IP (`100.X.X.X`) for the instance (found in Tailscale console's Machines tab)
  * `ssh ec2-user@<tailscale_ip>` 
* For a Windows AMI (e.g. FLAREVM), use an RDP client with the AMI's credentials and `10.0.2.10`
* For Linux AMI (e.g. REMnux), use SSH with your specified SSH private key (in Terraform and AWS console) and `10.0.2.11`
  * If desired, follow REMnux documentation to [enable GUI access](https://docs.remnux.org/tips/remnux-config-tips#gui-cloud-remnux)
* IPs may need to be confirmed in AWS console or with CLI, especially if multiple AMI instances are provisioned

## Troubleshooting

* Infrastructure-as-code (IaC) often requires troubleshooting due to various reasons (like changing cloud provider APIs)
* LLMs like ChatGPT can be very helpful in providing context to errors and possible solutions, but be sure to verify any code before use
* Writing, modifying, and debugging IaC projects is an excellent opportunity to learn more about cloud providers, networking, etc.

## Liability

This is an open source project meant to be used with authorization to analyze malware. Malware analysis can be dangerous, cloud infrastructure costs money, and MAAWS provides no guarantees of protection against malicious software or large bills. Use at your own risk.

## References

Inspired by:
* [TCM Security's Practical Malware Analysis & Triage (PMAT) course](https://academy.tcm-sec.com/p/practical-malware-analysis-triage)
* [adanalvarez's AWS-malware-lab Project](https://github.com/adanalvarez/AWS-malware-lab)
* [Tailscale](https://tailscale.com/)
  * [Tailscale AWS Routing KB](https://tailscale.com/kb/1021/install-aws)
* [FLAREVM](https://github.com/mandiant/flare-vm)
* [REMnux](https://remnux.org)
* [Terraform](https://developer.hashicorp.com/terraform/intro)
* [ChatGPT](https://chatgpt.com)
