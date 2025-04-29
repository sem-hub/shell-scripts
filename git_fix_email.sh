#!/bin/bash

git filter-branch --commit-filter '
        if [ "$GIT_COMMITTER_EMAIL" = "sem33@yandex-team.ru" ];
        then
                GIT_COMMITTER_EMAIL="sem@semmy.ru";
                GIT_AUTHOR_EMAIL="sem@semmy.ru";
                git commit-tree "$@";
        else
                git commit-tree "$@";
        fi' --tag-name-filter cat -- --all
