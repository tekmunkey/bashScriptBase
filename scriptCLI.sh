#
#
# Provides Command Line Interpretation with a simplified "you write a function and pass in argument pattern and function name" syntax
#   USAGE:  source ./path/to/scriptCLI.sh
#
#

#!/bin/bash
trap "exit 1" TERM
export CLI_PID=$$ # use 'kill -s TERM $CLI_PID' to pop this from anywhere in the script

#
# scriptCLI can/should die as soon as possible since it never consumes scriptHelp
#
if [ "${BASH_SOURCE[0]}" == "${0}" ]; then
    # script is being executed, not sourced - exit with error code
    if [ ! ${scriptHelp} ]; then
        # scriptHelp is not defined, so dump a plainjane error message
        echo "${0##*/} is intended to be included via source, not executed via command line."
    else
        # scriptHelp is defined, so call printHelp
        introHelpEntries+=("${ansi_foreRed}*****${ansi_resetAll}")
        introHelpEntries+=("${ansi_setBold}* ${ansi_setBold}${0##*/} is intended to be included via source, not executed via command line. *${ansi_resetAll}")
        introHelpEntries+=("${ansi_foreRed}*****${ansi_resetAll}")
    fi
    exit 1
fi

# the next line makes case statements process pipe-delimited lists inside variables
shopt -s extglob

#
# A value telling consumers that scriptCLI is included, so we don't over-include the script
#
declare -i scriptCLI=1

declare thisScript="${BASH_SOURCE[0]##*/}"
declare thisScriptDir="$( cd "${BASH_SOURCE[0]%/*}" && pwd )"
declare thisFQP="${thisScriptDir}/${thisScript}"

#
# cliParameters is a mutable value to contain the CLI parameters that the user passes in from the command line
# * This is a "multidimensional" bash array; as of this writing bash doesn't actually support multidimensional 
#   arrays.  
# ** What's being done here is that each entry in this array is a string where the first "dimension" is a 
#    space delimited array of key=value pairs and the second "dimension" is an = (equals) delimited array separating 
#    key (parameter name) from user-specified value
# ** We don't actually ever need to pull these out to multiple arrays.  Cutting the space-delimited string to an 
#    array and then cutting off everything after the = character in each element after that is plenty good enough.
#
declare -a cliParameters=("$@")

#
# cliHandlers is a mutable value to contain definitions you write for supported cliParameter keys (parameter names) 
# and the functions that will handle them.
# * This is a single-dimensional bash array but writing entries into it may look confusing.
# ** What's being done here is that each entry in this array is a space delimited string where the first part is a 
#    | (pipe) delimited case-pattern definition and the second part is your handler function name.  This is really 
#    much simpler than it seems at a glance.
#
# To add items to cliHandlers:
# 
# For simple switch (on/off) style parameters:
#   cliHandlers+=("-p|--paramLongname|--maybeSomeOtherLongName functionNameThatHandlesThisParameter")
#
# For specifically named detail-oriented style parameters:
#   cliHandlers+=("-p=specificDetail|--paramLongName=specificDetail|--maybeSomeOtherLongName=orMaybeSomeOtherSpecificDetail functionNameThatHandlesThisParameter")
#
# For non-specifically named or wildcard allowed style parameters:
#   cliHandlers+=("-p=*|--paramLongname=*|--maybeSomeOtherLongName=* functionNameThatHandlesThisParameter")
#
# * The parentheses around the whole thing are required when adding items to bash arrays.
# * The quotations around the whole thing inside the parentheses are too.
# * The pipes are case pattern.  The = are both case pattern and command line interpreter (CLI) pattern.
# * The only space in the entry must be between the case pattern and your function name.
#
declare -a cliHandlers

#
# A function called any time an unrecognized parameter is hit during parameter processing in processsCLIParameters
#
function unrecognizedCLIParameterFunction
{
    echo "    Unrecognized parameter on commandline:  \"${1}\""
    # Uncomment the next 2 lines if you like, or add additional handlers in your own scripts
    # echo "    ${0} will abort"
    # kill -s TERM $CLI_PID
}
#
# cliUnrecognizedParameterHandlers is a mutable value to contain function handlers for the event of a user entering unrecognized 
# parameters into your script at the command line.
# * In most cases you will want to print an error message and abort the script.
#
# Simply add your function with:
#     cliUnrecognizedParameterHandlers+=("functionNameThatFiresWhenCLIParametersAreNotRecognized")
#
# Event consumers subscribed to cliUnrecognizedParameterHandlers are guaranteed to fire in the order they are 
# entered into this array.
#
# * When a cliUnrecognizedParameterHandler function is called, the unrecognized parameter=value is passed to it just like it is to 
#   a defined cliHandler
#
# To remove the original/default entry, simply shift it off before adding your own handler(s):
#     shift cliUnrecognizedParameterHandlers
#
declare -a cliUnrecognizedParameterHandlers
cliUnrecognizedParameterHandlers+=("unrecognizedCLIParameterFunction")

#
# cliFinishedHandlers is an array of functions that will be called when all Command Line Interface (CLI) 
# parameters are finished processing.  With well-written code you shouldn't ever need to use this, but 
# I went ahead and included it in the interest of providing a complete and robust framework.  In this 
# case I mean 'robust' in the sense that you can track the state of your script or perform certain actions 
# at guaranteed, not presumed, points in processing time by event hooking.
#
# Simply add your function with:
#     cliFinishedHandlers+=("functionNameThatFiresWhenCLIParametersAreFinishedProcessing")
#
# Event consumers subscribed to cliFinishedHandlers are guaranteed to fire in the order they are 
# entered into this array.
#
declare -a cliFinishedHandlers

#
# The function that actually processes the CLI Parameters that were passed in, compared against the cliHandlers.
# *  BE SURE TO CALL THIS FUNCTION AT SOME POINT AFTER ADDING YOUR HANDLERS BUT BEFORE RUNNING THE MAIN BODY OF YOUR SCRIPT! *
#
function processCLIParameters
{
    for cliParam in "${cliParameters[@]}"; do
        # A value that indicates if the cliParam was recognized/handled during the next round of processing
        local -i parameterHandled=0
        for eachHandler in "${cliHandlers[@]}"; do
            # cliSignature is the bit that matches  everything before the last space in case statements
            local cliSignature="+(${eachHandler%%' '*})"
            # fncSignature is the event handler for parameter trapping everything after the last space
            local fncSignature="${eachHandler##*' '}"
            case ${cliParam} in
                ${cliSignature})
                    #
                    # This passes the entire parameter (ie:  --param=value) to your function, which you
                    # need to pick apart using string match specifications in your consuming function.
                    #  ** Bash' native string matching/manipulation functions are quite simple:
                    #      # removes the shortest match from the beginning of a string
                    #      ## removes the longest match from the beginning
                    #      % removes the shortest match from the end of a string
                    #      %% removes the longest match from the end
                    #  ***  As of 2017-08-27, https://spin.atomicobject.com/2014/02/16/bash-string-maniuplation/
                    #       had some great information on Bash-native string manipulation
                    #
                    "${fncSignature}" "${cliParam}"
                    parameterHandled=1
                    break
                ;;
            esac
        done
        if [ ${parameterHandled} -lt 1 ]; then
            # The parameter was not recognized or handled
            # call out to each cliUnrecognizedParameterHandler function defined
            for (( i=0; i<${#cliUnrecognizedParameterHandlers[@]}; i+=1 )); do
                "${cliUnrecognizedParameterHandlers[${i}]}" "${cliParam}"
            done
        fi
    done

    # call out to each cliFinishedHandler function defined
    for (( i=0; i<${#cliFinishedHandlers[@]}; i+=1 )); do
        "${cliFinishedHandlers[${i}]}"
    done
}