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
    "AdminEmail":"<Cluster admin email address>",
    "AwsProfile":"<AWS profile>",
    "IamInstanceProfileId":"<InstanceProfileId of iam profile>",
    "IamInstanceProfileName":"<InstanceProfileName of iam profile>",
    "ClusterRegion":"<Cluster Region>",
    "ClusterName":"<Cluster Name>",
    "ContainerRegistry":"<URL to container register>"
}
```
### Configuration Properties
- IamInstanceProfileId - Run "aws iam list-instance-profiles" to list profiles

## AWS cli
All aws cli interactions are done using the named profile set in the AwsProfile config value

see - https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-profiles.html


## Create Cluster 
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

## Persistent Storage Setup
Persistent storage is backed by 1 of 3 different AWS storage types EBS, EFS and S3. In most cases
EBS will be used and is the type of storage used by cluster nodes for their OS. EBS presents a 
challenge when mounting to our Deployments, EBS volumes can only be access from a single 
Availability Zone and Deployments can be created in any Availability Zone within their Region.
To overcome this limitation we will setup the EBS CSI driver. The InstallCSIDriver.ps1 script 
will create the nessasary iam profiles and install the aws-ebs-csi-driver driver into the
kube-system namespace. It is safe to run InstallCSIDriver.ps1 multiple times, all resources are
check for before being created.

``` sh
./InstallCSIDriver.ps1
```

see for more info - https://aws.amazon.com/blogs/opensource/eks-support-ebs-csi-driver/


## Cluster Ingress Setup with Let's Encrypt
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

# Make any needed changes to ../ingress-exns.yml then apply
kubectl apply -f ../ingress-exns.yml
```

After running ./MakeIngress.ps1 script the ../ingress-exns.yml will be created. Modify the newly
created file to point to an app. See the App Deployment section for details about deploying an app

``` sh
# Apply the ingress file
kubectl apply -f ../ingress-exns.yml
```


## App Deployment

1. Create an ECR repo for the app. Each time the app is build a new image will be created app pushed
to the repo. This step is only done once per app. (note. Use an app name that is unique across all namespaces)
``` sh
./CreateContainerRepo.ps1 -name "<full app name>"
```

2. Build and deploy the image for the app. BuildImage.ps1 will build an image using the provided
Dockerfile and push the image to the projects configured ECR.
``` sh
./BuildImage.ps1 -name "<full app name>" -dockerFile "<path/to/docker/file>"  -version "<image version>"
```

3. Create App YAML - todo
``` sh
# Create app yml
./MakeWebApp.ps1 -namespace "<namespace>" -appName "<app name>" -imageName "<full app name>"

# apply
kubectl apply -f "../app-<namespace>-<app name>.yml"
```

3. Make Cert
``` sh
# Create cert yml
./MakeCert.ps1 -domain "<domain name>" -namespace "<namespace>"

# apply
kubectl apply -f "../cert-<namespace>-<domain name>.yml"
```

4. Add to Ingress - see "Inserting App Into Ingress" and apply



## Certificate Creation
Creating SSL certificates is handled using the MakeCert.ps1 script

``` sh
# Create a certificate yml file
./MakeCert.ps1 -domain api.example.com -namespace exns

# Apply the certificate to the cluster
kubectl apply -f ../cert-exns-api-example-com.yml
```

Once the certificate has been applied to the cluster it can be used in an ingress controller.

### Inserting App Into Ingress
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

## Creating Storage Volume
Before creating a storage volume before you have followed the "Persistent Storage Setup" section.
There are 2 steps for creating a Storage volume, Create a storage class and creating the volume its self.

1. Create Storage Class (this only needs to be done once per namespace). Actually, I think StoreClass spans multiple namespaces
``` sh
./MakeStorageClass.ps1 -namespace "<namespace>" -name "<name>" -type "<gp2(default), io1, st1 or sc1>"
kubectl apply -f "../storage-class-<namespace>-<name>.yml"
```

2. Create Volume Claim
``` sh
./MakeVolume.ps1 -namespace "<exns>" -name "<name>" -sizeGb 10 -storageClass "<storage class>"
kubectl apply -f ../volume-<namespace>-<name>.yml
```

3. Mount Volume
``` yaml
# Example of volume used with MySQL Deployment
apiVersion: v1
kind: Service
metadata:
  name: sql
  namespace: exns
spec:
  selector:
    app: sql
  ports:
  - port: 3306

---

apiVersion: apps/v1
kind: Deployment
metadata:
  name: sql
  namespace: exns
  labels:
    app: sql
spec:
  replicas: 1
  selector:
    matchLabels:
      app: sql
  template:
    metadata:
      labels:
        app: sql
    spec:
      containers:
      - name: sql
        image: mysql:8.0.13

# Add volumeMounts
        volumeMounts:
        - mountPath: /var/lib/mysql
          name: data-volume

# Add volume
      volumes:
      - name: data-volume
        persistentVolumeClaim:
          claimName: volume-<name used with MakeVolume.ps1>


```

## Continuous Deployment

### Steps
- Create AWS profile for use by CircleCI

``` text
# Add to ~/.aws/config
[profile ciguy]
region = <default region. example - us-east-2>
output = json
```

``` text
# Add to ~/.aws/credentials
[ciguy]
aws_access_key_id = <key id>
aws_secret_access_key = <secret access key>
```

- Configure CircleCI context with AWS vars
  - https://circleci.com/orbs/registry/orb/circleci/aws-ecr

- Add CircleCI config
``` yaml
version: 2.1

# filter based on branch name. This is optional and can be removed
deploy-status: &deploy-status
  filters:
    branches:
      only:
        - deploy-status

orbs:
  aws-ecr: circleci/aws-ecr@6.5.0

workflows:
  build_and_push_image:
    jobs:
      - aws-ecr/build-and-push-image:
          # The line below adds the filter to the job and can be removed
          <<: *deploy-status
          context: TheClaw
          create-repo: true
          dockerfile: ./apps/status/Dockerfile
          path: ./apps/status
          profile-name: ciguy
          repo: web-status
          tag: 'latest'
```

- Setup Keel. Keel automatically pulls the latest version of images for deployments
``` sh
# To override default latest semver tag, add &tag=x.x.x query argument to the URL below
kubectl apply -f https://sunstone.dev/keel?namespace=keel&username=admin&password=admin&tag=latest

# Check the status of the pods in the keel namespace
kubectl -n keel get pods

# Add aws iam policy to aws profile needed by Keel
./AddKeelPolicy.ps1

```

Add configuration to Deployment YAML

``` yaml

apiVersion: apps/v1
kind: Deployment
metadata:
  name: status
  namespace: web
  labels:
    app: status

# Insert Keel Annotations
  annotations:
      keel.sh/policy: force
      keel.sh/trigger: poll
      keel.sh/pollSchedule: "@every 1m"
#end

spec:
  replicas: 1
  selector:
    matchLabels:
      app: status
  template:
    metadata:
  
# Insert IAM role so keel can pull images. Use GetRoleArn.ps1 to get arn value
      annotations:
        iam.amazonaws.com/role: arn:aws:iam::123456789012:role/me-long-role-name
# end

      labels:
        app: status
    spec:
      containers:
      - name: status
        image: 123456789012.dkr.ecr.us-east-2.amazonaws.com/me-image-name:latest

# Insert pull policy
        imagePullPolicy: Always
# end

        env:
        - name: SOME_VAR
          value: "some value"
        ports:
        - containerPort: 80


```


## Helpful Links
Using a Network Load Balancer with the NGINX Ingress Controller on Amazon EKS - 
https://aws.amazon.com/blogs/opensource/network-load-balancer-nginx-ingress-controller-eks/