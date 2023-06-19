#!/bin/bash

echo "Updating Packages"
sudo yum -y update
sudo yum -y install cyrus-sasl cyrus-sasl-gssapi cyrus-sasl-plain krb5-libs libcurl net-snmp openldap openssl xz-libs

echo "Formatting Filesystem"
sudo mkfs -t xfs /dev/sdf
sudo mkdir /data
sudo mount /dev/sdf /data
sudo grep -q /dev/sdf /etc/fstab || echo "/dev/sdf       /data          xfs     defaults,noatime   1  1" | sudo tee --append /etc/fstab

sudo mkfs -t xfs /dev/sdg
sudo mkdir /s3metadata
sudo mount /dev/sdg /s3metadata
sudo grep -q /dev/sdg /etc/fstab || echo "/dev/sdg       /s3metadata          xfs     defaults,noatime   1  1" | sudo tee --append /etc/fstab

sudo mkfs -t xfs /dev/sdh
sudo mkdir /backups/head
sudo mount /dev/sdh /backups/head
sudo grep -q /dev/sdh /etc/fstab || echo "/dev/sdh      /backups/head          xfs     defaults,noatime   1  1" | sudo tee --append /etc/fstab

echo "Applying Prod Notes"

echo "NUMA"
sudo grep -q 'vm.zone_reclaim_mode' /etc/sysctl.conf || echo "vm.zone_reclaim_mode=0" | sudo tee --append /etc/sysctl.conf
sudo grep   "vm.zone_reclaim_mode=0" /etc/sysctl.conf || echo "Incorrect value for Zone Reclaim Mode"

echo "Swap"
sudo grep -q 'vm.swappiness' /etc/sysctl.conf || echo "vm.swappiness=1" | sudo tee --append /etc/sysctl.conf
sudo grep "vm.swappiness=1" /etc/sysctl.conf || echo "Incorrect value for VM Swappiness"

echo "ulimits"

for limit in fsize cpu as memlock
do
  grep "mongodb" /etc/security/limits.conf | grep -q $limit || echo -e "mongod     hard   $limit    unlimited\nmongod     soft    $limit   unlimited" | sudo tee --append /etc/security/limits.conf
done

for limit in nofile noproc
do
  grep "mongodb" /etc/security/limits.conf | grep -q $limit || echo -e "mongod     hard   $limit    64000\nmongod     soft    $limit   64000" | sudo tee --append /etc/security/limits.conf
done

echo "THP"

SCRIPT=$(cat << 'ENDSCRIPT'
#!/bin/bash
### BEGIN INIT INFO
# Provides:          disable-transparent-hugepages
# Required-Start:    $local_fs
# Required-Stop:
# X-Start-Before:    mongod mongodb-mms-automation-agent
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Disable Linux transparent huge pages
# Description:       Disable Linux transparent huge pages, to improve
#                    database performance.
### END INIT INFO

case $1 in
  start)
    if [ -d /sys/kernel/mm/transparent_hugepage ]; then
      thp_path=/sys/kernel/mm/transparent_hugepage
    elif [ -d /sys/kernel/mm/redhat_transparent_hugepage ]; then
      thp_path=/sys/kernel/mm/redhat_transparent_hugepage
    else
      return 0
    fi

    echo 'never' > ${thp_path}/enabled
    echo 'never' > ${thp_path}/defrag

    re='^[0-1]+$'
    if [[ $(cat ${thp_path}/khugepaged/defrag) =~ $re ]]
    then
      # RHEL 7
      echo 0  > ${thp_path}/khugepaged/defrag
    else
      # RHEL 6
      echo 'no' > ${thp_path}/khugepaged/defrag
    fi

    unset re
    unset thp_path
    ;;
esac
ENDSCRIPT
)

echo "$SCRIPT" | sudo tee /etc/init.d/disable-transparent-hugepages

sudo chmod 755 /etc/init.d/disable-transparent-hugepages

sudo chkconfig --add disable-transparent-hugepages

echo "Readahead"

SCRIPT=$(cat << 'ENDSCRIPT'
#!/bin/bash
### BEGIN INIT INFO
# Provides:          disable-transparent-hugepages
# Required-Start:    $local_fs
# Required-Stop:
# X-Start-Before:    mongod mongodb-mms-automation-agent
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Disable Linux transparent huge pages
# Description:       Disable Linux transparent huge pages, to improve
#                    database performance.
### END INIT INFO

case $1 in
  start)
    if [ -d /sys/kernel/mm/transparent_hugepage ]; then
      thp_path=/sys/kernel/mm/transparent_hugepage
    elif [ -d /sys/kernel/mm/redhat_transparent_hugepage ]; then
      thp_path=/sys/kernel/mm/redhat_transparent_hugepage
    else
      return 0
    fi

    echo 'never' > ${thp_path}/enabled
    echo 'never' > ${thp_path}/defrag

    re='^[0-1]+$'
    if [[ $(cat ${thp_path}/khugepaged/defrag) =~ $re ]]
    then
      # RHEL 7
      echo 0  > ${thp_path}/khugepaged/defrag
    else
      # RHEL 6
      echo 'no' > ${thp_path}/khugepaged/defrag
    fi

    #Set Readahead for Data Disk
    blockdev --setra 8 /dev/sdf
    unset re
    unset thp_path
    ;;
esac
ENDSCRIPT
)

echo "$SCRIPT" | sudo tee /etc/init.d/disable-transparent-hugepages
sudo chmod 755 /etc/init.d/disable-transparent-hugepages
sudo chkconfig --add disable-transparent-hugepages

cat << 'ENDKEY' | sudo tee /etc/mongodb.key
/onQ7jTxupAqhw2Jly534pQbPyxU7lWBVQxAdrt8bR/XUIBLZ1ZYlyLidNiwXoP5
wxgiHmxAEvYPbSO/iMjhPHvOh96Ypykx0Y6VqxLLZoebnkImv98hFLibB0jDb/cM
Kaxy05IS7gCpGtN11lydYR3mlU5zQXcV+GNFbi8W4c/JW84HrpQQXkMy7JfXjMjJ
4ykLAZY73MobiZxXAKr2lAeF4Xw8n8x37R8D8Ymxwqkiv7WyLB9yBPHFJD53h4Ar
OdPfWm8WWV7ZzHezrD7Rc/mWo4SLSUfvexb0Gn8EDIRcHQATvrucYeTM5kvsFBRk
z8Vst+9T/ynZNFeNmhw17iuPA86Kr4sBv00of3k73DYaAjKoo9V9IVX3f+Y6Gv7q
SqXwTv4M+Th1yfODRrt7DmyohkLbLuz7gN3m6urguqAXyTABqbA3bjtPckXx5dX+
wQzubMNokHmNBDKZ2VjL+Z+bkJpeSi+XrLBTbkgyQ6KZ1va5wenFfO08EQCuPu+v
Sgs7+IZAWiT6DbaImLMJuLhPew076gah55RsRRkvwU/heljWClR/TZ1xMqk9Osf7
etUrbYw+WEX0vVDfhFPHgxkSDpu5nLZYuRsycV8ORRIe77OGThSQvxwcKiHgzz2D
tLyOkSUCvt/tR/6okm5MPCnMSrFlXBzQSXPW1hcQggSm79njiyHYgDa3Lqvrz/m0
9O+OgZjy/rpRu2CRA9caPlpUSiekxpliXb3ys4V6JgAtpmPUkZ26qlhidAPZesRD
UC3rnOFH2RacxaYWoPEZ4viNv+SeiylvpDiLq7Yt4RCZLLP58fMGn/0koU41NuLC
jaUeLCAeaq6yax1CMxWKZBbG9w6CoAVh7WrvTd8ayF0ZdkkCXQgnA3loKn0rKCrd
RiNH+WiwG8erKI7nr2galMl5w4RXc9/EgywdchlEtOv1vJF4+7t923uQBoDH+GTg
zT7lmP1oCOcMH2oh3On6uUYacLAIbU9WxJcU1xBG5SXWAJOv
ENDKEY

sudo chmod 400 /etc/mongodb.key

echo "Lets Encrypt Directories"
sudo mkdir /var/log/letsencrypt
sudo chown ec2-user:ec2-user /var/log/letsencrypt
sudo mkdir /etc/letsencrypt
sudo chown ec2-user:ec2-user /etc/letsencrypt
sudo mkdir /var/lib/letsencrypt
sudo chown ec2-user:ec2-user /var/lib/letsencrypt

sudo /usr/sbin/shutdown -r 1


