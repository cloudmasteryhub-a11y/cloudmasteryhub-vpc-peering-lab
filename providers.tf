provider "aws" {
  region = var.region_mumbai
}

provider "aws" {
  alias  = "virginia"
  region = var.region_virginia
}
