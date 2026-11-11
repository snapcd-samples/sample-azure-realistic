# sample-app

Deploys `sample-app` (source in `app/` at the repo root) into the tenancy's Kubernetes namespace, as a Deployment and a ClusterIP Service. It has no ingress. To reach it:

```bash
kubectl -n app port-forward service/sample-app 8080:80
```

Then open `http://localhost:8080`.

The Module signs in to the cluster as the app Runner's workload identity, and can manage only the resource kinds that the platform's Role allows in the tenancy's namespace.

The pod runs as the `sample-app` ServiceAccount, federated with the managed identity from `sample_app_infra`, and reaches Azure SQL and Key Vault with that identity. No secrets are passed to the pod.
