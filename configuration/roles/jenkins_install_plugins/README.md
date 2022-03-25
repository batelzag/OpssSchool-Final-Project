Install Jenkins Plugins
=========

This role is intended to install the desired plugin on Jenkins Server. 

Requirements
------------

This role uses EC2 module - for dynamic inventory, and requiers python3 & boto3 packages installed.

Role Variables
--------------

The role accepts jenkins_plugin_list as a variable, and the value reffers to the jenkins plugins you wish to install on the jenkins server.

| Variable                | Required | Default |
|-------------------------|----------|---------|
| jenkins_plugin_list     | yes      | locale, workflow-aggregator, ssh-slaves, ssh-credentials, credentials, github, github-branch-source, versionnumber, docker-plugin, docker-workflow, kubernetes,kubernetes-cd, kubernetes-credentials,aws-credentials, blueocean, cloudbees-disk-usage-simple, prometheus   |

Dependencies
------------

The role should run with the -i flug and point the aws_ec2 inventory file. 

Example Playbook
----------------

Including an example of how to use your role (for instance, with variables passed in as parameters) is always nice for users too:

    - hosts: all
      become: true
      roles:
         - jenkins_install_plugins
