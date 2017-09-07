#
# Examples of bashScriptBase usage
#

#
# This is titled badExample because it shows you how to write code that 
# executes operations directly out of commandline switch processing functions.
# This obliterates (but not entirely) the ability to error check, and as you 
# can see if you run the test cases it allows the script to partially execute 
# before it errors on a bad commandline argument.
#
# This convention is still fine for quick and dirty scripts, such as simple backups, 
# but not for more complex operations and definitely not for anything requires 
# any kind of mutual variable validation or error checking.
#

#!/bin/bash
# the next line makes the script die if anything it does throws an error or returns false
set -e

#!/bin/bash
trap "exit 1" TERM
export BADEX_PID=$$ # use 'kill -s TERM $HELP_PID' to pop this from anywhere in the script

# include but don't overinclude the directoryIndex.sh
if [ ! ${scriptDirectory} ]; then
    source "$( cd "${BASH_SOURCE[0]%/*}" && pwd )/scriptDirectory.sh"
fi

# include but don't overinclude the stringExtends.sh
if [ ! ${stringExtends} ]; then
    source "$(thisScriptDir)/devUtils/stringExtends.sh"
fi

# include but don't overinclude the adaptiveDisplay.sh
if [ ! ${adaptiveDisplay} ]; then
    source "$(thisScriptDir)/devUtils/adaptiveDisplay.sh"
fi

# include but don't overinclude the scriptCLI.sh
if [ ! ${scriptCLI} ]; then
    source "$(thisScriptDir)/scriptCLI.sh"
fi

# include but don't overinclude the scriptHelp.sh
if [ ! ${scriptHelp} ]; then
    source "$(thisScriptDir)/scriptHelp.sh"
fi

headerHelpEntries+=("${ansi_setBold}* The order in which parameters are sent into this script is not important. *${ansi_resetAll}")

function myUnrecognizedParameterHandler
{
    # 
    # $1 is the unrecognized parameter name and value
    #
    headerHelpEntries+=("${ansi_foreRed}*** Commandline Error ***${ansi_resetAll}")
    printHelp "    Unrecognized parameter on commandline:  ${1}"
    # the printHelp function automatically exits
}
# First dump the default CLI handler
cliUnrecognizedParameterHandlers=("${cliUnrecognizedParameterHandlers[@]:1}")
# Now add our custom handler
cliUnrecognizedParameterHandlers+=("myUnrecognizedParameterHandler")

function mySwitchParameterHandler
{
    #
    # $1 is the parameter supplied
    #
    echo "    You toggled the switch parameter ${1} when you launched ${0}!"
}
cliHandlers+=("-s|--switch|--switchParameter mySwitchParameterHandler")
bodyHelpEntries+=("    ${ansi_setBold}-s|--switch|--switchParameter${ansi_resetAll}")
bodyHelpEntries+=("        A demo showing how to deploy a simple on/off or toggle style switch parameter in your script.")

function myValueParameterHandler
{
    #
    # $1 is the whole parameter supplied
    #
    local parameterName="${1%=*}"
    local parameterValue="${1#*=}"
    echo "    You passed the parameter ${parameterName} with the value ${parameterValue} when you launched ${0}!"
}
cliHandlers+=("-v=*|--value=*|--valueParameter=* myValueParameterHandler")
bodyHelpEntries+=("    ${ansi_setBold}-v=*|--value=*|--valueParameter=*${ansi_resetAll}")
bodyHelpEntries+=("        A demo showing how to deploy a simple value parameter in your script.")
bodyHelpEntries+=("        If you want to pass multiple pieces or a value with spaces in it, your value must be surrounded by single or double quotes at the commandline.")

#
# Call to scriptCLI.sh to process the command line parameters and therefore execute the whole script.
#
processCLIParameters

# test cases for the commandline
#
# The next test case works!
# ./badExample.sh --switchParameter
#
# The next test case works!
# ./badExample.sh --valueParameter=testValue
#
# The next test case also works!
# ./badExample.sh --valueParameter="testValue0 testValue1 testValue2"
#
# The next test works!
# ./badExample.sh --switchParameter --valueParameter=testValue
#
# The next test case works!
# ./badExample.sh --switchParameter --valueParameter="testValue0 testValue1 testValue2"
#
# The next test case works!
# * We don't need to worry about the order of parameter inputs because of the way scriptCLI.sh operates
# * Notice how, because of how this script is designed, the valueParameter event fires before the switchParameter event.
# ./badExample.sh --valueParameter="testValue0 testValue1 testValue2" --switchParameter
#
# The next test case should not and does not work!
# * This test case doesn't work because --switchParameter isn't configured to be recognized with an =*
# ./badExample.sh --switchParameter="this parameter shouldn't take any values!"
#
# The next test case should not and does not work!
# * This test case doesn't work because --switchParameter isn't configured to be recognized with an =*
# * As you can see, the script fails and dies without partially executing even though --valueParameter is valid...
#   ... this is because of the order of parameter inputs
# ./badExample.sh --switchParameter="this parameter shouldn't take any values!" --valueParameter=testValue
#
# The next test case should not and does not work!
# * This test case doesn't work because --valueParameter isn't configured to be recognized without an =*
# * As you can see, the script fails and dies after partially executing even though --valueParameter is invalid...
#   ... this is because of the order of parameter inputs.  The valid --switchParameter causes execution of that bit
# ./badExample.sh --switchParameter --valueParameter
#
# Hopefully this is enough test cases to demonstrate how and why even though this code works,
# it's simply a bad programming style
#