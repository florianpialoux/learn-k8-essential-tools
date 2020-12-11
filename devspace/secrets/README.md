# Bitnami SealedSecrets

Sealed Secrets is composed of two parts:

* A cluster-side controller / operator
* A client-side utility: `kubeseal`

The `kubeseal` utility uses asymmetric crypto to encrypt secrets that only the controller can decrypt.

Upon startup, the controller looks for a cluster-wide private/public key pair, and generates a new 4096-bit RSA key pair if not found. The private key is persisted in a Secret object in the same namespace as that of the controller. The public key portion of this is made publicly available to anyone wanting to use Sealed Secrets with this cluster.

When a SealedSecret custom resource is deployed to the Kubernetes cluster, the controller will pick it up, unseal it using the private key, and create a Secret resource. During decryption, the SealedSecret’s namespace/name is used again as the input parameter. This ensures that the SealedSecret and Secret are strictly tied to the same namespace and name.

### Create a secret
To generate a secret `kubeseal`, `kubectl` are required.
Run the script called `make_multiple_secret.sh`, in the example below we set the password **toto**.
```
~/work/florian-test/devspace/secrets     ./make_multiple_secret.sh                                          
MySQL-Password:toto
MySQL-Replication-Password:toto
MySQL-Root-Password:toto
MySQL-Password-For-WP:toto
WP-Password:toto
```

This script will:
* save your inputs that you enter as password for each variables.
* `kubeseal` will communicate with the controller through the Kubernetes API server and retrieve the public key needed for encrypting a Secret which in our case contain multiple keys.
* the end result will generate a .json file that contains this sealed secret.


##### Note:
`kubeseal` interacts with the Sealed Secrets Controller and cannot be used when cluster is offline.

*bitnami/wordpress* helm chart required a key for `externalDatabase` as `mariadb-password` although MariaDB is not used for this WP deployment.

### Reference a Secret
For a `deployment.yaml`, populate with variables from `secrets/KEY.json`. A usable example is also outputted after generating a secret.

Example secret key reference to a single secret:
```
env:
- name: DB_PASSWORD
  valueFrom:
    secretKeyRef:
      name: db-password
      key: DB_PASSWORD
```

Example secret key reference to a single secret that contain multiple keys:
```
version: v1beta9
deployments:
  - name: manifests
    kubectl:
      manifests:
        - secrets
  - name: mysql
    helm:
      chart:
        name: bitnami/mysql
      values:
        auth:
          existingSecret: credentials
          database: florian-db
          username: florian
```

### To do:
- [ ] Find a way for secrets to work after a cluster wipe instead of recreating them manually.

### Useful resources
https://aws.amazon.com/blogs/opensource/managing-secrets-deployment-in-kubernetes-using-sealed-secrets/

https://github.com/bitnami-labs/sealed-secrets/blob/master/README.md#usage
