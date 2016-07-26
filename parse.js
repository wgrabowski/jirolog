#!/usr/bin/env node
var fs = require('fs');
var data = require('./data.json');
var jiraUsername = process.env.JIRA_USER

var userName = process.argv[2] || "";
var day = new Date(process.argv[3]) || "2016-07-26;


function getUserWorklogs(userName) {
    var issues = data.issues;
    var lastUpdatedIssues = issues.map(i=> {
        return {key: i.key, worklogs: i.fields.worklog.worklogs}
    });

    var issuesWithUserWorklog = lastUpdatedIssues.map(i=> {
        return {issueKey: i.key, worklogs: i.worklogs.filter(w => w.author.name === userName)}
    }).filter(i=>i.worklogs.length > 0);
    issuesWithUserWorklog.forEach(i=>i.worklogs.filter(w=>isFromDay(w,day)))
    return issuesWithUserWorklog
}
function isFromDay(worklog,day){
    let worklogStarted = new Date(worklog.started);
    return worklogStarted.toTimeString() >= day.toTimeString()
}

function printOutput(data){
    data.forEach(d=>console.log(d));
}

var worklogs = getUserWorklogs(userName);
printOutput(worklogs);


process.stdout.write("kupaaa\n");