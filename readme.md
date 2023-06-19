Summary

The Ansible scripts are used for installation of Operation Manager of MongoDB & Adding clusters to a new or created project & Database. The refactored Ansible scripts have been modified in more efficient way for a faster and clean execution. The playbook structure by removing unnecessary tasks and variables. Reduce the number of unnecessary remote connections by grouping tasks and running them in batches. Use dynamic inventories to dynamically generate lists of hosts and groups, rather than manually maintaining static inventory files. Use of Ansible roles to organize and reuse sets of tasks that are common to multiple playbooks. Use "ansible-pull" to run playbooks on remote hosts, rather than using "ansible-playbook" from a central location.

Objectives

The objective of refactoring an Ansible playbook to install MongoDB Operation Manager, clusters, and databases is to improve the overall efficiency, reliability, and maintainability of the playbook. The refactored playbook should be easier to understand, modify, and extend, and it should follow best practices for Ansible playbooks. Using Ansible modules and plugins to perform tasks more efficiently and with greater reliability. Use of dynamic inventories and variables to make the playbook more flexible and adaptable to different environments. Implementing idempotence to ensure that the playbook can be run multiple times without causing unintended side effects. 
By achieving these objectives, the refactored playbook should be easier to use, more reliable, and more maintainable, which can lead to improved productivity, better quality, and reduced risk


Variables Used in Ansible Playbook:

To Use the Ansible Scripts please understand the Variables used in the Ansible playbook.
Pre-Requisites:
Variable Definition for Operation Manager in install.operatinomanager.yml file:
•	om_nodes: true/false (This parameter set to be true only when we are installing operation manager for the first time) 
•	Enable_backup: true/false (This parameter set to be true only when we are installing operation manager for the first time)
•	Cluster_Nodes: true/false ( This parameter is set to be False if you are installing operation manager in the operation manager nodes.)
Note: om_nodes, Enable_Backups &  Cluster_Nodes: Using This parameters we are executing the init scripts in the nodes
•	group_name: tag_deployment_ops_manager_dev (The group name is to define from getting it from the EC2 dynamic inventory)
•	aws_region: cn-northwest-1 ( Default region of AWS)
•	mongod_port: 27000 ( This is the mongodb database port information)
•	backing_DB_port: 28000 (This is the mongodb database backing  port information)
•	ApiKeySecretName: "AdminApiKey" ( This parameter helps us to save the secret of Public & Private key in AWS)
•	database_creds_name: MongoDB-Creds (This is the mongodb database name & Password which should be manually defined in AWS secret manager)

File Name: install-opsmanager.yml

 
After updating the above variables as per user choice use the below script to execute the above Ansible Playbook. 

To get the group_name from the dynamic inventory, Kindly run the below command. 
ansible-inventory --graph

Script:
ansible-playbook install-opsmanager.yml --limit < Group_name >

First Time Configuration of Operation Manager 

Pre-Requisites:
Variable definition for configuring the Operation Manager for the first time.

•	first_user: true/false (This parameter should be set to True if you are creating the very first user in operation manager. Else set it to False if the user is created in Operation manager)
•	New_organization: true/false (This parameter should be set to True to create a new organization in operation manager. Else set it to False if the organization is created in Operation manager)
•	New_project: true/false (This parameter should be set to True to create a new project in operation manager.)
•	aws_region: "cn-northwest-1" ( Default region of AWS)
•	ApiKeySecretName: "ApiKeys"  (This parameter helps us to save the secret of Public & Private key in AWS)
•	OrganizationName: "CommerceTool" : ( Define the name of the organization which you would like to create in Operation Manager)
•	cm_env: "staging " (Define the Environment where you would like to configure the Operation Manager)
•	MongoSecretName: "MongoDB-Creds" (This is the mongodb database name & Password which should be manually defined in AWS secret manager)
•	ApiCallSecretName: "om_api_call_secret" (This secret name is to be defined in AWS manually, because based on that the first user in the operation manager is created.)













File Name: configure-usrprjcts.yml

 

After updating the above variables as per user choice use the below script to execute the above Ansible Playbook(configure-usrprjcts.yml). 

Script:
ansible-playbook configure-usrprjcts.yml --limit < Group_name >









Adding Nodes in the created Mongodb Operation Manager

Pre-Requisites: 

om_nodes: 'false' (This parameter should be in ‘False’ State always)
Enable_backup: 'false' (This parameter should be in ‘False’ State always)
Cluster_Nodes: 'True' (To run the init scripts in the nodes cluster this parameter should be Set to True)
group_name: "tag_deployment_ansible_project"  (The group name is to define from getting it from the EC2 dynamic inventory)
database_creds_name: "MongoDB-Creds" (This is the mongodb database name & Password which should be manually defined in AWS secret manager)
first_user: 'false' (This condition should always be set to ‘False’ when adding the nodes)
New_organization: 'false' (This parameter should be set to ‘False’ while adding the cluster)
New_project: 'True' (This parameter should be set to True to create a new project in operation manager or if you want to use existing project to add nodes this parameter is set to be ‘False’)
aws_region: "cn-northwest-1"  (Default region of AWS)
ApiKeySecretName: "AdminApiKey" (This parameter helps us to fetch the secret of Public & Private key from AWS)
OrganizationName: "COMMERCETOOLSSTAGING" ( The organization name needs to be defined here to get the organization id from AWS secret manager)
cm_env: "staging " (Define the Environment where you would like to configure the Operation Manager)
MongoSecretName: "MongoDB-Creds" (This is the mongodb database name & Password which should be manually defined in AWS secret manager)
project_name: "ansible-test-1-cn-northwest1.aws.commercetools.cn-0" ( We need to define the project name under this parameter for which we want to add a new cluster and deploy the mongodb database)
projects_file_path: "vars/ansible.json" ( We need to define JSON file which is created from Terraform code)




File Name: configure-nodes.yml

 

To get the group_name from the dynamic inventory, Kindly run the below command. 
ansible-inventory --graph

Script:
ansible-playbook configure-nodes.yml --limit < Group_name >





Global Variable File:
We have to configure the global variables in the global-vars.yml file which will remain same for every Ansible Playbook.
