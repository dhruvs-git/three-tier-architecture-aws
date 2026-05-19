project_name = "three-tier-app"
region       = "ca-central-1"

cidr_block           = "10.0.0.0/16"
public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnet_cidrs = ["10.0.3.0/24", "10.0.4.0/24"]
availability_zone    = ["ca-central-1a", "ca-central-1b"]

db_name     = "appdb"
db_username = "admin_dhruv"
