#!/bin/bash
set -x
exec 3>&1 4>&2
trap 'exec 2>&4 1>&3' 0 1 2 3
exec 1>/root/tf.log 2>&1

# Extend Boot Volume
/usr/libexec/oci-growfs -y

# Setup Firewall Rules
firewall-offline-cmd --zone=public --add-port=7860/tcp
systemctl restart firewalld

# Update
# dnf update -y # Time Consuming

# Install Library
dnf install curl gcc openssl-devel bzip2-devel libffi-devel zlib-devel wget make git -y

# Install Python
wget https://www.python.org/ftp/python/3.10.6/Python-3.10.6.tgz
tar -xf Python-3.10.6.tgz
cd Python-3.10.6

./configure --enable-optimizations
sudo make altinstall

echo 'export PATH="/usr/local/bin:$PATH"' >> ~/.bashrc 
source ~/.bashrc

ln -s /usr/local/bin/python3.10 /usr/local/bin/python3
ln -s /usr/local/bin/python3.10 /usr/local/bin/python
ln -s /usr/local/bin/pip3.10 /usr/local/bin/pip3
ln -s /usr/local/bin/pip3.10 /usr/local/bin/pip

# Install Miniconda
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda.sh
bash ~/miniconda.sh -b -p /root/miniconda
eval "$(/root/miniconda/bin/conda shell.bash hook)"
conda init
conda config --set auto_activate_base false

cd /root

# Install Stable Diffusion web UI
# https://github.com/AUTOMATIC1111/stable-diffusion-webui
# python -m venv sd-webui
# source ./sd-webui/bin/activate

# wget -q https://raw.githubusercontent.com/AUTOMATIC1111/stable-diffusion-webui/master/webui.sh
# sed -i 's/can_run_as_root=0/can_run_as_root=1/g' webui.sh
# chmod +x webui.sh
# nohup ./webui.sh --listen &

# Install Fooocus
# https://github.com/lllyasviel/Fooocus
conda create -n fooocus_env python=3.11 -y
conda activate fooocus_env

git clone https://github.com/lllyasviel/Fooocus.git
cd Fooocus
pip install pygit2==1.12.2
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121
conda install -y -c "nvidia/label/cuda-12.1.0" cuda-runtime
pip install -r requirements_versions.txt

# Create start_fooocus.sh
cat << EOF > start_fooocus.sh
#!/bin/bash
eval "$(/root/miniconda/bin/conda shell.bash hook)"
conda activate fooocus_env
nohup python entry_with_update.py --listen &
EOF

chmod +x start_fooocus.sh

# Setup Crontab
cat << EOF > crontab.txt
@reboot /bin/bash /root/Fooocus/start_fooocus.sh
EOF

crontab crontab.txt

# Start Fooocus
/bin/bash /root/Fooocus/start_fooocus.sh

