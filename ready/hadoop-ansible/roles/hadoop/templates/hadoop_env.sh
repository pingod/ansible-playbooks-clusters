export HADOOP_HOME={{hadoop_path}}/current
export PATH=$HADOOP_HOME/sbin:$HADOOP_HOME/bin:$PATH
export HADOOP_LOG_DIR={{ hadoop_log_path }}
export YARN_LOG_DIR=$HADOOP_LOG_DIR
jdk_version=$(ls -al {{jvm_home}}|grep "^d"|grep "java"|awk '{print$NF}')
if ! grep -q "export JAVA_HOME=/" {{hadoop_config_path}}/hadoop-env.sh; then
    echo "export JAVA_HOME={{ jvm_home }}/$jdk_version" >> {{hadoop_config_path}}/hadoop-env.sh;
fi
if ! grep -q "$HADOOP_HOME/bin" /etc/environment; then
    echo "PATH=\"$PATH\"" > /etc/environment
    source /etc/environment
fi