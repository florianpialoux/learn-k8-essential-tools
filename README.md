# Provision a GKE Cluster with terraform

This repo contains Terraform configuration files to provision a GKE Cluster on GCP in `us-west1-a` zone with 3x `g1-small` nodes.

It also creates a VPC and subnet for the GKE Cluster to keep it isolated.

**ignore the folder hello-app for now**

# Set up and initialize your Terraform workspace

In your terminal, clone this repository.
```shell
git@gitlab.com:bluelightco/testing/florian-test.git
```

- `main.tf` provisions a GKE cluster and a seperate managed node pool.

- `vpc.tf` provisions a VPC and subnet. The file outputs `region`

- `terraform.tfvars` is a template for variables.

- `versions.tf` sets the Terraform version to at least 0.12.

Once you have cloned the repo and changed your customized variables, initialize your Terraform workspace, which will download the provider and initialize it with the values provided in your `terraform.tfvars` files.


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
gcloud container clusters get-credentials $(terraform output kubernetes_cluster_name) --zone $(terraform output zone)
```

# Get started with DevSpace
**Install DevSpace CLI**
```shell
curl -s -L "https://github.com/devspace-cloud/devspace/releases/latest" | sed -nE 's!.*"([^"]*devspace-linux-amd64)".*!https://github.com\1!p' | xargs -n 1 curl -L -o devspace && chmod +x devspace;

sudo install devspace /usr/local/bin;
```

Move to devspace folder

```shell
cd /florian-test/devspace
```
**Prepare Kube-Context**

To develop and deploy your project with DevSpace, you need a valid kube-context because DevSpace uses the kube-config file just like kubectl or helm.
```shell
devspace use namespace testing
```

**Run the development mode**
```shell
devspace dev
```

This command above will build and deploy your application from your devspace.yaml directly on your k8 cluster.

`devspace.yaml` will run the following applications on your k8 cluster: **MySQL, Nginx and WordPress.**

# Network

To understand the end goal with that deployment:
* A static clusterIP has been set for MySQL so WordPress knows how to connect to it.
* Nginx is the ingress controler for this k8 cluster.
* An A Record for **wordpress.qaz.to** on an external DNS server has been set with the Ingress Controller *External-IP* which is the IP generated by GCP to create the LoadBalancer.

```shell
kubectl get services
NAME                                             TYPE           CLUSTER-IP     EXTERNAL-IP      PORT(S)                      AGE
mysql                                            ClusterIP      10.3.253.92    <none>           3306/TCP                     3h34m
nginx-nginx-ingress-controller                   LoadBalancer   10.3.252.198   104.196.231.91   80:31744/TCP,443:31840/TCP   3h34m
nginx-nginx-ingress-controller-default-backend   ClusterIP      10.3.248.157   <none>           80/TCP                       3h34m
wordpress                                        ClusterIP      10.3.245.74    <none>           80/TCP,443/TCP               43m
```
```shell
kgi
NAME        HOSTS              ADDRESS         PORTS   AGE
wordpress   wordpress.qaz.to   35.233.142.11   80      47m
```

# Useful resources

Hashicorp provides documentation on how `google_container_cluster` resource for Terraform works [here](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_cluster).

Helm charts for [MySQL](https://artifacthub.io/packages/helm/bitnami/mysql) and [WordPress](https://artifacthub.io/packages/helm/bitnami/wordpress).

# Cleanup your workspace
Once you are done with your tests on your GKE cluster, remember to destroy any resources you create once you are done.
Run the `destroy` terraform command and confirm with `yes` in your terminal.
```shell
terraform destroy
```
