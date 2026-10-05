# Terraform AWS EKS Landing Zone Baseline

This repository provisions a production-style AWS landing zone and an Amazon EKS cluster with a baseline namespace chart for workload governance.

## Included
- VPC with public and private subnets
- NAT gateway setup
- EKS cluster with managed node group
- Kubernetes add-ons for CoreDNS, kube-proxy, and VPC CNI
- Helm chart for namespace defaults and guardrails

## Layout

```text
.
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
├── environments/
│   └── dev/
│       ├── main.tf
│       ├── variables.tf
│       ├── outputs.tf
│       ├── providers.tf
│       └── terraform.tfvars
├── eks_landing_zone_baseline_setup_guide.md
└── README.md
```

## Quick start

1. Validate the provider and Terraform installation:

```bash
terraform version
aws sts get-caller-identity
```

2. Change into the environment directory:

```bash
cd environments/dev
```

3. Initialize Terraform:

```bash
terraform init
```

4. Review the plan:

```bash
terraform plan -out=tfplan
```

5. Apply the configuration:

```bash
terraform apply tfplan
```

6. Configure kubectl:

```bash
eval $(terraform output -raw configure_kubectl)
```

7. Validate the baseline workload namespace:

```bash
kubectl get all,resourcequota,limitrange,role,rolebinding -n workload-test
```

## Teardown

terraform destroy -auto-approve
```

## Notes

This project is intentionally set up as a starting baseline for a dev landing zone. Expand the modules and policies as required for higher environments and stricter organizational governance.
