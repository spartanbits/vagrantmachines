# postinstall.sh created from Mitchell's official lucid32/64 baseboxes

date > /etc/vagrant_box_build_time

# Apt-install various things necessary for Ruby, guest additions,
# etc., and remove optional things to trim down the machine.
apt-get -y update
apt-get -y upgrade
apt-get -y install linux-headers-$(uname -r) build-essential
apt-get -y install zlib1g-dev libssl-dev libreadline5-dev
apt-get clean

# Setup sudo to allow no-password sudo for "admin"
cp /etc/sudoers /etc/sudoers.orig
sed -i -e '/Defaults\s\+env_reset/a Defaults\texempt_group=admin' /etc/sudoers
sed -i -e 's/%admin ALL=(ALL) ALL/%admin ALL=NOPASSWD:ALL/g' /etc/sudoers

# Install NFS client
apt-get -y install nfs-common

# Install Ruby from source in /opt so that users of Vagrant
# can install their own Rubies using packages or however.
# We must install the 1.8.x series since Puppet doesn't support
# Ruby 1.9 yet.
wget http://ftp.ruby-lang.org/pub/ruby/1.8/ruby-1.8.7-p334.tar.gz
tar xvzf ruby-1.8.7-p334.tar.gz
cd ruby-1.8.7-p334
./configure --prefix=/opt/ruby
make -j
make install
cd ..
rm -rf ruby-1.8.7-p334*

# Install RubyGems 1.7.2
wget http://production.cf.rubygems.org/rubygems/rubygems-1.7.2.tgz
tar xzf rubygems-1.7.2.tgz
cd rubygems-1.7.2
/opt/ruby/bin/ruby setup.rb
cd ..
rm -rf rubygems-1.7.2*

# Installing chef & Puppet
/opt/ruby/bin/gem install chef --no-ri --no-rdoc
/opt/ruby/bin/gem install puppet --no-ri --no-rdoc
/opt/ruby/bin/gem install json #install json due to failed scenary validating machine

# Add /opt/ruby/bin to the global path as the last resort so
# Ruby, RubyGems, and Chef/Puppet are visible
echo 'PATH=$PATH:/opt/ruby/bin/'> /etc/profile.d/vagrantruby.sh

# Installing vagrant keys
mkdir /home/vagrant/.ssh
chmod 700 /home/vagrant/.ssh
cd /home/vagrant/.ssh
wget --no-check-certificate 'https://raw.github.com/mitchellh/vagrant/master/keys/vagrant.pub' -O authorized_keys
chmod 600 /home/vagrant/.ssh/authorized_keys
chown -R vagrant /home/vagrant/.ssh

#Configure ssh without DNS as recommend http://vagrantup.com/v1/docs/base_boxes.html
echo "UseDNS no" >> /etc/ssh/sshd_config

# Installing the virtualbox guest additions
VBOX_VERSION=$(cat /home/vagrant/.vbox_version)
cd /tmp
wget http://download.virtualbox.org/virtualbox/$VBOX_VERSION/VBoxGuestAdditions_$VBOX_VERSION.iso
mount -o loop VBoxGuestAdditions_$VBOX_VERSION.iso /mnt
sh /mnt/VBoxLinuxAdditions.run
umount /mnt

rm VBoxGuestAdditions_$VBOX_VERSION.iso

#Installing python 2.7.2
apt-get -y install build-essential
apt-get -y install libreadline5-dev libncursesw5-dev libssl-dev libsqlite3-dev tk-dev libgdbm-dev libc6-dev libbz2-dev

cd /tmp
wget http://python.org/ftp/python/2.7.2/Python-2.7.2.tgz
tar -xvf Python-2.7.2.tgz && cd Python-2.7.2/

./configure
make -j
make altinstall

ln -sf /usr/local/lib/python2.7 /usr/lib/python2.7
ln -sf /usr/local/include/python2.7 /usr/include/python2.7
ln -sf /usr/local/bin/python2.7 /usr/bin/python2.7

wget http://pypi.python.org/packages/2.7/s/setuptools/setuptools-0.6c11-py2.7.egg#md5=fe1f997bc722265116870bc7919059ea
sh setuptools-0.6c11-py2.7.egg
easy_install-2.7 pip==1.1
pip install virtualenv==1.8.4

#Installing redis 2.4.11
apt-get -y install tcl8.5
cd /tmp
wget http://redis.googlecode.com/files/redis-2.4.15.tar.gz
tar xvfz redis-2.4.15.tar.gz && cd redis-2.4.15
make -j
make install

cd utils
./install_server.sh

cp redis_init_script /etc/init.d/redis_6379
update-rc.d redis_6379 defaults

apt-get -y remove tcl8.5

#Installing git and pushand (automatic deployments like on heroku platform with .pushand file)
apt-get -y install git-core git-doc

cd /tmp
git clone git://github.com/fesplugas/pushand.git
cd pushand
./bin/pushand install

#Install vim
apt-get -y install vim

#Install foreman to run program on deploy
/opt/ruby/bin/gem install foreman
ln -sf /opt/ruby/bin/foreman /usr/bin/foreman

#Install dependencies of app
apt-get -y install libevent-dev

#Install tsung
cd /tmp
wget http://tsung.erlang-projects.org/dist/ubuntu/lucid/tsung_1.4.1-1_all.deb
dpkg -i tsung_1.4.1-1_all.deb

apt-get -y install -f #install dependencies from tsung
apt-get -y install gnuplot

#Configure cpan for Template perl neede to tsung_stat.pl
(echo y;echo o conf prerequisites_policy follow;echo o conf commit)|cpan
(echo install Template;echo exit) | perl -MCPAN -eshell

#Add mongodb
# add the mongodb repository to /etc/apt/sources.list
bash -c "echo 'deb http://downloads-distro.mongodb.org/repo/ubuntu-upstart dist 10gen' >> /etc/apt/sources.list"
 
# add 10gen's GPG key so that aptitude will trust the repository
apt-key adv --keyserver keyserver.ubuntu.com --recv 7F0CEB10
 
# Update aptitude's list of available packages
apt-get update
 
# Install mongodb
apt-get install mongodb20-10gen

# Remove items used for building, since they aren't needed anymore
apt-get -y remove linux-headers-$(uname -r) build-essential
apt-get -y autoremove

# Zero out the free space to save space in the final image:
dd if=/dev/zero of=/EMPTY bs=1M
rm -f /EMPTY

# Removing leftover leases and persistent rules
echo "cleaning up dhcp leases"
rm /var/lib/dhcp3/*

# Make sure Udev doesn't block our network
# http://6.ptmc.org/?p=164
echo "cleaning up udev rules"
rm /etc/udev/rules.d/70-persistent-net.rules
mkdir /etc/udev/rules.d/70-persistent-net.rules
rm -rf /dev/.udev/
rm /lib/udev/rules.d/75-persistent-net-generator.rules

echo "Adding a 2 sec delay to the interface up, to make the dhclient happy"
echo "pre-up sleep 2" >> /etc/network/interfaces
exit
