
FROM java:openjdk-8-jre
MAINTAINER puchinya

# Configuration variables.
ENV JIRA_HOME     /var/atlassian/application-data/jira
ENV JIRA_INSTALL  /opt/atlassian/jira
ENV JIRA_VERSION  8.1

ENV JIRA_PROXY_NAME="localhost"
ENV JIRA_PROXY_PORT="443"
ENV JIRA_SCHEME="https"
ENV JIRA_SECURE="true"

LABEL Description="This image is used to start Atlassian Jira Software" Vendor="Atlassian" Version="${JIRA_VERSION}"

ENV JIRA_DOWNLOAD_URL https://www.atlassian.com/software/jira/downloads/binary/atlassian-jira-software-${JIRA_VERSION}.tar.gz

ENV MYSQL_VERSION 5.1.38
ENV MYSQL_DRIVER_DOWNLOAD_URL http://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-${MYSQL_VERSION}.tar.gz

# Use the default unprivileged account. This could be considered bad practice
# on systems where multiple processes end up being executed by 'daemon' but
# here we only ever run one process anyway.
ENV RUN_USER            daemon
ENV RUN_GROUP           daemon

# Install Atlassian JIRA and helper tools and setup initial home
# directory structure.
RUN set -x \
    && apt-get update --quiet \
    && apt-get install --quiet --yes --no-install-recommends xmlstarlet \
    && apt-get install --quiet --yes --no-install-recommends -t jessie-backports libtcnative-1 \
    && apt-get clean \
    && mkdir -p                "${JIRA_HOME}" \
    && mkdir -p                "${JIRA_HOME}/caches/indexes" \
    && chmod -R 700            "${JIRA_HOME}" \
    && chown -R daemon:daemon  "${JIRA_HOME}" \
    && mkdir -p                "${JIRA_INSTALL}/conf/Catalina" \
    && curl -Ls                "${JIRA_DOWNLOAD_URL}" | tar -xz --directory "${JIRA_INSTALL}" --strip-components=1 --no-same-owner \
    && curl -Ls                "${MYSQL_DRIVER_DOWNLOAD_URL}" | tar -xz --directory "${JIRA_INSTALL}/lib" --strip-components=1 --no-same-owner "mysql-connector-java-${MYSQL_VERSION}/mysql-connector-java-${MYSQL_VERSION}-bin.jar" \
    && chmod -R 700            "${JIRA_INSTALL}/conf" \
    && chmod -R 700            "${JIRA_INSTALL}/logs" \
    && chmod -R 700            "${JIRA_INSTALL}/temp" \
    && chmod -R 700            "${JIRA_INSTALL}/work" \
    && chown -R ${RUN_USER}:${RUN_GROUP}  "${JIRA_INSTALL}/conf" \
    && chown -R ${RUN_USER}:${RUN_GROUP}  "${JIRA_INSTALL}/logs" \
    && chown -R ${RUN_USER}:${RUN_GROUP}  "${JIRA_INSTALL}/temp" \
    && chown -R ${RUN_USER}:${RUN_GROUP}  "${JIRA_INSTALL}/work" \
    && sed --in-place          "s/java version/openjdk version/g" "${JIRA_INSTALL}/bin/check-java.sh" \
    && echo -e                 "\njira.home=$JIRA_HOME" >> "${JIRA_INSTALL}/atlassian-jira/WEB-INF/classes/jira-application.properties" \
    && touch -d "@0"           "${JIRA_INSTALL}/conf/server.xml"

# Use the default unprivileged account. This could be considered bad practice
# on systems where multiple processes end up being executed by 'daemon' but
# here we only ever run one process anyway.
USER ${RUN_USER}:${RUN_GROUP}

# Expose default HTTP connector port.
EXPOSE 8080

ADD ./server.xml ${JIRA_INSTALL}/conf/server.xml.org
ADD ./bootstrap.sh ${JIRA_INSTALL}/bin/bootstrap.sh

# Set volume mount points for installation and home directory. Changes to the
# home directory needs to be persisted as well as parts of the installation
# directory due to eg. logs.
VOLUME ["${JIRA_INSTALL}", "${JIRA_HOME}"]

# Set the default working directory as the installation directory.
WORKDIR ${JIRA_INSTALL}

# Run Atlassian Jira as a foreground process by default.
CMD ["sh", "./bin/bootstrap.sh"]
