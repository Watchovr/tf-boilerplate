provider "aws" {
    shared_credentials_file = "$HOME/.aws/credentials"
    profile = "dougwoodrow"
    region = var.aws_region
}
