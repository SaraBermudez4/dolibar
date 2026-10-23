project_name = "dolicloud"
location = "southcentralus"

# subscription_id: se obtiene con `az account show --query id -o tsv`
# y se exporta para no dejarlo en el repositorio:
#   export TF_VAR_subscription_id='00000000-0000-0000-0000-000000000000'

vnet_cidr   = "10.1.0.0/16"
subnet_cidr = "10.1.1.0/24"

# Para la sustentacion se deja abierto. En un entorno real se restringe
# a la IP publica de la organizacion, p. ej. ["190.0.0.0/32"].
http_allowed_cidrs = ["0.0.0.0/0"]
ssh_allowed_cidrs  = ["0.0.0.0/0"]

vm_size      = "Standard_B1ms"
os_disk_size = 30

admin_username      = "azureuser"
ssh_public_key_path = "~/.ssh/id_rsa.pub"

db_name     = "dolibarrdb"
db_username = "dolibarr"
# db_password: no se guarda aqui, se exporta como variable de entorno:
#   export TF_VAR_db_password='...'

dolibarr_version     = "22.0.5"
dolibarr_admin_login = "admin"
php_timezone         = "America/Bogota"
