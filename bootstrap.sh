#!/bin/sh

cp -f ${JIRA_INSTALL}/conf/server.xml.org ${JIRA_INSTALL}/conf/server.xml
sed -i -e "4s/%proxyName%/${JIRA_PROXY_NAME}/" ${JIRA_INSTALL}/conf/server.xml
sed -i -e "4s/%proxyPort%/${JIRA_PROXY_PORT}/" ${JIRA_INSTALL}/conf/server.xml
sed -i -e "4s/%scheme%/${JIRA_SCHEME}/" ${JIRA_INSTALL}/conf/server.xml
sed -i -e "4s/%secure%/${JIRA_SECURE}/" ${JIRA_INSTALL}/conf/server.xml

${JIRA_INSTALL}/bin/catalina.sh run
