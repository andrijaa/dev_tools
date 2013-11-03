# SCRIPT TO UPGRADE WORDPRESS
# USAGE: update_wordpress.sh http://wordpress.org/wordpress-3.5.zip 

WORDPRESS_FILE="wordpress_update.zip"
wget http://wordpress.org/latest.zip -O $WORDPRESS_FILE
unzip $WORDPRESS_FILE -d wordpress_update
rm -rf wp-includes/ wp-admin/
mv wordpress_update/wordpress/wp-includes .
mv wordpress_update/wordpress/wp-admin .
mv wordpress_update/wordpress/* .

# CLEAN UP
rm -rf wordpress_update
rm -f $WORDPRESS_FILE 

