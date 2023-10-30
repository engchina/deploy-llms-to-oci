#!/bin/bash
set -x
exec 3>&1 4>&2
trap 'exec 2>&4 1>&3' 0 1 2 3
exec 1>/root/tf.log 2>&1

# Extend Boot Volume
/usr/libexec/oci-growfs -y

# Setup Firewall Rules
firewall-offline-cmd --zone=public --add-port=7860/tcp
firewall-offline-cmd --zone=public --add-port=8000/tcp
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

# Install FastChat
conda create -n fastchat python=3.11 -y
conda activate fastchat

git clone https://github.com/lm-sys/FastChat.git
cd FastChat

pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121
conda install -y -c "nvidia/label/cuda-12.1.0" cuda-runtime
pip3 install --upgrade pip # enable PEP 660 support
pip3 install -e ".[model_worker,webui]"

# Create start_fastchat.sh
cat << "EOF" > start_fastchat.sh
#!/bin/bash
eval "$(/root/miniconda/bin/conda shell.bash hook)"
conda activate fastchat
nohup python3 -m fastchat.serve.controller &
nohup python3 -m fastchat.serve.model_worker --model-path ${llm_fastchat_model} --model-names "chat,gpt-3.5-turbo,gpt-3.5-turbo-16k,gpt-4,gpt-4-32k,text-embedding-ada-002,text-davinci-003" --controller http://localhost:21001 --worker http://localhost:31000 --port 31000 &
sleep 180
nohup python3 -m fastchat.serve.openai_api_server --host 0.0.0.0 --port 8000 &
nohup python3 -m fastchat.serve.gradio_web_server --host 0.0.0.0 --port 7860 &
EOF

chmod +x start_fastchat.sh

# Setup Crontab
cat << EOF > crontab.txt
@reboot /bin/bash /root/FastChat/start_fastchat.sh
EOF

crontab crontab.txt

# Start FastChat
/bin/bash /root/FastChat/start_fastchat.sh

