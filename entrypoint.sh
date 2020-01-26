#!/bin/sh

source "${DOCKER_USER_HOME}"/perl5/perlbrew/etc/bashrc
source "${DOCKER_USER_HOME}"/.system.env

while true
    do
        "${DOCKER_USER_HOME}"/perl5/perlbrew/perls/perl-5.22.1/bin/ubic-watchdog ubic.watchdog \
        >>"${DOCKER_USER_HOME}"/ubic/log/watchdog.log 2>>"${DOCKER_USER_HOME}"/ubic/log/watchdog.err.log
        sleep 60
    done
