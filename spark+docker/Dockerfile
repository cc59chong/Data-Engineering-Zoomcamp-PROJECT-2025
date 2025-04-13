# Use the Bitnami Spark base image
FROM bitnami/spark:latest

# Switch to root user for system installations
USER root

# Configure Hadoop and Spark environment
RUN echo "export HADOOP_OPTS=\"-Dhadoop.security.authentication=simple\"" >> /opt/bitnami/spark/conf/spark-env.sh && \
    echo "export HADOOP_USER_NAME=root" >> /opt/bitnami/spark/conf/spark-env.sh && \
    echo "export HADOOP_HOME=/opt/bitnami/hadoop" >> /opt/bitnami/spark/conf/spark-env.sh

# Install Python and dependencies
RUN apt-get update && \
    apt-get install -y python3 python3-pip && \
    ln -s /usr/bin/python3 /usr/bin/python

# Set up Ivy cache
ENV IVY_HOME=/app/.ivy2
RUN mkdir -p ${IVY_HOME} && chmod 775 ${IVY_HOME}

# Switch back to non-root user for application files
USER 1001

# Install Python packages
RUN pip install pyspark pandas

# Set working directory
WORKDIR /app

# Copy application files (as non-root user)
COPY --chown=1001:root spark_run_cleaning.py ./
COPY --chown=1001:root gcp/gcs-connector-hadoop3-latest.jar ./
COPY --chown=1001:root gcp/credentials/ ./credentials/
COPY --chown=1001:root conf/core-site.xml /opt/bitnami/spark/conf/

# Environment variables (non-sensitive)
ENV SPARK_CLASSPATH="/app/gcs-connector-hadoop3-latest.jar" \
    HADOOP_CONF_DIR="/opt/bitnami/spark/conf"

# Entrypoint with credentials passed at runtime
ENTRYPOINT ["spark-submit", \
    "--master", "local[*]", \
    "--conf", "spark.hadoop.google.cloud.auth.service.account.enable=true", \
    "--conf", "spark.hadoop.google.cloud.auth.service.account.json.keyfile=/app/credentials/gcp_credentials.json", \
    "--conf", "spark.driver.extraJavaOptions=-Divy.home=/app/.ivy2", \
    "--conf", "spark.executor.extraJavaOptions=-Divy.home=/app/.ivy2", \
    "--jars", "gcs-connector-hadoop3-latest.jar", \
    "spark_run_cleaning.py"]