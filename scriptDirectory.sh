#
# This script does nothing but contain directory references
#   USAGE:  source ./path/to/scriptDirectory.sh
#

#!/bin/bash

#
# directoryIndex can/should die as soon as possible since it never consumes scriptHelp
#
if [ "${BASH_SOURCE[0]}" == "${0}" ]; then
    # script is being executed, not sourced - exit with error code
    echo "${0##*/} is intended to be included via source, not executed via command line."
    exit 1
fi

#
# A value telling consumers that directoryIndex is included, so we don't over-include the script
#
declare -i scriptDirectory=1

#
# Returns the calling script's name only
#
function thisScript
{
    echo "${BASH_SOURCE[1]##*/}"
}

#
# Returns the calling script's Directory only
#
function thisScriptDir
{
    echo "$( cd "${BASH_SOURCE[1]%/*}" && pwd )"
}

#
# Returns the calling script's Fully Qualified Path (FQP)
#
function thisFQP
{
    echo "$( cd "${BASH_SOURCE[1]%/*}" && pwd )/${BASH_SOURCE[1]##*/}"
}

#
# Returns the script base includes directory.
#
function includesDir
{
    echo "$( cd "${BASH_SOURCE[0]%/*}" && pwd )"
}