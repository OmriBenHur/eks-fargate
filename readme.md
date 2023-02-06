#  API movie poster application, deployed on EKS Fargate running on terraform cloud
> search for movie posters using the TMDB API, running on containerized python flask


## ⚠️ requirements    
 ### 1. sign up to [tmdb.com](https://www.themoviedb.org/) 
and create an api key under profile settings.
 ### 2. have an acm certificate for your domain name & validate it.
 - [create acm certificate](https://docs.aws.amazon.com/acm/latest/userguide/gs-acm-request-public.html)
 - [validate dns certificate](https://docs.aws.amazon.com/acm/latest/userguide/dns-validation.html)
 ### 3. have a terraform cloud account with organization and workspace configured.
 [you can refer to this page for any info about terraform cloud](https://developer.hashicorp.com/terraform/tutorials/cloud-get-started)


# ⚙️ Installation

### 1. configure the providers.tf file with your relevant organization name and workspace
```yaml
terraform {
  cloud {
    organization = <your organization>

    workspaces {
      name = <your workspace>
    }
  }

```
   
### 2. login to your terraform cloud account from your cli
 [log in to terraform cloud](https://developer.hashicorp.com/terraform/tutorials/cloud-get-started/cloud-login)

### 3. refer to the [var.tf](https://github.com/OmriBenHur/eks-fargate/blob/main/terraform/var.tf) file for any custom configuration

### 4. in the [k8s/poster-app](https://github.com/OmriBenHur/eks-fargate/tree/main/k8s/poster-app) directory, update the values of:
- app-secret.yaml - api-key (your previously created TMDB api key, b64 encoded)
- ingress.yaml - alb.ingress.kubernetes.io/certificate-arn (your acm certificate arn)
- ingress.yaml - host (your hostname that you created the certificate for)
- efs-volume.yaml - in PersistentVolume-volumeHandle (your efs id)

### 5. in the command line, enter the kubectl update config command that was outputted by terraform

### 6. cd into [k8s/poster-app](https://github.com/OmriBenHur/eks-fargate/tree/main/k8s/poster-app) and apply the k8s files.
i.
```commandline
kubectl apply -f .\namespace.yaml -f .\mongo-secret.yaml -f .\app-secret.yaml -f .\mongodb-deployment.yaml -f .\app-deployment.yaml  -f .\pod-auto-scaler.yaml -f .\efs-volume.yaml -f .\ingress.yaml 
```
ii.

make sure the load-balancer reconciles correctly after the apply of the ingress file

```commandline
kubectl logs -n kube-system -f -l app.kubernetes.io/name=aws-load-balancer-controller
```
iii.

now get the load-balancer dns corresponding to the ingress, copy the value under address

```commandline
kubectl get ing -n staging 
```

iv.

 in the domain hosting service that hosts your domain.
add a CNAME record with your subdomain as the CNAME and the load-balancer dns name(the one that you copied from the ingress.) as the value.


# that's it. 	🎊
### you can now search you domain name, and it will have https configured.
### happy searching 😄 