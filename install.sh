#!/bin/bash

# First thing is to create an EC2 instance. You need a community AMI for Debian.
# Make sure the image doesn't have "testing" in the name.  Then log in to the instance.

# Run this with /bin/bash install.sh

#
# Install prerequisites
#

sudo apt-get install vim python-virtualenv gdal-bin libgeos-dev libpq-dev libxslt1-dev libxml2-dev postgresql-common python-dev postgresql-client postgresql postgresql-contrib postgis git openjdk-7-jre-headless unzip python-memcache libjpeg-dev libfreetype6 libfreetype6-dev zlib1g-dev supervisor nginx build-essential

#
# Get the floodlight code
#

mkdir -p ~/www
mkdir -p ~/virt_env
cd ~/www

git clone https://github.com/zmetcalf/storybase.git floodlight

#
# Install the requirements from production
# Note that the requirements.txt file in storybase is not the same as Wilbertos, or production
#

cd ~/www/floodlight
git fetch
git checkout zm_local_install

virtualenv ~/virt_env/storybase
source ~/virt_env/storybase/bin/activate
pip install -r requirements.txt
pip install gunicorn

cd ~/www
git clone https://github.com/zmetcalf/storybase_solr.git

#
# Create a postgres floodlight user
#

sudo useradd floodlight
sudo passwd floodlight

sudo cp /home/admin/storybase_ec2/db_setup.sh /tmp
sudo cp /home/admin/storybase_ec2/db_floodlight.sh /tmp

sudo chown postgres:postgres /tmp/db_setup.sh
sudo chown floodlight:floodlight /tmp/db_floodlight.sh

sudo su - postgres -c "/tmp/db_setup.sh"

su - floodlight -c "/tmp/db_floodlight.sh"

#
# Restart postgresql
#

sudo /etc/init.d/postgresql restart


#
# Copy config files
#

cd ~/storybase_ec2

cp gunicorn.conf.py /home/admin/www/floodlight
sudo cp supervisor/floodlight.conf /etc/supervisor/conf.d
sudo cp supervisor/floodlight_solr.conf /etc/supervisor/conf.d
sudo cp nginx/floodlight /etc/nginx/sites-available

sudo ln -s /etc/nginx/sites-available/floodlight /etc/nginx/sites-enabled/floodlight

sudo service nginx restart
sudo service supervisor restart
