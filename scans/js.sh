#!/bin/bash

#  onliner to extract endpoints from JS files of a given host

url -L -k -s https://www.example.com | tac | sed "s#\\\/#\/#g" | egrep -o "src['\"]?\s*[=:]\s*['\"]?[^'\"]+.js[^'\"> ]*" | awk -F '//' '{if(length($2))print "https://"$2}' | sort -fu | xargs -I '%' sh -c "curl -k -s \"%\" | sed \"s/[;}\)>]/\n/g\" | grep -Po \"(['\\\"](https?:)?[/]{1,2}[^'\\\"> ]{5,})|(\.(get|post|ajax|load)\s*\(\s*['\\\"](https?:)?[/]{1,2}[^'\\\"> ]{5,})\"" | awk -F "['\"]" '{print $2}' | sort -fu

# using linkfinder
function ejs() {
   URL=$1;
   curl -Lks $URL | tac | sed "s#\\\/#\/#g" | egrep -o "src['\"]?\s*[=:]\s*['\"]?[^'\"]+.js[^'\"> ]*" | sed -r "s/^src['\"]?[=:]['\"]//g" | awk -v url=$URL '{if(length($1)) if($1 ~/^http/) print $1; else if($1 ~/^\/\//) print "https:"$1; else print url"/"$1}' | sort -fu | xargs -I '%' sh -c "echo \"\n##### %\";wget --no-check-certificate --quiet \"%\"; basename \"%\" | xargs -I \"#\" sh -c 'linkfinder.py -o cli -i #'"
}

# with file download (the new best one):
# but there is a bug if you don't provide a root url
# (ex: https://www.example.com/dir/subdir/aaaa will fuck relative url)
function ejs() {
   URL=$1
   curl -Lks $URL | tac | sed "s#\\\/#\/#g" | egrep -o "src['\"]?\s*[=:]\s*['\"]?[^'\"]+.js[^'\"> ]*" | sed -r "s/^src['\"]?[=:]['\"]//g" | awk -v url=$URL '{if(length($1)) if($1 ~/^http/) print $1; else if($1 ~/^\/\//) print "https:"$1; else print url"/"$1}' | sort -fu | xargs -I '%' sh -c "echo \"\n##### %\";wget --no-check-certificate --quiet \"%\";curl -Lks \"%\" | sed \"s/[;}\)>]/\n/g\" | grep -Po \"('#####.*)|(['\\\"](https?:)?[/]{1,2}[^'\\\"> ]{5,})|(\.(get|post|ajax|load)\s*\(\s*['\\\"](https?:)?[/]{1,2}[^'\\\"> ]{5,})\" | sort -fu" | tr -d "'\""
}

# debug mode and absolute/relative urls support:
function ejs() {
   URL=$1;
   curl -Lks $URL | tac | sed "s#\\\/#\/#g" | egrep -o "src['\"]?\s*[=:]\s*['\"]?[^'\"]+.js[^'\"> ]*" | sed -r "s/^src['\"]?[=:]['\"]//g" | awk -v url=$URL '{if(length($1)) if($1 ~/^http/) print $1; else if($1 ~/^\/\//) print "https:"$1; else print url"/"$1}' | sort -fu | xargs -I '%' sh -c "echo \"'##### %\";curl -k -s \"%\" | sed \"s/[;}\)>]/\n/g\" | grep -Po \"('#####.*)|(['\\\"](https?:)?[/]{1,2}[^'\\\"> ]{5,})|(\.(get|post|ajax|load)\s*\(\s*['\\\"](https?:)?[/]{1,2}[^'\\\"> ]{5,})\" | sort -fu" | tr -d "'\""
}

# debug mode:
curl -L -k -s https://www.example.com | tac | sed "s#\\\/#\/#g" | egrep -o "src['\"]?\s*[=:]\s*['\"]?[^'\"]+.js[^'\"> ]*" | awk -F '//' '{if(length($2))print "https://"$2}' | sort -fu | xargs -I '%' sh -c "echo \"'##### %\";curl -k -s \"%\" | sed \"s/[;}\)>]/\n/g\" | grep -Po \"('#####.*)|(['\\\"](https?:)?[/]{1,2}[^'\\\"> ]{5,})|(\.(get|post|ajax|load)\s*\(\s*['\\\"](https?:)?[/]{1,2}[^'\\\"> ]{5,})\" | sort -fu" | awk -F "['\"]" '{print $2}'

# first version
function ejs() {
  curl -L -k -s "$1" | tac | sed "s#\\\/#\/#g" | egrep -o "src['\"]?\s*[=:]\s*['\"]?[^'\"]+.js[^'\"> ]*" | awk -F '//' '{if(length($2))print "https://"$2}' | sort -fu | xargs -I '%' sh -c "curl -k -s \"%\" | sed \"s/[;}\)>]/\n/g\" | grep -Po \"(['\\\"](https?:)?[/]{1,2}[^'\\\"> ]{5,})|(\.(get|post|ajax|load)\s*\(\s*['\\\"](https?:)?[/]{1,2}[^'\\\"> ]{5,})\"" | awk -F "['\"]" '{print $2}' | sort -fu
}
