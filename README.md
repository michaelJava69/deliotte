# terraform-lambdas-api-gateway-cloudfront

Example terraform scripts for lambdas, api-gateway and cloudfront

- Hello World lambda edge optimized
- Python lambda dynamic script
- Image that is cached using cloudfront
ACM for Route53 Domain registering
IAM Rules to allow lambda / API communication



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

git clone https://github.com/michaelJava69/deliotte.gitcd deliotte
cd deliotte 

terraform init
terraform plan
terraform apply

```
terraform destroy


.
├── acm
│   ├── acm.tf
│   └── variables.tf
├── api_gateway
│   ├── main.tf
│   └── main.tf_bk
├── buckets
│   └── main.tf
├── _build
│   ├── lambda_html.zip
│   └── lambda_json.zip
├── cloudfront
│   └── main.tf
├── edge_lambdas
│   └── main.tf
├── lambdas
│   ├── main.tf.old
│   └── maint.tf
├── main.tf
├── michael
├── objects
│   └── main.tf
├── README.md
├── src
│   ├── assets
│   │   └── example.jpg
│   ├── _build
│   │   └── lambda_function.zip
│   ├── lambda-function
│   │   └── lambda_function.py
│   ├── lambda_html
│   │   └── index.js
│   └── lambda_json
│       └── index.js
├── terraform.tfstate
├── terraform.tfstate.backup
└── terraform.tfvars


```
To do

Please note that sections/modules buidling the edge lambdas and acm and Route53 have been commented out becuase ran out of ACM allocations.
Optimize cloudfront to serve parts of world required for cost savings [at pricecing 100 at mo]
Get the python accessible through API DNS URL and eventually Domain address after adding a mapping to cloudfront and Route53
Lots of other things
