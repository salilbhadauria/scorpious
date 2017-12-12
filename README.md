[![Build Status](https://travis-ci.com/deepcortex/scorpius.svg?token=pvwDNvw6P8fj9zJxpA1p&branch=master)](https://travis-ci.com/deepcortex/scorpius)
[![Codacy Badge](https://api.codacy.com/project/badge/Grade/159b57f655704fa58920eb425104697a)](https://www.codacy.com?utm_source=github.com&amp;utm_medium=referral&amp;utm_content=deepcortex/scorpius&amp;utm_campaign=Badge_Grade)

#  scorpius
Automated deployment for DeepCortex platform

### Docker deployment

1. Create a folder called environments on your computer.
2. Place the template.tfvars file under this "environmnets" directory.
3. Fill in the necessary variables in template.tfvars.
4. Export the following variables in your terminal.
    * CONFIG - the name of the config file to use (should be template).
    * AWS_ACCESS_KEY - the access key that should be used to deploy in AWS.
    * AWS_SECRET_ACCESS_KEY - the secret key that should be used to deploy in AWS.
    * CUSTOMER_KEY - the DC/OS enterprise key 
    * DCOS_USERNAME - the username you'd like to use to login to the DC/OS cluster
    * DCOS_PASSWORD - the password you'd like to use to login to the DC/OS cluster
5. Run "docker pull deepcortex/scorpius-deploymnet:TAG" repalcing tag with the correct image tag.
6. Run the following docker command replacing /path/to/environments with the path to the environments directory you created in step 1 and TAG with the correct version of the docker image.

    ```bash
    docker run \
      -v /path/to/environments:/opt/deploy/environments \
      -e CONFIG=${CONFIG_FILE} \
      -e AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID} \
      -e AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY} \
      -e CUSTOMER_KEY=${CUSTOMER_KEY} \
      -e DCOS_USERNAME=${DCOS_USERNAME} \
      -e DCOS_PASSWORD=${DCOS_PASSWORD} \
      deepcortex/scorpius-deployment:TAG
    ```
6. Once your terminal output states the deployment it complete you can access the DeepCortex UI.

### Manual deploying the scripts without docker.

#### Dependencies:

  * Terraform >=0.10.7 https://releases.hashicorp.com/terraform/0.10.7/
  * Packer =1.0.4 https://releases.hashicorp.com/packer/?_ga=2.152781114.2069873712.1510704531-228023890.1505205072
  * AWS Cli https://aws.amazon.com/cli/

  * Create your ~/.aws/config and ~/.aws/credentials

  * Make sure you exported AWS_PROFILE

#### BUILDING NEW ENVIRONMENT

##### Build all<config> <aws_access_key_id> <aws_secret_access_key> <customer_key> <dcos_username> <dcos_password>

Everything can be built at once, including all terraform and packer scripts by running build.sh.

You must export the following varible to run build.sh
* CONFIG
* AWS_PROFILE or AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY
* CUSTOMER_KEY
* DCOS_USERNAME
* DCOS_PASSWORD

##### Packer:

Building the environment requires first building the AMIs that terraform will use. We do it with Packer.

In the environments/CONFIG.tfvars file for your environment/region/cloud you will need to update the following variables:

 - packer_base_ami
 - packer_ssh_user
 - aws_region

Running packer:

Bootstrap instance requires the following env variables exported:
  - CUSTOMER_KEY
  - DCOS_USERNAME
  - DCOS_PASSWORD

./packer.sh captain CONFIG
./packer.sh bootstrap CONFIG
./packer.sh master CONFIG
./packer.sh slave CONFIG

once we have the AMIs ready, we can continue with Terraform.

##### Terraform:

First of all we need a bucket where Terraform will store all the state files for each stack.

On environments/CONFIG.tfvars file for your environment/region/cloud you will need to update the following variables:

 - bucket

Creating the bucket and updating the terraform code will be done by running the terraform_init_backend.sh script.

IMPORTANT: Update environments/CONFIG.tfvars file for your environment/region/cloud using environments/integration.tfvars as example.

SSH key MUST be provided via configuration file, we cannot retrieve AWS generated keys.

Running terraform:

We've built a terraform.sh script (wrapper) to handle configuration files and all the terraform code. Run the following commands in the presented order to build the environment.

Building IAM:

./terraform.sh init CONFIG iam (initializes the state file)
./terraform.sh plan CONFIG iam (check the code will run and generates output file)
./terraform.sh apply CONFIG iam (applies output file generated in the previous command)

Building VPC:

./terraform.sh init CONFIG vpc (initializes the state file)
./terraform.sh plan CONFIG vpc (check the code will run and generates output file)
./terraform.sh apply CONFIG vpc (applies output file generated in the previous command)

Building Redshift:

./terraform.sh init CONFIG redshift (initializes the state file)
./terraform.sh plan CONFIG redshift (check the code will run and generates output file)
./terraform.sh apply CONFIG redshift (applies output file generated in the previous command)

Building Platform (DC/OS):

./terraform.sh init CONFIG platform (initializes the state file)
./terraform.sh plan CONFIG platform (check the code will run and generates output file)
./terraform.sh apply CONFIG platform (applies output file generated in the previous command)

Apply will return master_elb_url which currently is public for testing purposes, you will be able to access to the DC/OS dashboard vía https://master_elb_url

Destroying everything(run backwards):

./terraform.sh plan-destroy CONFIG STACK (check the code will run and generates output file)
./terraform.sh apply CONFIG STACK (applies output file generated in the previous command)
