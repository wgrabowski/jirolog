#!/bin/env bash
JIROLOG_HOME=$(dirname $0);
CONFIG_PATH=$JIROLOG_HOME'/jira.properties'
echo $JIROLOG_HOME
JIROLOG_PARSER="$JIROLOG_HOME/parse.js"
source $CONFIG_PATH;
DAY_LABEL="today";
DATE_TODAY=`date +"%Y-%m-%d"`;
DATE_YESTERDAY=`date -d "12 hours ago" '+%Y-%m-%d'`

get_logs_from_date(){
JQL_QUERY="timespent%20>%200%20ORDER%20BY%20updatedDate&fields=summary,worklog"
URL="https://${JIRA_HOSTNAME}/rest/agile/latest/board/$JIRA_BOARD_ID/issue?jql=$JQL_QUERY"
curl -D- -s -u "${JIRA_USERNAME}:${JIRA_PASSWORD}" -X GET -H 'Content-Type: application/json' --insecure "$URL" -o data.json >/dev/null
echo "JIROLOG"
echo "Amount Work logged by $JIRA_USERNAME in $JIRA_HOSTNAME $DAY_LABEL:";

"$JIROLOG_PARSER" "${JIRA_USERNAME}" "$1";
}

USAGE="Usage: $0 [--today | -t | --yesterday | -y| --date <date>"

if [ "$#" == "0" ]; then
	echo "$USAGE"
	exit 1
fi

while (( "$#" )); do

case $1 in
    --today|-t)
       get_logs_from_date "$DATE_TODAY"
    ;;
    --yesterday | -y)
        get_logs_from_date "$DATE_YESTERDAY"
        ;;
    --date | -d)
    get_logs_from_date "$2"
    shift
    ;;
    *)
    echo "$USAGE"
    shift
    ;;
    esac
shift

done