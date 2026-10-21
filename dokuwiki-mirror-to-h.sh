#!/bin/bash

cd ~rsync
# ssh proto
# sudo -u rsync rsync -az --delete -v dokuwiki rsync@h.local.semmy.ru:
# rsync proto
#sudo -u rsync rsync -az --delete -v dokuwiki rsync://h.local.semmy.ru:/dokuwiki
rsync -az --delete -v dokuwiki rsync://h.semmy.ru:/dokuwiki
