# KubeEKS
Kubernetes scripts for running on EKS


## tools
- aws cli - https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html
- eksctl - https://eksctl.io/
``` bash
brew tap weaveworks/tap
brew install weaveworks/tap/eksctl
```
- kubectl - https://kubernetes.io/docs/tasks/tools/install-kubectl/


## Configuration
All configurations should be stored in a file called config.sh in a parent directory to the
KubeEKS directory.

### Example config.sh
``` sh
# Name AWS Profile name used for interacting with the aws cli.
AWS_PROFILE=<profileName>
```

## AWS cli
All aws cli interactions are do using Named Profiles.

see - https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-profiles.html