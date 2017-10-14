# Copy line by line and paste to an interactive shell

# Update system
#sudo apt-get update && sudo apt-get dist-upgrade

# Install Java
#sudo add-apt-repository ppa:openjdk-r/ppa  
#sudo apt-get update   
#sudo apt-get install openjdk-7-jdk  

# Download & Install Hadoop
# wget http://apache.mirrors.tds.net/hadoop/common/hadoop-2.7.2/hadoop-2.7.2.tar.gz -P ~/Downloads 
#wget http://apache.mirror.cdnetworks.com/hadoop/common/hadoop-2.7.4/hadoop-2.7.4.tar.gz
sudo tar zxvf ~/Downloads/hadoop-* -C /usr/local
sudo mv /usr/local/hadoop-* /usr/local/hadoop

# Configure environment (copy the whole block)
echo "
export JAVA_HOME=$(readlink -f $(which java))
export PATH=\$PATH:\$JAVA_HOME/bin
export HADOOP_HOME=/usr/local/hadoop
export PATH=\$PATH:\$HADOOP_HOME/bin
export HADOOP_CONF_DIR=/usr/local/hadoop/etc/hadoop
" >> ~/.bashrc

# Load configure
source ~/.bashrc
