#!/bin/bash
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

echo "* Updating system"
apt-get update
apt-get -y upgrade
echo "* Installing packages"
apt-get -y install build-essential libmagickcore-dev imagemagick libmagickwand-dev libxml2-dev libxslt1-dev git-core nginx curl nodejs htop acl nginx

id -u deploy &> /dev/null

if [ $? -ne 0 ]
then
  echo "* Creating user deploy"
  useradd -m -g staff -s /bin/bash deploy
  echo "* Creating user rollfindr"
  useradd -m -g staff -s /bin/bash rollfindr
  echo "* Adding user deploy to sudoers"
  chmod +w /etc/sudoers
  echo "deploy ALL=(ALL) ALL" >> /etc/sudoers
  chmod -w /etc/sudoers
else
  echo "* deploy user already exists"
fi

setfacl -m g:staff:rwx /home/rollfindr
setfacl -d -m g:staff:rwx /home/rollfindr

echo "* Installing rvm"
. /etc/profile.d/rvm.sh &> /dev/null

type rvm &> /dev/null

if [ $? -ne 0 ]
then
  curl -L https://get.rvm.io | bash -s
  echo "source /etc/profile.d/rvm.sh" >> /etc/bash.bashrc
  . /etc/profile.d/rvm.sh &> /dev/null
else
  echo "* rvm already installed"
fi

cat /etc/environment | grep RAILS_ENV
if [ $? -ne 0 ]
then
  echo "RAILS_ENV=production" >> /etc/environment
fi

echo "* Adding a gemrc file to deploy user"
echo -e "verbose: true\nbulk_threshold: 1000\ninstall: --no-ri --no-rdoc --env-shebang\nupdate: --no-ri --no-rdoc --env-shebang" > /home/deploy/.gemrc
chmod 644 /home/deploy/.gemrc
chown deploy /home/deploy/.gemrc
chgrp staff  /home/deploy/.gemrc

echo "* Adding ssh key to authorized_keys"
test -d /home/deploy/.ssh
if [ $? -ne 0 ]
then
  mkdir /home/deploy/.ssh
  chmod 700 /home/deploy/.ssh
  chown deploy /home/deploy/.ssh
  chgrp staff /home/deploy/.ssh
fi

echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDQTjjPrdPMib0C8yejRT+S2fdAs/A2NSLyfBXbZNOFQWfUmjTi0hkAwcE/ahYJrmsxKJUgpMRJJcklCgxwZEcmMG7+W5QhASx00ayDRDYtJMCo/ZiePCntVYzZcefTr0ZOx3fYjXJ8IntcbIf3nwumG5Q/yE9nbwXwAo4DSxW5fveWwlG99c8LSKuKGKzl2fEsU/93LADrgj5yqnFIa5YdkDZCr80P5zJixMc1jzZ0+iYBVk9yc5Zph1WQG4Cq9wIQOT8TC+BSYWHguePfMPl2a0uqYu/r4guqu7q5/74dvFRdGc1lOIA28rbZdWIPp037tw0XDUYcP8/RisufLdUB evaniainbrooks@gmail.com" > /home/deploy/.ssh/authorized_keys
echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDu9E0ooFAh/6PJNQTGzr5LNGWNmZHpahKsS3WvndUNbGlvqNKkXDOreeeyYcR96zLY3RxkUBuJ5xsKF0C3HAScDxfe83qtzuLYq937GsY60xY/c/KhtLn94mvpnFe7vSCkx/FsZzo50T2nIXrhpkRR/3TL+ntiYjWitSJwPALd+lvG/aN229zE1lZb9f55Muf0o2l7fc32Aq79yKnsqfSwOpLRjJbUoTcbWeXxz0fYhwcBinibAFSIlYEHqZ8/DR4iDileEAhv3rlqKLnJkQnWowZ3wJb+3DwbiRzY4bTqlavYcJv7fVDmm7vO3zniH50F9vjfFe6ADbjC5mUlXFtJ Codeship/rollfindr/rollfindr" >> /home/deploy/.ssh/authorized_keys

chmod 600 /home/deploy/.ssh/authorized_keys
chown deploy /home/deploy/.ssh/authorized_keys
chgrp staff /home/deploy/.ssh/authorized_keys

echo "* Install JRuby"
ruby -v &> /dev/null
if [ $? -ne 0 ]
then
  rvm install jruby
else
  echo "* JRuby already installed"
fi

echo "* Add user deploy to rvm group"
usermod -a -G rvm deploy

rvm --default use jruby
ruby -v
echo "* DONE *"
