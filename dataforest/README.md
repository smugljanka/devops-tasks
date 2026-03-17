# Dataforest

## Task description

```text
Підготувати Terraform код для розгортання простого застосунку: фронт, бекенд, база даних. 

Рекомендовані сервіси: 
VPC, EC2, CloudFront.

Також підготувати конфігурацію Nginx та Docker Compose для інфраструктури на EC2.
```

## Setup pre-requisites

The following utilities are required

- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-quickstart.html)
- [Terraform CLI](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)
- [Tfenv](https://github.com/tfutils/tfenv)

## Initial work-flow

We need to follow the next order

- Setup `tf-backend`
```shell
cd tf-backend
tfenv install min-required && tfenv use min-required && terraform init
terraform apply
```

- Setup VPC common resources
```shell
cd common-vpc
tfenv install min-required && tfenv use min-required && terraform init
terraform apply
```

- Setup rest resources (ALB, EC2, S3 bucket and/or CloudFront distribution)
```shell
tfenv install min-required && tfenv use min-required && terraform init
terraform apply
```