# install kernel driver
yum install -y gcc kernel-devel-$(uname -r)

# blacklist nvidia conflicting kernel modules
cat << EOF | sudo tee --append /etc/modprobe.d/blacklist.conf
blacklist vga16fb
blacklist nouveau
blacklist rivafb
blacklist nvidiafb
blacklist rivatv
EOF

# install nvdia driver
curl -O http://us.download.nvidia.com/XFree86/Linux-x86_64/367.106/NVIDIA-Linux-x86_64-367.106.run
/bin/bash ./NVIDIA-Linux-x86_64-367.106.run -s

# reboot to load kernel modlures
reboot

# somehow, after rebooting, the node does not connect back to the cluster.
# Anthony, could you please help to find out the reason?

# install cuda driver
curl -O https://developer.download.nvidia.com/compute/cuda/repos/rhel7/x86_64/cuda-repo-rhel7-8.0.61-1.x86_64.rpm

sudo rpm -i cuda-repo-rhel7-8.0.61-1.x86_64.rpm
sudo yum clean all
sudo yum -y install cuda-8-0.x86_64