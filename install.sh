#!/bin/bash

# First thing is to create an EC2 instance. You need of Debian.

# Login to instance
# Run sudo apt-get update
# Run sudo apt-get install git
# Run git clone https://github.com/denverfoundation/storybase_ec2.git
# Run cd storybase_ec2
# Run this with /bin/bash install.sh

#
# Install prerequisites - say YES!
#

sudo apt-get install vim python-virtualenv gdal-bin libgeos-dev libpq-dev libxslt1-dev libxml2-dev postgresql-common python-dev postgresql-client postgresql postgresql-contrib postgis git openjdk-7-jre-headless unzip python-memcache libjpeg-dev libfreetype6 libfreetype6-dev zlib1g-dev supervisor nginx build-essential postgresql-9.3-postgis-scripts

# Stop supervisor now because it takes Solr time to stop, so restart does not work right

sudo service supervisor stop

#
# Setup file structure
#

mkdir -p ~/www
mkdir -p ~/virt_env
cd ~/www
mkdir static media

# TODO remove when storybase is merged
git clone https://github.com/denverfoundation/storybase.git floodlight


cd ~/www/floodlight

# TODO remove when storybase is merged
git fetch
git checkout zm_local_install

# Add server settings to cloned project

mkdir floodlight
cp ~/storybase_ec2/wsgi.py floodlight
touch ~/www/floodlight/floodlight/__init__.py
cp ~/storybase_ec2/settings.py ~/www/floodlight/floodlight/settings.py
cp ~/storybase_ec2/dev.py ~/www/floodlight/settings/dev.py

# Setup Virtual Environment

cd ~/www/floodlight
virtualenv ~/virt_env/storybase
source ~/virt_env/storybase/bin/activate
pip install -r requirements.txt
pip install gunicorn

# Setup Solr

cd ~/www
git clone https://github.com/denverfoundation/storybase_solr.git

#
# Create a postgres floodlight user
#

sudo useradd floodlight
sudo passwd floodlight # set password as floodlight

# Move db_setup script to public dir, change permissions, and run script as postgres

sudo cp /home/ubuntu/storybase_ec2/db_setup.sh /tmp

sudo chown postgres:postgres /tmp/db_setup.sh

sudo su - postgres -c "sh /tmp/db_setup.sh"

sudo rm /tmp/db_setup.sh

sudo /etc/init.d/postgresql restart

# Run setup of django site

cd /home/ubuntu/www/floodlight

python manage.py collectstatic # say yes - it is ok
python manage.py syncdb
python manage.py migrate

#
# Copy server config files
#

cd ~/storybase_ec2

cp gunicorn.conf.py /home/ubuntu/www/floodlight
sudo cp supervisor/floodlight.conf /etc/supervisor/conf.d
sudo cp supervisor/floodlight_solr.conf /etc/supervisor/conf.d
sudo cp nginx/floodlight /etc/nginx/sites-available

sudo ln -s /etc/nginx/sites-available/floodlight /etc/nginx/sites-enabled/floodlight
sudo rm /etc/nginx/sites-enabled/default

sudo service nginx restart
sudo service supervisor start
