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

**Deploy your project**
```shell
devspace deploy -p production
```

This command above will build and deploy your application from your devspace.yaml directly on your k8 cluster.

`devspace.yaml` will run the following applications on your k8 cluster: **MySQL, Nginx, WordPress and Sealed Secrets.**

# Build/Push/Deploy docker images to GKE Cluster

#### Dockerfile
Will copy content from `apache_test/public-html` to `/usr/local/apache2/htdocs/`

L3-L9 on `devspace.yaml`  will build and push the docker image apache2 on a GCR repo linked to my project ID from GCP.
Once it's done performing the steps mentioned above, it will run a deployment on our GKE Cluster L76-L88.
# Network

To understand the end goal with that deployment:
* WP is able to connect to MySQL through the dns name`mysql.testing.svc.cluster.local`
* Nginx is the ingress controler for this k8 cluster.
* External-DNS is linked with Cloudflare DNS which auto create C Name for names mentioned in `.k8s\external-dns.yaml` and an A Record for Nginx due to the annotations on L39-40 `devspace.yaml`

```shell
kubectl get services

NAME                                             TYPE           CLUSTER-IP     EXTERNAL-IP      PORT(S)                      AGE
apache2-custom                                   ClusterIP      10.3.252.94    <none>           80/TCP                       8m48s
external-dns                                     ClusterIP      10.3.240.73    <none>           7979/TCP                     8m56s
external-dns-wordpress                           ExternalName   <none>         nginx.qaz.to     <none>                       8m58s
mysql                                            ClusterIP      10.3.254.242   <none>           3306/TCP                     8m51s
mysql-headless                                   ClusterIP      None           <none>           3306/TCP                     8m51s
nginx-nginx-ingress-controller                   LoadBalancer   10.3.253.146   35.197.117.190   80:31484/TCP,443:30094/TCP   8m53s
nginx-nginx-ingress-controller-default-backend   ClusterIP      10.3.252.255   <none>           80/TCP                       8m53s
wordpress                                        ClusterIP      10.3.242.69    <none>           80/TCP,443/TCP               8m49s
```
```shell
kubectl get ingress

NAME             HOSTS              ADDRESS       PORTS   AGE
apache2-custom   apache2.qaz.to     35.247.8.52   80      9m18s
wordpress        wordpress.qaz.to   35.247.8.52   80      9m20s
```

# Useful resources

Hashicorp provides documentation on how `google_container_cluster` resource for Terraform works [here](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_cluster).

Helm charts for [MySQL](https://artifacthub.io/packages/helm/bitnami/mysql) and [WordPress](https://artifacthub.io/packages/helm/bitnami/wordpress).

# Cleanup your workspace
Once you are done with your tests on your GKE cluster, remember to destroy any resources you create once you are done.
Run the `destroy` terraform command and confirm with `yes` in your terminal.
```shell
cd /tf
terraform destroy
```
