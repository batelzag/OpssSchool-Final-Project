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

In order to set the environment you will need a linux machine with the following installed:
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
   db_username             = "example"
   db_password             = "example12345"

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
   terraform apply -auto-approve -var-file=<file_name>.tfvars 
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

8.  Set up Jenkins server - access the Jenkins UI and add the following credentials:
    <br />
    | ID                 | Value             | Description |
    |--------------------|-------------------|-------------|
    | Jenkins Agents     | username + ssh key| The jenkins agents\ nodes credentials for the use with jenkins server|
    | Github             | username + ssh key| The Github credentials in order to use the private repository |
    | Dockerhub          | username + password| The Docker hub credentials in order to upload Kandula's image to Dockerhub's registry|
    | K8s                | config map         | The config map file in order to deploy kandula's app on the EKS cluster|
    <br />
9. Test Kandula's App:
    Create a scm pipline and use the ```test-and-build-kandula.groovy``` file from the <a href="https://learn.hashicorp.com/tutorials/terraform/install-cli">Kandula-App Repo</a> (in the pipeline folder).
    <br />
10. Deploy Kandula to K8s:
    * Create a Database schema for Kandula's app - Create a scm pipline and use the ```configure-db-kandula.groovy``` file from the <a href="https://learn.hashicorp.com/tutorials/terraform/install-cli">Kandula-App Repo</a> (in the pipeline folder).
    * Deploy to K8s - Create a scm pipline and use the ```deploy-kandula.groovy``` file from the <a href="https://learn.hashicorp.com/tutorials/terraform/install-cli">Kandula-App Repo</a> (in the pipeline folder).
  
    **Now Kandula is up and running and can be accessed from the loadbalancer service endpoint:**
    ```
    kubectl get svc -o wide
    ```
    <br />
11.  Clean up and destroy the environment:
      ```
      kubectl delete service kandula-project-lb
      kubectl delete deploy kandula-final-project-deployment
      kubectl delete -f ../configuration/Kubernetes/Filebeat/filebeat-config.yml -n logging
      helm delete prometheus prometheus-community/prometheus-node-exporter -n monitoring
      helm delete consul hashicorp/consul -n consul
      terraform destroy -auto-approve -var-file=<file_name>.tfvars
      ```

<p align="right">(<a href="#top">back to top</a>)</p>

---

<!-- VARIABLES -->
### Variables
The main input variables (can be changed as of your choice):
| Name                    | Description                                     | Type | Default value                                                               |
|-------------------------|-------------------------------------------------|------|-----------------------------------------------------------------------------|
|aws_region               | AWS region in which to deploy the infrastructure|string| us-east-1                                                                   |
|vpc_cidr                 | VPC cidr block                                  |string| 10.0.0.0\16                                                                 |
|number_of_public_subnets | Number of public subnets to create              |number| 2                                                                           |
|number_of_private_subnets| Number of private subnets to create             |number| 2                                                                           |
|key_name                 | Name of the pem key for the instances           |string|opsschool_project_key                                                        |
|route53_domain_name      | Internal domain name for route53 hosted zone    |string|opsschool.internal                                                           |
|default_tags             | Tags for the created reasources                 |string|evironment=development, owner_tag=opsschool-batel, project_tag= final-project|
|alb_name                 | Application Load Balancer name                  |string|private-resources-alb                                                        |
|instance_type            | EC2 instance type                               |string|mainly t2-micro                                                              |
|number_of_instances      | Number of instances for every kind of server    |number|consul=3, jenkins-agents=2, rest=1                                           |     
|instance_name            | Name of the instance on aws and on consul's DNS |string| diffrenet values                                                            |
|cluster_name             | Name of the EKS cluster                         |string| project-eks                                                                 |

<!-- MARKDOWN LINKS & IMAGES -->
[Kandula-App]: https://github.com/batelzag/kandula-project-app
