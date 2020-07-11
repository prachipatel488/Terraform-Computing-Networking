terraform {
   backend "s3" {
	bucket = "terra-lab"
	key      = "terraform.tfstate"
	region  = "us-east-2"
    }
}