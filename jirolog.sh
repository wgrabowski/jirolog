#!/usr/bin/env bash
declare -A JQ_FILTERS;
JIROLOG_HOME=$(readlink -f `dirname $0`);
CONFIG_PATH=$JIROLOG_HOME'/jira.properties'
source "$CONFIG_PATH";
DATE_TODAY=$(date '+%Y-%m-%d');
DATE_YESTERDAY=$(date -d "12 hours ago" '+%Y-%m-%d');

JQ_FILTERS['verbose']='.issues | .[] | .key+"\n\t Status: "+.fields.status.name+"\n\tSummary: "+.fields.summary + "\n\t"+"   Link: https://'${JIRA_HOSTNAME}'/browse/"+.key+"\n\n"';
JQ_FILTERS['minimal']='.issues | .[] | .key';
JQ_FILTERS['default']='.issues | .[] | .key+" "+.fields.summary+"  => "+.fields.status.name';
OUTPUT_STYLE="default";

# $1 from date
# $2 to date
get_logs_from_date(){
JQL_QUERY='status%20changed%20by%20currentUser()%20after%20"'$1'%2000:00"%20before%20"'$2'%2023:59"%20and%20workLogAuthor%20=%20currentUser()%20and%20worklogDate%20>=%20'$1'%20and%20worklogDate%20<=%20'$2'%20ORDER%20BY%20status%20DESC'    
URL="https://${JIRA_HOSTNAME}/rest/api/2/search?jql=$JQL_QUERY&fields=summary,status";
curl -s -u "${JIRA_USERNAME}:${JIRA_PASSWORD}" -X GET -H 'Content-Type: application/json' --insecure "$URL" 
}

USAGE='Usage: $0 <date> [--minimal | --simple]'



if [ "$#" == "0" ]; then
	echo "$USAGE"
	exit 1
fi

while (( "$#" )); do

case $1 in
    today | t)
    FROM_DATE="$DATE_TODAY"
    TO_DATE="$DATE_TODAY"
    DATE_LABEL="Today"
    ;;
    yesterday | y)
    FROM_DATE="$DATE_YESTERDAY"
    TO_DATE="$DATE_YESTERDAY"
    DATE_LABEL="Yesterday"
    ;;
    --date | -d)
    FROM_DATE="$2"
    TO_DATE="$2"
    DATE_LABEL="$2"
    shift;
    ;;
    --verbose)
    OUTPUT_STYLE="verbose"
    ;;
    --minimal)
    OUTPUT_STYLE="minimal"
    ;;
    *)
    echo "$USAGE"
    exit 
    ;;
    esac
shift
done
echo "Tasks touched by me $DATE_LABEL"
get_logs_from_date "$FROM_DATE" "$TO_DATE" | jq -r "${JQ_FILTERS[$OUTPUT_STYLE]}"
