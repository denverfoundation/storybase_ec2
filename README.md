Install script for Storybase on EC2
===================================

Start by creating a Debian instance.

Login to the instance.

Update the repositories and install git::

    sudo apt-get update
    sudo apt-get install git # say yes

Clone this script::

    git clone https://github.com/zmetcalf/storybase_ec2.git

Move into the directory and start install::

    cd storybase_ec2
    /bin/bash install.sh # virtualenv in script requires BASH

The script will start working. You will need to input some information as
it runs. All of the answers are `yes` except the password is `floodlight`.

Once it has completed you should be able to access the instance from the Public DNS.
