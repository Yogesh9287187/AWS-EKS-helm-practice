# Terraform AWS EKS Landing Zone Baseline

This repository provisions an AWS VPC and an Amazon EKS cluster with a baseline namespace chart for workload governance.

## Included
- VPC with public subnets
- EKS cluster with managed node group
- Kubernetes add-ons for CoreDNS, kube-proxy, and VPC CNI
- Helm chart for namespace defaults and guardrails

## Layout

```text
.
├── .github/
│   └── workflows/
│       └── terraform.yml
├── charts/
│   └── namespace-baseline/
│       ├── Chart.yaml
│       ├── values.yaml
│       └── templates/
│           ├── _helpers.tpl
│           ├── namespace.yaml
│           ├── resourcequota.yaml
│           ├── limitrange.yaml
│           ├── rbac.yaml
│           ├── networkpolicy.yaml
│           └── hpa-template.yaml
├── main.tf
├── outputs.tf
├── providers.tf
├── variables.tf
└── README.md
```

## GitHub Actions CI/CD

The workflow in [`.github/workflows/terraform.yml`](.github/workflows/terraform.yml) runs Terraform from the repository root and uses the Terraform Cloud workspace configured in `providers.tf`.

### One-time setup

1. In Terraform Cloud, confirm the organization and workspace names match `providers.tf`, and configure the workspace for remote execution.

2. Add AWS credentials to the Terraform Cloud workspace as environment variables, not GitHub secrets. For access keys, add `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` as sensitive variables. Set `AWS_DEFAULT_REGION` if needed; Terraform's `aws_region` variable defaults to `us-east-1`.

3. Create a Terraform Cloud API token with access to the workspace. In GitHub, add it as an Actions secret named `TF_API_TOKEN` at the repository or organization level.

4. Confirm AWS authentication works in the Terraform Cloud run environment. The current provider configuration sets `aws_profile` to `admin` and passes that profile to `aws eks get-token`; adjust the profile configuration if that profile is not available to remote runs.

### Workflow behavior

- Pull requests run `terraform init` and `terraform plan`; they do not apply changes.
- Pushes to `main` run `terraform init`, `terraform plan`, and `terraform apply -auto-approve`.
- The GitHub Actions run triggers Terraform Cloud remote execution. AWS workspace variables are available to the Terraform Cloud run, not downloaded into the GitHub runner.
- GitHub does not provide repository secrets to workflows triggered by pull requests from forks, so those plan runs cannot authenticate to Terraform Cloud unless a separate trusted workflow is configured.

Protect `main` with required reviews and restrict who can push to it: a push to `main` applies infrastructure automatically without a separate GitHub approval step.

## Local quick start

Run these commands from the repository root. Terraform uses the Terraform Cloud workspace configured in `providers.tf`.

```bash
terraform version
terraform init
terraform plan
terraform apply -auto-approve
```

After the apply completes, configure kubectl:

```bash
eval $(terraform output -raw configure_kubectl)
```

Validate the baseline workload namespace:

```bash
kubectl get all,resourcequota,limitrange,role,rolebinding -n workload-test
```

## Teardown

```bash
terraform destroy -auto-approve
```

## Notes

This project is intentionally set up as a starting baseline for a dev landing zone. Expand the modules and policies as required for higher environments and stricter organizational governance.
