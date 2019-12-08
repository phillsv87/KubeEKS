# KubeEKS
Kubernetes scripts for running on EKS


## Local Tools
- aws cli - https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html
- eksctl - https://eksctl.io/
``` sh
brew tap weaveworks/tap
brew install weaveworks/tap/eksctl
```
- kubectl - https://kubernetes.io/docs/tasks/tools/install-kubectl/

- helm - https://docs.aws.amazon.com/eks/latest/userguide/helm.html
``` sh
# Install helm client
brew install helm
# You many need to close your current shell for helm to be visible now as the PATH env var has been updated.

# Verify helm v3 was install
helm version

# Add repos
helm repo add nginx https://helm.nginx.com/stable
helm repo update

```



## Configuration
All configurations should be stored in a file called KubeEKS.json in a parent directory to the
KubeEKS directory.
``` json
{
    "AwsProfile":"<AWS profile>",
    "ClusterRegion":"<Cluster Region>",
    "ClusterName":"<Cluster Name>"
}
```

## AWS cli
All aws cli interactions are done using the named profile set in the AwsProfile config value

see - https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-profiles.html

## Cluster Setup

### Create Cluster 
First we will create our cluster. Below is a example cluster with 2 nodes of size t3.small

``` yaml
#cluster.yml
apiVersion: eksctl.io/v1alpha5
kind: ClusterConfig

metadata:
  name: the-claw
  region: us-east-2

nodeGroups:
  - name: ng-1
    instanceType: t3.small
    desiredCapacity: 2
```

``` sh
kubectl -f cluster.yml
```


### Cluster Ingress Setup with Let's Encrypt
Next we will be setting up an ingress controller using ingress-nginx and automatic SSL certificate management using Let's Encrypt.

``` sh
# Install ingress components
./CreateIngress.ps1

# Create the cert manager
./CreateCertManager.ps1

# Create an issuer
./CreateIssuer.ps1

```
After successfuly running the above commands we will need to add a DNS CName record to point to ingress load balancer address

## Namespace Setup
Namespace setup will be done for each application set that will be deployed to your cluster

``` sh
# Create the namespace in the cluster
kubectl create namespace exns

# Make ingress yml. ../ingress-exns.yml will be created
./MakeIngress.ps1 -namespace exns
```

After running ./MakeIngress.ps1 script the ../ingress-exns.yml will be created. Modify the newly
created file to point to an app. See the App Deployment section for details about deploying an app

``` sh
# Apply the ingress file
kubectl apply -f ../ingress-exns.yml
```


## App Deployment
Application deployment is handled using the Deploy.ps1 script.

``` sh
./Deploy.ps1 -name "<app name>" -dockerFile "<path/to/docker/file>"  -version "<image version>" -noSignIn
```

Deploy.ps1 will build an image using the provided Dockerfile and push the image to the projects configured ECR.

## Certificate Creation
Creating SSL certificates is handled using the MakeCert.ps1 script

``` sh
# Create a certificate yml file
./MakeCert.ps1 -domain api.example.com -namespace exns

# Apply the certificate to the cluster
kubectl apply -f ../cert-exns-api-example-com.yml
```

Once the certificate has been applied to the cluster it can be used in an ingress controller.

``` yml
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: ingress-exns
  namespace: exns
  annotations:
    kubernetes.io/ingress.class: "nginx"
spec:
  tls:
  
  - hosts:
    - frontend.example.com
    secretName: cert-frontend-example-com

# Insert tls host
  - hosts:
    - api.example.com
    secretName: cert-api-example-com
# End Insert

  rules:

  - host: frontend.example.com
    http:
      paths:
      - backend:
          serviceName: frontend
          servicePort: 80
        path: /

# Insert host
  - host: api.example.com
    http:
      paths:
      - backend:
          serviceName: api
          servicePort: 80
        path: /
# End Insert

```

## Helpful Links
Using a Network Load Balancer with the NGINX Ingress Controller on Amazon EKS - 
https://aws.amazon.com/blogs/opensource/network-load-balancer-nginx-ingress-controller-eks/