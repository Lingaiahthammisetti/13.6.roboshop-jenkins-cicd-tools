https://github.com/Lingaiahthammisetti/13.6.roboshop-jenkins-cicd-tools.git

terraform init -reconfigure
terraform plan
terraform apply -auto-approve
terraform destroy -auto-approve

login into Jenkins master and install these plugins

Install below plugins when you started Jenkins.

Plugins:

Pipeline stage view
Pipeline Utility Steps
AWS Credentials
AWS Steps
Rebuild
Ansi Color
Sonarqube Scanner
Restart Jenkins once plugins are installed


Go to credentials --> add credentials
ssh-auth:  user:ec2-user, password:DevOps321

AWS-Cred:  
access key
Secret Access key

configure Jenkins agent on Jenkins master as AGENT-1

Configure Jenkins Shared Libraries
Go to Manage Jenkins -> System
Find Global Trusted Pipeline Libraries section
Name as jenkins-shared-library, default version main and mark the load implicitly
Location is https://github.com/Lingaiahthammisetti/13.5.jenkins-shared-library-roboshop.git

Configure shared library:
Manage Jenkins--> System

https://github.com/Lingaiahthammisetti/13.7.roboshop-infra-dev.git


for i in 00-vpc/ 10-sg/ 20-bastion/ 30-rds/ 40-eks/ 50-acm/ 60-alb/ 70-ecr/ 80-cdn/ ; do cd $i; terraform init -reconfigure; cd .. ; done

for i in 00-vpc/ 10-sg/ 20-bastion/ 30-rds/ 40-eks/ 50-acm/ 60-alb/ 70-ecr/ 80-cdn/ ; do cd $i; terraform plan; cd .. ; done

for i in 00-vpc/ 10-sg/ 20-bastion/ 30-rds/ 40-eks/ 50-acm/ 60-alb/ 70-ecr/ 80-cdn/ ; do cd $i; terraform apply -auto-approve; cd .. ; done

for i in 80-cdn/ 70-ecr/ 60-alb/ 50-acm/ 40-eks/ 30-rds/ 20-bastion/ 10-sg/ 00-vpc/ ; do cd $i; terraform destroy -auto-approve; cd .. ; done

Login into Bastion Server and then configure MySQL.

We will run below commands on ec2-instance.

mysql -h roboshop-dev.cm9mcies2otg.us-east-1.rds.amazonaws.com -u root -pRoboShop1


mysql -h roboshop-dev.cm9mcies2otg.us-east-1.rds.amazonaws.com -u root -pRoboShop1 < 13.17.roboshop-shipping-CI/db/schema.sql

mysql -h roboshop-dev.cm9mcies2otg.us-east-1.rds.amazonaws.com -u root -pRoboShop1 < 13.17.roboshop-shipping-CI/db/app-user.sql

mysql -h roboshop-dev.cm9mcies2otg.us-east-1.rds.amazonaws.com -u root -pRoboShop1 < 13.17.roboshop-shipping-CI/db/master-data.sql


Make sure to follow below steps for Target group binding and Ingress Controller

Target group binding
If we are running frontend using normal user it can't bind the port 80. non root privelege user running container are not able to open system ports which are under 1024.
So we have to use port no 8080 for frontend. Make sure
nginx.conf opens port no 8080 instead of 80.
ALB target group health check port should be 8080.
frontend service target port should be 8080 instead of 80.


Configuring Ingress Controller on bastion server.
aws configure

aws eks update-kubeconfig --region us-east-1 --name roboshop-dev
kubectl get nodes
kubectl create namespace roboshop



Ingress Controller
Login to bastion host and get the kubeconfig of EKS cluster
aws configure
aws eks update-kubeconfig --region us-east-1 --name roboshop-dev
kubectl get nodes

Create namespace roboshop
kubectl create namespace roboshop

IAM policy
curl -o iam-policy.json https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.10.0/docs/install/iam_policy.json

IAM Role created
aws iam create-policy \
    --policy-name AWSLoadBalancerControllerIAMPolicy \
    --policy-document file://iam-policy.json

Create Service account. Replace your account ID.
eksctl create iamserviceaccount \
--cluster=roboshop-dev \
--namespace=kube-system \
--name=aws-load-balancer-controller \
--attach-policy-arn=arn:aws:iam::484907532817:policy/AWSLoadBalancerControllerIAMPolicy \
--override-existing-serviceaccounts \
--region us-east-1 \
--approve

Install aws load balancer controller drivers through helm.
helm repo add eks https://aws.github.io/eks-charts
helm install aws-load-balancer-controller eks/aws-load-balancer-controller -n kube-system --set clusterName=roboshop-dev --set serviceAccount.create=true --set serviceAccount.name=aws-load-balancer-controller

Make sure load balancer pods are running
kubectl get pods -n kube-system





Note: We usually do not create pipelines for Databases like MySQL, redis, mongodb, RabbitMQ. Database team will maintain these servers and provide access to devops team.

pipeline project vs multi-branch pipeline

MySQL created in infra and configured in bastion server
mongodb -> we didn't create pipeline for it. We configured in bastion server
Redis image is pulled from internet as a open source image.
RabbitMQ image is pulled from internet as a open source image.


We have created and used the Jenkins shared library for API servers (Catalogue, Cart, User, Shipping, Payment)

Catatlogue-ci is multi-branch pipeline, because it is development
catalogue-cd is a normal pipeline project because used for only deployment.

Cart-ci is multi-branch pipeline, because it is development
cart-cd is a normal pipeline project because used for only deployment.

user-ci is multi-branch pipeline, because it is development
user-cd is a normal pipeline project because used for only deployment.


shipping-ci is multi-branch pipeline, because it is development
shipping-cd is a normal pipeline project because used for only deployment.

payment-ci is multi-branch pipeline, because it is development
payment-cd is a normal pipeline project because used for only deployment.

roboshop-frontend is a normal pipeline project


https://github.com/Lingaiahthammisetti/13.8.roboshop-mongodb.git

git clone https://github.com/Lingaiahthammisetti/13.8.roboshop-mongodb.git
cd 13.8.roboshop-mongodb
Login to ECR
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 484907532817.dkr.ecr.us-east-1.amazonaws.com
Build MongoDB image.
docker build -t 484907532817.dkr.ecr.us-east-1.amazonaws.com/roboshop/dev/mongodb:v1.0.2 .
Push image
docker push 484907532817.dkr.ecr.us-east-1.amazonaws.com/roboshop/dev/mongodb:v1.0.2
Now install using Helm. move to helm directory
cd helm
helm upgrade --install mongodb . -n roboshop


https://github.com/Lingaiahthammisetti/13.9.roboshop-redis.git
git clone https://github.com/Lingaiahthammisetti/13.9.roboshop-redis.git
cd 13.9.roboshop-redis/
helm upgrade --install redis . -n roboshop
kubectl get pods -n roboshop



https://github.com/Lingaiahthammisetti/13.10.roboshop-rabbitmq.git
git clone https://github.com/Lingaiahthammisetti/13.10.roboshop-rabbitmq.git
cd 13.10.roboshop-rabbitmq
helm upgrade --install rabbitmq . -n roboshop
kubectl get pods -n roboshop

13.11.roboshop-catalogue-CI
13.12.roboshop-catalogue-CD
13.13.roboshop-user-CI
13.14.roboshop-user-CD
13.15.roboshop-cart-CI
13.16.roboshop-cart-CD
13.15.roboshop-shipping-CI
13.16.roboshop-shipping-CD
13.15.roboshop-payment-CI
13.16.roboshop-payment-CD
13.15.roboshop-frontend