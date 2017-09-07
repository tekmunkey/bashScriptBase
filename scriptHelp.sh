#
#
# Contains the helpfile features
#   USAGE:  source ./path/to/scriptHelp.sh
#
#

#!/bin/bash
trap "exit 1" TERM
export HELP_PID=$$ # use 'kill -s TERM $HELP_PID' to pop this from anywhere in the script

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

#
# A value telling consumers that scriptHelp is included, so we don't over-include the script
#
declare -i scriptHelp=1

#
# An array of strings representing the help introduction header that will print whenever printHelp function is called.
# These help entries will print before anything else.
#
# When adding entries to help arrays, add each line item as a separate entry.  To insert empty lines, insert an empty entry.
#  ie:
#    headerHelpEntries+=('Some Help Entry')
#    headerHelpEntries+=('  * Some additional notation')
#    headerHelpEntries+=('') # a blank line in the help screen output
#
# We do it this way because the printHelp function calls on fold to ensure that each line is properly wrapped for the user's
# terminal width, and long help entries with multiline string declarations or even explicit \n markers are broken by fold (the 
# whole thing is strung together as a single if wrapped mess of garbage.)
#
declare -a headerHelpEntries
headerHelpEntries+=("${ansi_setBold}Help documentation for:${ansi_resetAll} ${ansi_setBold}${0##*/}${ansi_resetAll}")
headerHelpEntries+=("")
#
## The next line is commented because it isn't necessarily true unless you code that way.  It certainly should be.
## * If you code execution function calls directly out from CLI Parameter processing, then it is not.
## * If your script execution doesn't really begin until after all CLI processing is complete, so that CLI Parameter Processing
##   function calls really only error check and set variables that execution functions and processes use, then it is.
##   So you can set this line into your own scripts if it is true.  Otherwise, kindly leave it out!
#
# headerHelpEntries+=("${ansi_setBold}* The order in which parameters are sent into this script is not important. *${ansi_resetAll}")
#

#
# An array of strings representing the individual help entries that will print whenever printHelp function is called.
# These may be added to by consumers who import scriptHeader.sh, displaying help syntax entries created by consumers
# of scriptHeader.sh for custom scripts.  These help entries will print before footerHelpEntries.
#
# When adding entries to help arrays, add each line item as a separate entry.  To insert empty lines, insert an empty entry.
#  ie:
#    bodyHelpEntries+=('Some Help Entry')
#    bodyHelpEntries+=('  * Some additional notation')
#    bodyHelpEntries+=('') # a blank line in the help screen output
#
declare -a bodyHelpEntries

#
# An array of strings representing the individual help entries that will print whenever printHelp function is called.
# While these may be added to by consumers who import scriptHeader.sh, they are intended to contain help syntax entries 
# for scriptHeader.sh builtins only.  These help entries will print after bodyHelpEntries.
#
# When adding entries to help arrays, add each line item as a separate entry.  To insert empty lines, insert an empty entry.
#  ie:
#    footerHelpEntries+=('Some Help Entry')
#    footerHelpEntries+=('  * Some additional notation')
#    footerHelpEntries+=('') # a blank line in the help screen output
#
# We do it this way because the printHelp function calls on fold to ensure that each line is properly wrapped for the user's
# terminal width, and long help entries with multiline string declarations or even explicit \n markers are broken by fold (the 
# whole thing is strung together as a single if wrapped mess of garbage.)
#
declare -a footerHelpEntries

#
# A string containing the pipe-delimited list of help commands.  Each entry here will trigger the help display as 
# command line (CLI) parameters when you include scriptHelp.sh into your script, and each entry here will be ignored if/when 
# it is passed into printHelp as an argument.
#
declare helpCommands="-h|-hlp|--help|-?|--?|/?"

#
# prints the help documentation for this script
#
function printHelp
{
    #
    # if $1 is passed in, then only print the help intro entries (the script help header and etc) along with 
    # the $1 parameter
    #
    local soloHelpEntry="${1}"
    local -a helpCommandsArr=(${helpCommands//|/ })
    for helpcomstr in ${helpCommandsArr[@]}; do
        if [ "${soloHelpEntry}" == "${helpcomstr}" ]; then
            soloHelpEntry=''
            break
        fi
    done

    # get the current terminal width - this adapts to a user on a telnet terminal that resizes, such as puTTY
    # * subtracting 4 provides a dandy 4-column padding on the right-hand side
    local screenWidth=$(($(tput cols)-4))

    # will be used for individual screen-wrapped help entries
    local helpWrap=''
    
    printf "\n"
    # do the headerHelpEntries
    for ihhelp in "${headerHelpEntries[@]}"; do
        helpWrap=$(echo "${ihhelp}" | fold -w "${screenWidth}" -s)
        helpWrap=$(centerHorz "${helpWrap}")
        printf "${helpWrap}\n"
    done

    if [ "${#soloHelpEntry}" -gt 0 ]; then
        # soloHelpEntry aka $1 length is gt 0
        helpWrap=$(echo "${soloHelpEntry}" | fold -w "${screenWidth}" -s)
        printf "${helpWrap}\n"
    else
        # soloHelpEntry aka $1 length is lte 0
        # do the bodyHelpEntries
        if [ ${#bodyHelpEntries[@]} -gt 0 ]; then
            for cshelp in "${bodyHelpEntries[@]}"; do
                helpWrap=$(echo "${cshelp}" | fold -w "${screenWidth}" -s)
                printf "${helpWrap}\n"
            done
        fi

        # do the footerHelpEntries
        for shhelp in "${footerHelpEntries[@]}"; do
            helpWrap=$(echo "${shhelp}" | fold -w "${screenWidth}" -s)
            printf "${helpWrap}\n"
        done
    fi

    # print a final lineterm for a nice, clean break before the next prompt
    printf "\n"
    kill -s TERM $HELP_PID
}

# add printHelp to scriptCLI
footerHelpEntries+=("")
#footerHelpEntries+=("${ansi_setBold}$(centerHorz 'Script Framework Help Entries')${ansi_resetAll}")
footerHelpEntries+=("    ${ansi_setBold}-h|-hlp|--help|-?|--?|*${ansi_resetAll}")
footerHelpEntries+=("        Prints this help screen.")

cliHandlers+=("${helpCommands} printHelp")

#
# scriptHelp can/should die as soon as its help entries are set up
#
if [ "${BASH_SOURCE[0]}" == "${0}" ]; then
    # script is being executed, not sourced - exit with error code
    if [ ! ${scriptHelp} ]; then
        # scriptHelp is not defined, so dump a plainjane error message
        echo "${0##*/} is intended to be included via source, not executed via command line."
    else
        # scriptHelp is defined, so call printHelp
        headerHelpEntries+=("${ansi_foreRed}*****${ansi_resetAll}")
        headerHelpEntries+=("${ansi_setBold}* ${ansi_setBold}${0##*/} is intended to be included via source, not executed via command line. *${ansi_resetAll}")
        headerHelpEntries+=("${ansi_foreRed}*****${ansi_resetAll}")
        printHelp
    fi
    exit 1
fi