#!/bin/env bash
CONFIG_PATH='jira.properties'
source $CONFIG_PATH;
FROM_DATE=`date +"%Y-%m-%d"`;
FROM_DATE="$1";

#URL="https://${JIRA_HOSTNAME}/rest/api/2/search?jql=status+%21%3D+Closed+AND+status+%21%3D+Resolved+AND+assignee+%3D+${JIRA_USERNAME}"
#JQL_QUERY="updated%20>=%20%27$FROM_DATE%2000:00%27%20and%20updated%20<=%20%27$FROM_DATE%2023:59%27&fields=summary,worklog"
JQL_QUERY="timespent%20>%200%20ORDER%20BY%20updatedDate&fields=summary,worklog"
URL="https://${JIRA_HOSTNAME}/rest/agile/latest/board/34/issue?jql=$JQL_QUERY"
echo "$URL"
curl -D- -s -u "${JIRA_USERNAME}:${JIRA_PASSWORD}" -X GET -H 'Content-Type: application/json' --insecure "$URL" -o data.json >/dev/null
echo "JIROLOG"
echo "Amount Work logged by $JIRA_USERNAME in $JIRA_HOSTNAME today:";

./parse.js "${JIRA_USERNAME}" "$FROM_DATE";