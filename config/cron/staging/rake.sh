#!/bin/bash

. /projects/alarms/.bashrc
cd /projects/alarms/current

rake $1 > /projects/alarms/shared/cron/$1.last 2>&1