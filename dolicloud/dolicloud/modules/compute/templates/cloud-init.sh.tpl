#!/bin/bash
# Instala Apache + PHP + MariaDB + Dolibarr ERP/CRM sobre Ubuntu 24.04 LTS.
# Lo ejecuta cloud-init en el primer arranque de la VM.
# Log propio: /var/log/dolicloud-install.log
# Log de cloud-init: /var/log/cloud-init-output.log
set -euxo pipefail
exec > >(tee /var/log/dolicloud-install.log) 2>&1

export DEBIAN_FRONTEND=noninteractive

DB_NAME='${db_name}'
DB_USER='${db_username}'
DB_PASS='${db_password}'
DOLI_VERSION='${dolibarr_version}'
DOLI_ADMIN='${dolibarr_admin_login}'
DOLI_TZ='${php_timezone}'

DOLI_HOME=/var/www/dolibarr
WEB_ROOT="$DOLI_HOME/htdocs"
DOC_ROOT="$DOLI_HOME/documents"

# ---------------------------------------------------------------------------
# 1. Swap: la B1ms tiene 2 GB de RAM para Apache + PHP + MariaDB
# ---------------------------------------------------------------------------
if [ ! -f /swapfile ]; then
  fallocate -l 2G /swapfile
  chmod 600 /swapfile
  mkswap /swapfile
  swapon /swapfile
  echo '/swapfile swap swap defaults 0 0' >> /etc/fstab
fi

# ---------------------------------------------------------------------------
# 2. Paquetes del stack LAMP
#    DPkg::Lock::Timeout evita el choque con unattended-upgrades al arrancar.
# ---------------------------------------------------------------------------
apt-get -o DPkg::Lock::Timeout=600 update -y
apt-get -o DPkg::Lock::Timeout=600 install -y \
  apache2 mariadb-server \
  php libapache2-mod-php php-mysql php-gd php-curl php-zip \
  php-intl php-mbstring php-xml php-soap php-cli \
  curl tar unzip

systemctl enable --now apache2
systemctl enable --now mariadb

# ---------------------------------------------------------------------------
# 3. Base de datos y usuario de Dolibarr
# ---------------------------------------------------------------------------
mysql <<SQL
CREATE DATABASE IF NOT EXISTS \`$DB_NAME\` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER IF NOT EXISTS '$DB_USER'@'localhost' IDENTIFIED BY '$DB_PASS';
GRANT ALL PRIVILEGES ON \`$DB_NAME\`.* TO '$DB_USER'@'localhost';
DELETE FROM mysql.user WHERE User='';
DROP DATABASE IF EXISTS test;
FLUSH PRIVILEGES;
SQL

# ---------------------------------------------------------------------------
# 4. Codigo de Dolibarr (release fijada, no la rama develop)
# ---------------------------------------------------------------------------
if [ ! -d "$WEB_ROOT" ]; then
  mkdir -p /var/www
  curl -fsSL -o /tmp/dolibarr.tar.gz \
    "https://github.com/Dolibarr/dolibarr/archive/refs/tags/$DOLI_VERSION.tar.gz"
  tar -xzf /tmp/dolibarr.tar.gz -C /tmp
  mv "/tmp/dolibarr-$DOLI_VERSION" "$DOLI_HOME"
  rm -f /tmp/dolibarr.tar.gz
fi

# Carpeta de documentos FUERA del DocumentRoot (no accesible por HTTP)
mkdir -p "$DOC_ROOT"

# conf.php vacio y escribible: el instalador lo completa y lo deja en solo lectura
mkdir -p "$WEB_ROOT/conf"
touch "$WEB_ROOT/conf/conf.php"

# ---------------------------------------------------------------------------
# 5. Parametros precargados y bloqueados en el asistente de instalacion
# ---------------------------------------------------------------------------
cat > "$WEB_ROOT/install/install.forced.php" <<PHP
<?php
// Generado por Terraform (cloud-init). Precarga y bloquea el asistente web.
\$force_install_noedit = 2;
\$force_install_type = 'mysqli';
\$force_install_dbserver = 'localhost';
\$force_install_port = '3306';
\$force_install_database = '$DB_NAME';
\$force_install_databaselogin = '$DB_USER';
\$force_install_databasepass = '$DB_PASS';
\$force_install_prefix = 'llx_';
\$force_install_createdatabase = false;
\$force_install_createuser = false;
\$force_install_dolibarrlogin = '$DOLI_ADMIN';
\$force_install_mainforcehttps = false;
\$force_install_lockinstall = '444';
PHP

# ---------------------------------------------------------------------------
# 6. Permisos
# ---------------------------------------------------------------------------
chown -R www-data:www-data "$DOLI_HOME"
find "$WEB_ROOT" -type d -exec chmod 755 {} \;
find "$WEB_ROOT" -type f -exec chmod 644 {} \;
chmod 660 "$WEB_ROOT/conf/conf.php"
chmod -R 770 "$DOC_ROOT"

# ---------------------------------------------------------------------------
# 7. Apache: virtual host propio apuntando a htdocs
# ---------------------------------------------------------------------------
cat > /etc/apache2/sites-available/dolibarr.conf <<CONF
<VirtualHost *:80>
    DocumentRoot $WEB_ROOT

    <Directory $WEB_ROOT>
        Options -Indexes +FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>

    ErrorLog /var/log/apache2/dolibarr-error.log
    CustomLog /var/log/apache2/dolibarr-access.log combined
</VirtualHost>
CONF

a2enmod rewrite
a2dissite 000-default
a2ensite dolibarr

# ---------------------------------------------------------------------------
# 8. Ajustes de PHP requeridos por Dolibarr
# ---------------------------------------------------------------------------
for d in /etc/php/*/apache2/conf.d /etc/php/*/cli/conf.d; do
  if [ -d "$d" ]; then
    cat > "$d/99-dolibarr.ini" <<INI
memory_limit = 256M
upload_max_filesize = 64M
post_max_size = 64M
max_execution_time = 300
date.timezone = $DOLI_TZ
INI
  fi
done

systemctl restart apache2

echo "Instalacion de Dolibarr terminada: abrir /install/ en el navegador"
