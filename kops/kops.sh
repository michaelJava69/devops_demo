#!/bin/bash
 
install_kops () {
    kops create cluster \
     --name=kops.azuka.tk \
     --state=s3://kops.helm.devopsinuse.com \
     --authorization RBAC \
     --zones=eu-central-1a \
     --node-count=2 \
     --node-size=t2.micro \
     --master-size=t2.micro \
     --master-count=1 \
     --dns-zone=kops.azuka.tk \
     --out=azuka_helm_terraform \
     --target=terraform \
     --ssh-public-key=/var/lib/jenkins/.ssh/udemy_devopsinuse.pub
 
}

install_kops
