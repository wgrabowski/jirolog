#!/bin/env bash
CONFIG_PATH='jira.properties'
source $CONFIG_PATH;
echo $JIRA_USERNAME
#URL="https://${JIRA_HOSTNAME}/rest/api/2/search?jql=status+%21%3D+Closed+AND+status+%21%3D+Resolved+AND+assignee+%3D+${JIRA_USERNAME}"
URL="https://${JIRA_HOSTNAME}/rest/agile/latest/board/34/issue?jql=updated%20%3E%20startOfDay()%20and%20updated%20%3C%20endOfDay()&fields=worklogs"
echo "curl -D- -u ${JIRA_USERNAME}:${JIRA_PASSWORD} -X GET -H 'Content-Type: application/json' --insecure $URL"
curl -D- -u "${JIRA_USERNAME}:${JIRA_PASSWORD}" -X GET -H 'Content-Type: application/json' --insecure "$URL"
