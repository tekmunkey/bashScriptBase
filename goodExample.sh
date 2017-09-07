#
# Examples of bashScriptBase usage
#

#
# This is titled goodExample because it shows you how to write code that 
# performs variable-setting and potential error-checking operations 
# directly out of commandline switch processing functions.
#
# As you can see if you run the test cases it allows the script to error and die
# on any bad commandline argument.
#
# This convention is perfect for any and all applications
#

#!/bin/bash
# the next line makes the script die if anything it does throws an error or returns false
set -e

#!/bin/bash
trap "exit 1" TERM
export GOODEX_PID=$$ # use 'kill -s TERM $HELP_PID' to pop this from anywhere in the script

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

#
# A value to indicate whether the switch parameter was specified at the command line or not
#
declare mySwitchVariable
#
# An array style value to contain any value(s) passed into the value parameter at the command line
#
declare -a myValueParameterVariable

function mySwitchParameterHandler
{
    #
    # $1 is the parameter supplied
    #
    mySwitchVariable="${1}"
}
#
# -s and --switch and --switchParameter represent aliases to the same command or parameter
#
cliHandlers+=("-s|--switch|--switchParameter mySwitchParameterHandler")
bodyHelpEntries+=("    ${ansi_setBold}-s|--switch|--switchParameter${ansi_resetAll}")
bodyHelpEntries+=("        A demo showing how to deploy a simple on/off or toggle style switch parameter in your script.")

function myValueParameterHandler
{
    #
    # $1 is the whole parameter supplied
    #
    myValueParameterVariable+="${1}"
}
#
# -v and --value and --valueParameter represent aliases to the same command or parameter
# The =* indicates that we'll take any input the user wishes to give us here.
# * These are case statement patterns
#
cliHandlers+=("-v=*|--value=*|--valueParameter=* myValueParameterHandler")
bodyHelpEntries+=("    ${ansi_setBold}-v=*|--value=*|--valueParameter=*${ansi_resetAll}")
bodyHelpEntries+=("        A demo showing how to deploy a simple value parameter in your script.")
bodyHelpEntries+=("        If you want to pass multiple pieces or a value with spaces in it, your value must be surrounded by single or double quotes at the commandline.")

#
# Call to scriptCLI.sh to process the command line parameters and therefore execute the whole script.
#
processCLIParameters

if [ "${mySwitchVariable}" ]; then
    echo "    You toggled the switch parameter ${mySwitchVariable} when you launched ${0}!"
fi

for valueParameter in "${myValueParameterVariable[@]}"; do
    # So right now valueParameter is a key=value pair - value may be 1 or multiple space-delimited values
    declare pName="${valueParameter%=*}"
    echo ${valueParameter#*=}
    declare -a pValues=("${valueParameter#*=}")
    echo "    You entered the value parameter ${pName} with the following values:"
    for eachValue in "${pValues[@]}"; do
        echo "        ${eachValue}"
    done
done

# test cases for the commandline
#
# The next test case works!
# ./goodExample.sh --switchParameter
#
# The next test case works!
# ./goodExample.sh --valueParameter=testValue
#
# The next test case also works!
# ./goodExample.sh --valueParameter="testValue0 testValue1 testValue2"
#
# The next test works!
# ./goodExample.sh --switchParameter --valueParameter=testValue
#
# The next test case works!
# ./goodExample.sh --switchParameter --valueParameter="testValue0 testValue1 testValue2"
#
# The next test case works!
# * We don't need to worry about the order of parameter inputs because of the way scriptCLI.sh operates
# * Notice how, because of how this script is designed, the order of processing events remains the same
#   regardless of the order of parameter inputs
# ./goodExample.sh --valueParameter="testValue0 testValue1 testValue2" --switchParameter
#
# The next test case should not and does not work!
# * This test case doesn't work because --switchParameter isn't configured to be recognized with an =*
# ./goodExample.sh --switchParameter="this parameter shouldn't take any values!"
#
# The next test case should not and does not work!
# * This test case doesn't work because --switchParameter isn't configured to be recognized with an =*
# * As you can see, the script fails and dies without partially executing even though --valueParameter is valid...
#   ... in this script example that's actually because of design, not just because of input order
# ./goodExample.sh --switchParameter="this parameter shouldn't take any values!" --valueParameter=testValue
#
# The next test case should not and does not work!
# * This test case doesn't work because --valueParameter isn't configured to be recognized without an =*
# * As you can see, the script fails and dies completely even though a valid parameter precedes the invalid
#   ... this is because we're fully processing all the CLI parameters before any execution is performed
# ./goodExample.sh --switchParameter --valueParameter
#
# Hopefully this is enough test cases to demonstrate how and why this is the right way to order events in 
# a script
#