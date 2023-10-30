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

# Install Text generation web UI
conda create -n textgen python=3.11 -y
conda activate textgen

git clone https://github.com/oobabooga/text-generation-webui.git
cd text-generation-webui

pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121
conda install -y -c "nvidia/label/cuda-12.1.0" cuda-runtime
# pip install -r requirements.txt
pip install -r requirements_nowheels.txt

# Create start_textgen_webui.sh
cat << "EOF" > start_textgen_webui.sh
#!/bin/bash
eval "$(/root/miniconda/bin/conda shell.bash hook)"
conda activate textgen
nohup python server.py --listen --trust-remote-code --api &
EOF

chmod +x start_textgen_webui.sh

# Setup Crontab
cat << EOF > crontab.txt
@reboot /bin/bash /root/text-generation-webui/start_textgen_webui.sh
EOF

crontab crontab.txt

# Start Text generation web UI
/bin/bash /root/text-generation-webui/start_textgen_webui.sh

