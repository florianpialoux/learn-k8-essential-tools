# Provision a GKE Cluster with terraform

This repo contains Terraform configuration files to provision a GKE Cluster on GCP in `us-west1-a` zone with 3x `g1-small` nodes.

It also creates a VPC and subnet for the GKE Cluster to keep it isolated.

**ignore the folder hello-app for now**

# Set up and initialize your Terraform workspace

In your terminal, clone this repository.
```shell
git@gitlab.com:bluelightco/testing/florian-test.git
```

Once you have cloned the repo and changed your customized variables, initialize your Terraform workspace, which will download the provider and initalize it with the values provided in your `terraform.tfvars` files.

```shell
terraform init
```
Run `terraform apply`  and review the planned actions.

```shell
terraform apply
An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

## output truncated ...

Plan: 4 to add, 0 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.
```
You can see this terraform apply will provision a VPC, subnet, GKE Cluster and a GKE node pool. If you're comfortable with this, confirm the run with a `yes`.

This process should take approximately 5 minutes.

# Configure kubectl

Run the following command to retrieve the access credentials for your cluster and automatically configure `kubectl`.

```shell
gcloud container clusters get-credentials $(terraform output kubernetes_cluster_name) --region $(terraform output region)
```
# Useful resources

Hashicorp provides documentation on how `google_container_cluster` works [here](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_cluster).

# Cleanup your workspace
Once you are done with your tests on your GKE cluster, remember to destroy any resources you create once you are done.
Run the `destroy` terraform command and confirm with `yes` in your terminal.
```shell
terraform destroy
```
