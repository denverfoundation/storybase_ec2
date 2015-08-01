#!/bin/bash

# First thing is to create an EC2 instance. You need a community AMI for Debian.
# Make sure the image doesn't have "testing" in the name.  Then log in to the instance.

#
# Install prerequisites
#

sudo apt-get update

sudo apt-get upgrade

sudo apt-get install vim python-virtualenv gdal-bin geos libpq-dev postgresql-common python-dev postgresql-client postgresql postgresql-contrib postgis git openjdk-7-jre-headless unzip python-memcache libjpeg libjpeg-dev libfreetype6 libfreetype6-dev zlib1g-dev supervisor nginx

#
# Get the floodlight code
#

mkdir -p ~/www

sudo mkdir -p ~/virt_env

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

sudo su - postgres

createuser --superuser floodlight

psql

\password floodlight # floodlight

psql mydatabasename -c "CREATE EXTENSION postgis";


sudo -u postgres createdb floodlight

sudo psql floodlight -c "CREATE EXTENSION postgis";



#
# Restart postgresql
#

sudo /etc/init.d/postgresql restart

sudo su - postgres


#
# Copy config files
#

cp gunicorn.conf.py /home/admin/www/floodlight

sudo cp supervisor/floodlight.conf /etc/supervisor/conf.d

sudo cp supervisor/floodlight_solr.conf /etc/supervisor/conf.d

sudo cp nginx/floodlight /etc/nginx/sites-available

sudo ln -s /etc/nginx/sites-available/floodlight /etc/nginx/sites-enabled/floodlight

sudo service nginx restart

sudo service supervisor restart
