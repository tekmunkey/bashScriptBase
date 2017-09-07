#
#
# Provides quick-access support for common system user lookups
#   USAGE:  source ./path/to/scriptCLI.sh
#
#

#!/bin/bash
trap "exit 1" TERM
export USERS_PID=$$ # use 'kill -s TERM $USERS_PID' to pop this from anywhere in the script

#
# scriptUsers can/should die as soon as possible since it never consumes scriptHelp
#
if [ "${BASH_SOURCE[0]}" == "${0}" ]; then
    # script is being executed, not sourced - exit with error code
    echo "${0##*/} is intended to be included via source, not executed via command line."
    exit 1
fi

function getUserID
{
    #
    # Queries the local system to return a user id.
    # Returns the user's numeric ID, or -1 if the user does not exist
    #
    # * $1 may be either a numeric user id or a string user account name.
    #
    local -i userID=`id -u "${1}" 2>/dev/null || echo -1`
    echo ${userID}
}

function getUserName
{
    #
    # Queries the local system to return a user name, given a user's account name.
    # Returns the user's string account name, or -1 if the user does not exist
    #
    # * $1 may be either a numeric user id or a string user account name.
    #
    local userName=`id -nu "${1}" 2>/dev/null || echo -1`
    echo "${userName}"
}

function isUser
{
    #
    # Queries the local system to return a 1 or 0 (boolean) indicating whether a 
    # specified user exists.  Returns 1 if the user exists or 0 if not.
    #
    # * $1 may be either a numeric user id or a string user account name.
    #
    local userID=`id -u "${1}" 2>/dev/null || echo -1`
    local -i r=0
    if [ "${userID}" != "-1" ]; then
        r=1
    fi
    echo "${r}"
}

function isUserRoot
{
    #
    # Queries the local system to return a 1 or 0 (boolean) indicating whether a 
    # specified user is root/superuser (retrieves the user's numeric id and tests 
    # if that id is equal to 0)
    #
    # * $1 may be either a numeric user id or a string user account name.
    #
    local -i rootID=0
    local -i userID=`id -u "${1}" 2>/dev/null || echo -1`
    local -i r=0
    if [ "${userID}" -eq "${rootID}" ]; then
        r=1
    fi
    echo "${r}"
}