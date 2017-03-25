#!/bin/sh

cp -f ${JIRA_INSTALL}/conf/server.xml.org ${JIRA_INSTALL}/conf/server.xml
sed -i -e "s/%proxyName%/${JIRA_PROXY_NAME}/g" ${JIRA_INSTALL}/conf/server.xml
sed -i -e "s/%proxyPort%/${JIRA_PROXY_PORT}/g" ${JIRA_INSTALL}/conf/server.xml
sed -i -e "s/%scheme%/${JIRA_SCHEME}/g" ${JIRA_INSTALL}/conf/server.xml
sed -i -e "s/%secure%/${JIRA_SECURE}/g" ${JIRA_INSTALL}/conf/server.xml

${JIRA_INSTALL}/bin/catalina.sh run
