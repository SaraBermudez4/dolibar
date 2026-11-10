project_name = "dolicloud"
location     = "eastus"

# subscription_id, db_password y dolibarr_admin_password NO van aqui:
#   export TF_VAR_subscription_id="$(az account show --query id -o tsv)"
#   export TF_VAR_db_password='UnaClaveLarga2026'
#   export TF_VAR_dolibarr_admin_password='OtraClave2026'

vnet_cidr         = "10.1.0.0/16"
apps_subnet_cidr  = "10.1.0.0/23"
mysql_subnet_cidr = "10.1.2.0/24"

db_name     = "dolibarrdb"
db_username = "dolibarr"

image                = "docker.io/dolibarr/dolibarr:22.0.5"
dolibarr_admin_login = "admin"
php_timezone         = "America/Bogota"
