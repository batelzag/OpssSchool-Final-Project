# OpsSchool Final Project
<div id="top"></div>

:elephant: [Related Repository - Kandula App][Kandula-App]

<br />
<div align="center">
  <a href="https://github.com/batelzag/OpssSchool-Final-Project">

 ![Dumbo](/assets/d4c22a8b5f806a7a4cf3742ae6d3639e.gif)  

<h3 align="center">OpsSchool Final Project</h3>

  <p align="center">
    <a href="https://github.com/batelzag/OpssSchool-Final-Project"><strong>Explore the files »</strong></a>
    <br />
    <br />
  </p>
</div>

<!-- TABLE OF CONTENTS -->
<details>
  <summary>Table of Contents</summary>
  <ol>
    <li>
      <a href="#about-the-project">About The Project</a>
      <ul>
      </ul>
    </li>
    <li>
      <a href="#prerequisites">Prerequisites</a>
      <ul>
      </ul>
    </li>
    <li>
      <a href="#usage">Usage</a></li>
      <ul>
      </ul>
    </li>
    <li>
      <a href="#variables">Variables</a>
      <ul>
      </ul>
    </li>
  </ol>
</details>

<!-- ABOUT THE PROJECT -->
## About The Project
A small production environment for a highly available web application <a href="https://learn.hashicorp.com/tutorials/terraform/install-cli">(Kandula)</a> on AWS.

<p align="right">(<a href="#top">back to top</a>)</p>

---

<!-- Prerequisites -->
## Prerequisites

In order to set the environment you will need a linux mechine with the following installed:
* <a href="https://learn.hashicorp.com/tutorials/terraform/install-cli">Teraform cli</a>
* <a href="https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html">AWS cli</a>
* <a href="https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/">kubectl</a>
* <a href="https://helm.sh/docs/intro/install/">Helm</a>
* <a href="https://docs.npmjs.com/downloading-and-installing-node-js-and-npm">npm</a> (optional)
* <a href="https://docs.snyk.io/snyk-cli/install-the-snyk-cli">snyk</a> (optional)

<p align="right">(<a href="#top">back to top</a>)</p>

---

<!-- USAGE EXAMPLES -->
## Usage

1. Clone the repository to your mechine:
   <br />
   ```
   git clone https://github.com/batelzag/OpssSchool-Final-Project 
   ```
   
2. Set your AWS credentials as environment vars:
   <br />
   ```
   export AWS_ACCESS_KEY_ID=EXAMPLEACCESSKEY
   export AWS_SECRET_ACCESS_KEY=EXAMPLESECRETKEY
   export AWS_DEFAULT_REGION=us-east-1
   ```
3. Use the example.tfvars file and enter the username and password that you wish to set for the RDS insance, and the AWS credentials for the kandula app user:
   <br />
   ```
   # AWS
   aws_access_key_id       = "xxxxxxxxxx"
   aws_secret_access_key   = "xxxxxxxxxx"
   db_username             = "xxxxxxxxxx"
   db_password             = "xxxxxxxxxx"

   # Gmail
   gmail_address           = "xxxx@gmail.com"
   gmail_app_code          = "xxxxxx"

   # Slack
   slack_notification_webhook_url = "https://hooks.slack.com/..."
   ```
4. Optional: scan terraform's configuration files
   for vulnerabilities with <a href="https://docs.snyk.io/snyk-cli/install-the-snyk-cli">snyk</a>:
   <br />
   ```
   cd /OpssSchool-Final-Project
   snyk auth
   snyk iac test .
   ```
5. Optional: scan terraform's plan for vulnerabilities with <a href="https://docs.snyk.io/snyk-cli/install-the-snyk-cli">snyk</a>:
   <br />
   ```
   cd /OpssSchool-Final-Project/infrastructure
   terraform init
   terraform plan -out=tfplan.binary
   terraform show -json tfplan.binary > tf-plan.json
   snyk iac test --scan=planned-values tf-plan.json
   ```
6. Create S3 bucket for storing terraform's remote state:
   <br />
   ```
   cd /OpssSchool-Final-Project/infrastructure/s3
   terraform apply -auto-approve
   ```
   For your convenience terraform will output the follwing values:<br />
   | Resource                 | Value           |
   |--------------------------|-----------------|
   |S3 Bucket                 | ID \ Name       |
   |S3 Bucket                 | Region          |
   
   >**📝 Please Note:**
   The default name of the S3 bucket is set on the variables.tf file as ```"terraformstate-environments/Development/"``` and the region as ```us-east-1```, you can change the name of your choice, just note that the name must be unique.<br />
   Terraform's state for the S3 bucket will be saved locally on youre station.
   <br />

7. Create the infrastructure of the environemnt:
   <br />
   ```
   cd /OpssSchool-Final-Project/infrastructure
   terraform apply -auto-approve
   ```
    >**📝 Please Note:**
   If you changed the name of the S3 bucket on step 6, you will need to change it also on the variables.tf file on this dir.<br />
   
   See further details regarding the variables of the project below.
   <br />

   For your convenience terraform will output the follwing values:
   <br />
   | Resource                 | Value           |
   |--------------------------|-----------------|
   |Bastion server            | Public IP       |
   |Application Load Balancer | Public DNS Name |
   |Consul UI                 | URL Link        |
   |Jenkins UI                | URL Link        |
   |Prometherus UI            | URL Link        |
   |Grafana UI                | URL Link        |
   |Kibana UI                 | URL Link        |
   |EKS cluster               | Cluster Name    |
   |Jenkins Agents EKS access | Role ARN        |
   <br />
8. Set up the EKS cluster:
   <br />
   ```
   aws eks --region=us-east-1 update-kubeconfig --name <cluster_name>
   kubectl get configmap aws-auth -n kube-system -o yaml
   ```
   Add the ARN of the jenkins agents eks access role to the config map:
   <br />
   ```
   kubectl edit configmap aws-auth -n kube-system
   ```
   <br />
   Set cosul on K8s:
   ```
   helm repo add hashicorp https://helm.releases.hashicorp.com
   helm install consul hashicorp/consul --set global.name=consul -n consul -f ../configuration/Kubernetes/consul-helm/values.yaml
   kubectl apply -f ../configuration/Kubernetes/consul-helm/CoreDNS.yaml -n consul
   ```
   <br />
   Set prometheus on K8s:
   ```
   helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
   helm install prometheus prometheus-community/prometheus -n monitoring
   ```
   <br />
   Set filebeat on K8s:
   ```
   kubectl create -f ../configuration/Kubernetes/Filebeat/filebeat-config.yml -n logging
   ```
   <br />

9.  Set up Jenkins server - access the Jenkins UI and add the following credentials:
    <br />
    | ID                 | Value             | Description |
    |--------------------|-------------------|-------------|
    | Jenkins Agents     | username + ssh key| The jenkins agents\ nodes credentials for the use with jenkins server|
    | Github             | username + ssh key| The Github credentials in order to use the private repository |
    | Dockerhub          | username + password| The Docker hub credentials in order to upload Kandula's image to Dockerhub's registry|
    | K8s                | config map         | The config map file in order to deploy kandula's app on the EKS cluster|
    <br />

    Test Kandula's App:
    Create scm pipline and use the ```test-kandula.groovy``` file on the <a href="https://learn.hashicorp.com/tutorials/terraform/install-cli">Kandula-App Repo</a>.
    <br />
    Create a Database schema for Kandula's app:
    Create scm pipline and use the ```db-kandula.groovy``` file on the <a href="https://learn.hashicorp.com/tutorials/terraform/install-cli">Kandula-App Repo</a>.
    <br />
    Deploy Kandula to K8s:
    Create scm pipline and use the deploy-kandula.groovy file on the <a href="https://learn.hashicorp.com/tutorials/terraform/install-cli">Kandula-App Repo</a>.
    <br />
    Now Kandula is up and running and can be accessed on the loadbalancer service endpoint:
    ```
    kubectl get svc -o wide
    ```
    <br />
10. Destroy and clean up the environment:
    <br />
    ```
    kubectl delete service kandula-project-lb
    kubectl delete -f ../configuration/Kubernetes/Filebeat/filebeat-config.yml -n logging
    helm delete prometheus prometheus-community/prometheus -n monitoring
    helm delete consul hashicorp/consul --set global.name=consul -n consul
    terraform destroy

<p align="right">(<a href="#top">back to top</a>)</p>

---

<!-- VARIABLES -->
### Variables


<!-- MARKDOWN LINKS & IMAGES -->
[Kandula-App]: https://github.com/batelzag/kandula-project-app
