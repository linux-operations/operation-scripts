#!/bin/bash

# 创建nagios用户
/usr/sbin/useradd -m nagios

# 安装nagios应用
{
wget 'http://prdownloads.sourceforge.net/sourceforge/nagiosplug/nagios-plugins-1.4.16.tar.gz'
tar -xf nagios-plugins-1.4.16.tar.gz
cd nagios-plugins-1.4.16
echo "================ install nagios plugins ================"
./configure --with-nagios-user=nagios --with-nagios-group=nagios && make && make install
} >> nagios_install.log 2>&1
cd ..
rm -rf nagios-plugins-1.4.16.tar.gz nagios-plugins-1.4.16

# 安装nrpe
{
wget 'http://downloads.sourceforge.net/project/nagios/nrpe-2.x/nrpe-2.14/nrpe-2.14.tar.gz?r=&ts=1363788540&use_mirror=hivelocity'
tar -xf nrpe-2.14.tar.gz
cd nrpe-2.14
echo "================ install nrpe ================"
./configure && make all && make install
} >> nagios_install.log 2>&1
cd ..
rm -rf nrpe-2.14.tar.gz nrpe-2.14
