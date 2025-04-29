#!/bin/bash -

LIMIT=5

# one of (hour, day, week, month, year, all)
PERIOD="year"

clear
for subreddit in neovim vim vimplugins vimporn;
do
        echo "$subreddit"
        LINK="https://www.reddit.com/r/${subreddit}/top/.json?t=${PERIOD}&limit=${LIMIT}"
        curl -s $LINK|python -mjson.tool|grep permalink|  cut -d\" -f4|sed 's!^!https://www.reddit.com!'
        sleep 10
done
