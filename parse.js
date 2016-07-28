#!/usr/bin/env node
var fs = require('fs');
var data = require('./data.json');
var jiraUsername = process.env.JIRA_USER

var userName = process.argv[2] || "";
var day = new Date(process.argv[3]) || new Date("2016-07-26");
function rightPad(str, len,separator=" ") {
    let pad = Array(len).join(separator);
    return (pad + str).slice(str.length)
}
function getUserWorklogs(userName) {
    var issues = data.issues;
    var lastUpdatedIssues = issues.map(i=> {
        return {key: i.key, summary: i.fields.summary, worklogs: i.fields.worklog.worklogs}
    });

    var issuesWithUserWorklog = lastUpdatedIssues.map(i=> {
        return {issueKey: i.key, summary: i.summary, worklogs: i.worklogs.filter(w => w.author.name === userName)}
    }).filter(i=>i.worklogs.length > 0);

    issuesWithUserWorklog.forEach(i=>i.worklogs = i.worklogs.filter(w=>isFromDay(w, day)));
    issuesWithUserWorklog = issuesWithUserWorklog.filter(i=>i.worklogs.length > 0);
    return issuesWithUserWorklog
}
function isFromDay(worklog, day) {
    let nextDay = new Date(day.getTime() + 86400000);
    let worklogStarted = new Date(worklog.started);
    return (worklogStarted.getTime() >= day.getTime()) && (worklogStarted.getTime() < nextDay.getTime());
}

function printOutput(data) {
    data.forEach(d=>{console.log(formatIsse(d));console.log(rightPad("+",80,"-"));});
}
function formatIsse(issue) {
    return `${rightPad(issue.issueKey, 6)}: ${rightPad(issue.summary.slice(0, 30), 30)} ${formatWorklogs(issue.worklogs)}`
}
function formatWorklogs(worklogs) {
    let output = `\t`;
    output += worklogs.map(worklog=>`${worklog.timeSpent} ${worklog.comment}`);
    return output
}
var worklogs = getUserWorklogs(userName);
printOutput(worklogs);



