# terraform-lambdas-api-gateway-cloudfront

Example terraform/terragrunt scripts for lambdas, api-gateway and cloudfront

## Intro

This is a working set of Terraform files that will deploy a few resources:

* Stores terraform state can be remotely stored in S3 however locally for test purpose AS ONLY use dby myself 
* S3 buckets - public & private in eu-west-2, lambda_edge in us-east-1 region
* S3 bucket objects - image and zipped lambda files
* Standard lambda (created from zipped source in private bucket)
* API gateway to access the normal lambda  (Python class ./deliotte/src/lambda-function/lambda_function.py)
* Edge lambda (created from zipped source in lambda edge bucket)
* Cloudfront distribution with public bucket as origin and edge lambda association
* Various IAM roles, policies and permissions to make the bits work together
* Route53  to access Domain name
* ACM to provide authentication for Domin Name : Only valid to run on FireFox 


## Install 

### Install Terraform & AWSCLI

```
brew install terraform 
```

### Install AWS CLI

Instructions here <https://docs.aws.amazon.com/cli/latest/userguide/install-macos.html>


```

## Run Deployment

git alone 

terraform init
terraform plan
terraform apply

```
terraform destroy


```

Please note that sections/modules buidling the edge lambdas and acm and Route53 have been commented out becuase ran out of ACM allocations.
