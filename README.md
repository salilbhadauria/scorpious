# scorpius
Automated deployment for DeepCortex platform

Dependencies:

  Terraform >=0.10.7 https://releases.hashicorp.com/terraform/0.10.7/
  Packer >=1.0.4 https://releases.hashicorp.com/packer/?_ga=2.152781114.2069873712.1510704531-228023890.1505205072
  AWS Cli https://aws.amazon.com/cli/

Create your ~/.aws/config and ~/.aws/credentials

Make sure you exported AWS_PROFILE

BUILDING NEW ENVIRONMENT

Packer:

Building the environment requires first building the AMIs that terraform will use. We do it with Packer.

In the environments/CONFIG.tfvars file for your environment/region/cloud you will need to update the following variables:

 - packer_base_ami
 - packer_ssh_user
 - aws_region

Running packer:

./packer.sh bootstrap CONFIG
./packer.sh master CONFIG
./packer.sh slave CONFIG

once we have the AMIs ready, we can continue with Terraform.

Terraform:

First of all we need a bucket where Terraform will store all the state files for each stack.

On environments/CONFIG.tfvars file for your environment/region/cloud you will need to update the following variables:

 - bucket

Creating the bucket and updating the terraform code will be done by running the terraform_init_backend.sh script.

Update environments/CONFIG.tfvars file for your environment/region/cloud using environments/integration.tfvars as example.

Running terraform:

We've built a terraform.sh script (wrapper) to handle configuration files and all the terraform code. Run the following commands in the presented order to build the environment.

Building VPC:

./terraform.sh init CONFIG vpc (initializes the state file)
./terraform.sh plan CONFIG vpc (check the code will run and generates output file)
./terraform.sh apply CONFIG vpc (applies output file generated in the previous command)

Building IAM:

./terraform.sh init CONFIG iam (initializes the state file)
./terraform.sh plan CONFIG iam (check the code will run and generates output file)
./terraform.sh apply CONFIG iam (applies output file generated in the previous command)

Building Platform (DC/OS):

./terraform.sh init CONFIG platform (initializes the state file)
./terraform.sh plan CONFIG platform (check the code will run and generates output file)
./terraform.sh apply CONFIG platform (applies output file generated in the previous command)

Apply will return master_elb_url which currently is public for testing purposes, you will be able to access to the DC/OS dashboard vía https://master_elb_url

Building Redshift:

./terraform.sh init CONFIG redshift (initializes the state file)
./terraform.sh plan CONFIG redshift (check the code will run and generates output file)
./terraform.sh apply CONFIG redshift (applies output file generated in the previous command)

Destroying everything(run backwards):

./terraform.sh plan-destroy CONFIG STACK (check the code will run and generates output file)
./terraform.sh apply CONFIG STACK (applies output file generated in the previous command)
