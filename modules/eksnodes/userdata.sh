#!/bin/bash
set -o xtrace
/etc/eks/bootstrap.sh dish-test-upf-cluster --kubelet-extra-args "--cpu-manager-policy=static --cpu-manager-reconcile-period=5s --system-reserved=cpu=512m,memory=512Mi --kube-reserved=cpu=512m,memory=512Mi"
echo "net.ipv4.conf.default.rp_filter = 0" | tee -a /etc/sysctl.conf
echo "net.ipv4.conf.all.rp_filter = 0" | tee -a /etc/sysctl.conf
sudo sysctl -p
sleep 45
ls /sys/class/net/ > /tmp/ethList;cat /tmp/ethList |while read line ; do sudo ifconfig $line up; done
grep eth /tmp/ethList |while read line ; do echo "ifconfig $line up" >> /etc/rc.d/rc.local; done
systemctl enable rc-local
chmod +x /etc/rc.d/rc.local