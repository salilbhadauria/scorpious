#!/bin/bash

# install kernel driver
# sudo yum install -y gcc kernel-devel-$(uname -r)

# blacklist nvidia conflicting kernel modules
cat << EOF | sudo tee --append /etc/modprobe.d/blacklist.conf
blacklist vga16fb
blacklist nouveau
blacklist rivafb
blacklist nvidiafb
blacklist rivatv
EOF

GRUB_CMDLINE_LINUX="modprobe.blacklist=nouveau"
sudo grub2-mkconfig -o /boot/grub2/grub.cfg

cd /opt/gpu_support

# install cuda driver
#curl -O https://developer.download.nvidia.com/compute/cuda/repos/rhel7/x86_64/cuda-repo-rhel7-8.0.61-1.x86_64.rpm
sudo rpm -i https://s3.amazonaws.com/falcon-scorpius-assets/packages/newrpm/cuda-repo-rhel7-8.0.61-1.x86_64.rpm


sudo rpm -i cuda-repo-rhel7-8.0.61-1.x86_64.rpm
sudo yum clean all
sudo yum -y install cuda-8-0.x86_64

# install nvdia driver
# for now going with the driver installed with cuda
#curl -O http://us.download.nvidia.com/XFree86/Linux-x86_64/367.106/NVIDIA-Linux-x86_64-367.106.run
#sudo /bin/bash ./NVIDIA-Linux-x86_64-367.106.run -s

sudo bash -c "cat > /etc/ld.so.conf.d/cuda-lib64.conf << EOF
/usr/local/cuda/lib64
EOF"
