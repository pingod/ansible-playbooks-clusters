source /etc/environment
export HADOOP_HOME={{hadoop_path}}/current
export HIVE_HOME=$HADOOP_HOME/hive-{{ hive_version }}
export PATH=$HIVE_HOME/bin:$PATH
export CLASSPATH=$CLASSPATH.:$HIVE_HOME/lib
export HIVE_CONF_DIR={{ hive_path }}/hive-{{ hive_version }}/conf
if ! grep -q "$HIVE_HOME/bin" /etc/environment; then
    echo "PATH=\"$PATH\"" > /etc/environment
    source /etc/environment
fi
if [[ -f "$HIVE_HOME/lib/guava-19.0.jar" ]]; then
    rm $HIVE_HOME/lib/guava-*.jar
    cp $HADOOP_HOME/share/hadoop/hdfs/lib/guava-*.jar $HIVE_HOME/lib/
    # wget -P $HIVE_HOME/lib/ https://jdbc.postgresql.org/download/postgresql-42.2.24.jar  # very important to use a higher jdbc version of postgres if the running one is >13 and poses problems
fi
