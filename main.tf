/*
# Probably the most useful variable, enter
# the domain where you want your website hosted
variable "domain_website" {
  default = "azuka.ga"
}
# Visit https://console.aws.amazon.com/route53/home#hosted-zones:
# and look at the "Hosted Zone ID" column
variable "route53_zone_id" {
  default = "Z03047433UI6HPACQ4I96"
}

variable "profile" {
   default = "default"
}
variable "public_bucket_name" {
  default = "public-edge-site"
}
variable "private_bucket_name" {
  default = "gateway-edge-site"
}
variable "lambda_edge_bucket_name" {
   default = "edge-site"
}
variable "project_prefix" {
  default = "test"
}
variable "region" {
    default = "eu-west-1"
}
variable "lambda_edge_region" {
  default = "us-east-1"
}

variable "account_id" {
  default = "051102736698"
}


*/




# Probably the most useful variable, enter
# the domain where you want your website hosted
variable "domain_website" {
}
# Visit https://console.aws.amazon.com/route53/home#hosted-zones:
# and look at the "Hosted Zone ID" column
variable "route53_zone_id" {
}


variable "profile" {
}
variable "public_bucket_name" {
}
variable "private_bucket_name" {
}
variable "lambda_edge_bucket_name" {
}
variable "project_prefix" {
}
variable "region" {
}
variable "lambda_edge_region" {
}
variable "account_id" {
}






provider "aws" {
  version = "~> 2.22"
  profile = "${var.profile}"
  region  = "eu-west-2"
}

provider "aws" {
  version = "~> 2.22"
  profile = "${var.profile}"
  region  = "${var.lambda_edge_region}"
  alias   = "lambda_edge"
}



##archives
/*
data "archive_file" "lambda_json" {
  type        = "zip"
  source_dir  = "${path.module}/src/lambda_json"
  output_path = "${path.module}/_build/lambda_json.zip"
}
*/

data "archive_file" "lambda_html" {
  type        = "zip"
  source_dir  = "${path.module}/src/lambda_html"
  output_path = "${path.module}/_build/lambda_html.zip"
}


data "archive_file" "lambda_json" {
  type        = "zip"
  source_file = "${path.module}/src/lambda-function/lambda_function.py"
  output_path = "${path.module}/src/_build/lambda_function.zip"
}



## modules
module "buckets" {
  source                  = "./buckets"
  public_bucket_name      = "${var.public_bucket_name}"
  private_bucket_name     = "${var.private_bucket_name}"
  lambda_edge_bucket_name = "${var.lambda_edge_bucket_name}"
  providers = {
    aws.lambda_edge = aws.lambda_edge
  }
}

module "objects" {
  source               = "./objects"
  public_bucket        = "${module.buckets.public_bucket}"
  private_bucket       = "${module.buckets.private_bucket}"
  lambda_edge_bucket   = "${module.buckets.lambda_edge_bucket}"
  lambda_json_zip_path = "${data.archive_file.lambda_json.output_path}"
  lambda_html_zip_path = "${data.archive_file.lambda_html.output_path}"
  example_image_path   = "${path.module}/src/assets/example.jpg"
  providers = {
    aws.lambda_edge = aws.lambda_edge
  }
}

module "lambdas" {
  source           = "./lambdas"
  private_bucket   = "${module.buckets.private_bucket}"
  lambda_json_key  = "${module.objects.lambda_json_key}"
  lambda_json_hash = "${data.archive_file.lambda_json.output_base64sha256}"
  project_prefix   = "${var.project_prefix}"
  handler          = "lambda_function.lambda_handler"    # "lambda_function.handler"   python code
}

module "api_gateway" {
  source                    = "./api_gateway"
  region                    = "${var.region}"
  account_id                = "${var.account_id}"
  lambda_json_invoke_arn    = "${module.lambdas.lambda_json_invoke_arn}"
  lambda_json_function_name = "${module.lambdas.lambda_json_function_name}"
  lambda_json_qualified_arn = "${module.lambdas.lambda_json_qualified_arn}"

}

/*
module "edge_lambdas" {
  source               = "./edge_lambdas"
  lambda_edge_bucket   = "${module.buckets.lambda_edge_bucket}"
  lambda_edge_html_key = "${module.objects.lambda_edge_html_key}"
  lambda_html_hash     = "${data.archive_file.lambda_html.output_base64sha256}"
  project_prefix       = "${var.project_prefix}"
  providers = {
    aws.lambda_edge = aws.lambda_edge
  }
}


module "cloudfront" {
  source                         = "./cloudfront"
  public_bucket_domain_name      = "${module.buckets.public_bucket_domain_name}"
  lambda_edge_bucket_domain_name = "${module.buckets.lambda_edge_bucket_domain_name}"
  origin_id                      = "${var.project_prefix}-cloudfront-distribution"
  project_prefix                 = "${var.project_prefix}"
  edge_lambda_html_qualified_arn = "${module.edge_lambdas.edge_lambda_html_qualified_arn}"
  acm_arn = "${module.acm-us-east-1.acm_arn}"
  domain_website = "${var.domain_website}"
  route53_zone_id = "${var.route53_zone_id}"
}


module "acm-us-east-1" {
  source = "./acm"
  providers = {
    aws = "aws.lambda_edge"

  }

  domain_website = "${var.domain_website}"
  route53_zone_id = "${var.route53_zone_id}"
}

*/

# OUTPUT

output "public_bucket_domain_name" {
  value = "${module.buckets.public_bucket_domain_name}"
}
output "private_bucket_domain_name" {
  value = "${module.buckets.private_bucket_domain_name}"
}
output "lambda_edge_bucket_domain_name" {
  value = "${module.buckets.lambda_edge_bucket_domain_name}"
}
output "example_image_url" {
  value = "${module.buckets.public_bucket_domain_name}/${module.objects.example_image_key}"
}

/*
output "cloudfront_domain_name" {
  value = "${module.cloudfront.cloudfront_domain_name}"
}

output "edge_lambda_cloud_url" {
  value = "${module.cloudfront.edge_lambda_cloud_url}"
}

*/

output "lambda_public_url" {
  value =    "${module.api_gateway.lambda_public_url}" #            "${aws_api_gateway_deployment.example.invoke_url}${aws_api_gateway_resource.example.path}"
}

output "base_url" {
  value =  "${module.api_gateway.base_url}"      #"${aws_api_gateway_deployment.example.invoke_url}"
}

