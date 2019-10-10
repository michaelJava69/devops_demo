# DevOps Demo

DevOps Demo is a demonstration of a simple CI/CD Pipeline.

Tools such as Github, Ansible, Docker Hub,Docker , Kubernetes/Kops, Maven, Terraform and Jenkins and AWS Cloud's EC2 instances,
AWS : S3 buckets and Route 53.

## What will happen

```bash
1. Jenkins job 1 will create an AWS kubernetes master2 and 2 nodes using KOPs and Terraform with one click of a button : duration 4 mins: wait time 5 mins 
2. Jenkins Job 2 (vcs triggered) will compile/test and deploy a war file to a stage location
   Push create a modified Tomcat docker container from the war file
   Push the modified container to Docker Hub
   Pull the modified container from Docker hub and deploy onto a AWS Docker Container
   Pull the modified container from Docker hub and deploy onto the AWS Kubernetes cluster.
   
3. Jenkins kobs are declarative and stored in Github

```
## Preparation

### Pre-requisites
1. Oracle VM box
2. Jenkins server
3. Ansible

### Main installation

1. Install Oracle VM : I chose an ubuntu environment: This will Jenkins, Ansible, Kubectl.
   
2. Create User and S3 bucket for Kops
     ```bash
	- set up dns: Can use freedomanin website (https://my.freenom.com/) [Domain name =azuka.tk]
	- create hosted zone in AWS and put the NS into your hosted DNS
	- create a user and download her  SSH KEYS, associate her with IAM full admin credentials 
	- create S3 bucket in AWS
	- DOWNLOAD users SSH KEYS for kops   : I chose Oracle VM I will take you from scratchSetup from scratch will be outlined for Jenkins and Kubernetes Kubectl and AWSCLIUse the package manager [pip](https://pip.pypa.io/en/stable/) to install foobar.
     ```
3. Install utility tools     
     ```bash
        - sudo apt-get install python2-pip
        - sudo apt-get install python3-pip
        - sudo pip install awscli
        - sudo pip3 install awscli
     
4  Create new IAM user
     ```bash
        - create group with full admin access
        - generate access/key from user in AWS. associate
        - security group addmin to user and you will be given a url for user to log onto console with
        #User will be asked to change password on first access
         Download the key file 
     
           copy past key into credentials
          ./aws/credentials
          ./aws/config
  
        - Make AWS aware of the screte details : 
          aws iam get-user
     ```
 5 Install Kops and Terraform
    ```bash
      https://github.com/kubernetes/kops
     
      curl -LO https://github.com/kubernetes/kops/releases/download/$(curl -s https://api.github.com/repos/kubernetes/kops/releases/latest | grep tag_name | cut -d '"' -f 4)/kops-linux-amd64
      chmod +x kops-linux-amd64
      sudo mv kops-linux-amd64 /usr/local/bin/kops
  
      https://kubernetes.io/docs/tasks/tools/install-kubectl/#install-kubectl-on-linux
      curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl
      chmod +x ./kubectl
      sudo mv ./kubectl /usr/local/bin/kubectl
      kubectl version
    ``` 
  6 Install Terraform
  ```bash
     - https://www.terraform.io/
     - wget https://releases.hashicorp.com/terraform/0.12.9/terraform_0.12.9_linux_amd64.zip
     - unzip terraform_0.12.9_linux_amd64.zip 
     whereis kops
     - kops: /usr/local/bin/kops
     - sudo mv terraform /usr/local/bin/terraform
  ```
  7 Install Kubectl
  ```bash
     - https://kubernetes.io/docs/tasks/tools/install-kubectl/#install-kubectl-on-linux
     - curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl
     - chmod +x ./kubectl
     - sudo mv ./kubectl /usr/local/bin/kubectl
     - kubectl version
  ``` 
    
## Setting up the Jenkins job
  Job 1 :
  ```bash
     This really executes the powerful Kops script that declaratively maos the whole AWS kunbernetes environment
     kops create cluster \
       --name=kops.azuka.tk \                  	1. the name of the cluster, the top level and second level names makeup last part
       --state=s3://kops.helm.azuka.tk \	2. the is the name of your s3 bucket which stores the cluster configurations that Terraform uses 
       --authorization RBAC \                   3. Role based access control :restricts system access to authorized users. I tlinks in with AWS IAM
       --zones=eu-central-1a \			4. The zone in which the cluster would resides
       --node-count=2 \				5. Node count
       --node-size=t2.micro \			6. Node EC2 type/size
       --master-size=t2.micro      \		7. Master EC2 type/size
       --master-count=1 \			8. Number of Master nodes
       --dns-zone=kops.azuka.tk \		9. DNS name :the matches your DNS host
       --out=azuka_helm_terraform  \		10. directory for auto genearated Terraform file
       --target=terraform \			11. Name of terraform file
         --ssh-public-key=~/.ssh/devops_demo.pub 12. address of the SSH keys that Terraform will use to configure the RBAC
   
       The Jenkins job will run this script then automatically execute the Terraform script to build the cluster.
  ``` 
  Job 2
  ```bash
       This job will take over and build the application fro source . In this case it is a Java Web application that will be deployed on Tomcat
       The maven step will generate the war which is picked up by ansible and transformed into a Docker image. This image is pushed to Docker hub.
       The image is then pulled from Docker hub and deployed onto a Docker container and /or the Kubernetes cluster
       From here on Kubernetes takes care of scaling and replication
     
  ``` 
 
##
  Note
  ```bash
      All code for application and infrastructure is stored in Github and with minimal setup will run on any Jenkins CI.
      Both infra and application code is sourced together
      Ansible and Jenkins are hosted on prem whilst Docker Contsainer and Kubernetes are hosted on AWS. AWS S3 bucket version manages the Kops cluster code.
      
  ```
## License
 