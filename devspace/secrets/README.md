# Bitnami SealedSecrets

Sealed Secrets is composed of two parts:

* A cluster-side controller / operator
* A client-side utility: `kubeseal`

The `kubeseal` utility uses asymmetric crypto to encrypt secrets that only the controller can decrypt.

### Create a secret
To generate a secret `kubeseal`, `kubectl`, and `make` are required. In the root of the project type `make secret` and follow the prompts to generate.
```
$ make secret
CLIENT: client1
KEY: DB_PASSWORD
VALUE: xxxxxx
```

### Reference a Secret
For a `deployment.yaml`, populate with variables from `secrets/KEY.json`. A usable example is also outputted after generating a secret.
```
Example secret key reference:
env:
- name: DB_PASSWORD
  valueFrom:
    secretKeyRef:
      name: db-password
      key: DB_PASSWORD
```

### Useful resources
https://aws.amazon.com/blogs/opensource/managing-secrets-deployment-in-kubernetes-using-sealed-secrets/

https://github.com/bitnami-labs/sealed-secrets/blob/master/README.md#usage
