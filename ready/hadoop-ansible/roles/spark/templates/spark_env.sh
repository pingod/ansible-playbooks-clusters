source /etc/environment
export HADOOP_HOME={{hadoop_path}}/current
export HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop
export SPARK_HOME=$HADOOP_HOME/spark-{{spark_version}}
export PATH=$SPARK_HOME/bin:$PATH
export LD_LIBRARY_PATH=$HADOOP_HOME/lib/native:$LD_LIBRARY_PATH
if ! grep -q "$SPARK_HOME/bin" /etc/environment; then
    echo "PATH=\"$PATH\"" > /etc/environment
    source /etc/environment
fi