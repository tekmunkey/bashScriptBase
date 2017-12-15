#
#
# Contains the helpfile features
#   USAGE:  source ./path/to/scriptHelp.sh
#
#

#!/bin/bash
#
# you may need to run the next line from command shell to make the script executable
# chmod ugo+x your_shell_script.sh
#

#
# the next line makes the script die if anything it does throws an error or returns false
set -e

#
# A value telling consumers that adaptiveDisplay is included, so we don't over-include the script
#
declare -i adaptiveDisplay=1

#
# Horizontally centers the text $1 in the user's terminal screen
#
function centerHorz
{
    # $1 is the text to center in the user's display
    screenCenter=$(($(tput cols)/2))
    textCenter=$((${#1}/2))
    textStart=$((${screenCenter}-${textCenter}))
    echo "$(repeatChar ' ' ${textStart})${1}"
}

##
## BEGIN ansiColor SEGMENT
##

    ##
    ## Set
    ##
    ansi_setBold="\e[1m"
    ansi_setDim="\e[2m"
    ansi_setUnderline="\e[4m"
    ansi_setBlink="\e[5m"
    ansi_setReverse="\e[7m" # (invert the foreground and background colors)
    ansi_setHidden="\e[8m"  # (usefull for passwords)

    ##
    ## Reset
    ##
    ansi_resetAll="\e[0m" # The ”\e[0m” sequence removes all attributes (formatting and colors). It can be a good idea to add it at the end of each colored text. ;)
    ansi_resetBold="\e[21m"
    ansi_resetDim="\e[22m"
    ansi_resetUnderline="\e[24m"
    ansi_resetBlink="\e[25m"
    ansi_resetReverse="\e[27m"
    ansi_resetHidden="\e[28m"

    ##
    ## Colors
    ##

        ##
        ## Foreground
        ##
        ansi_foreDefault="\e[39m"
        ansi_foreBlack="\e[30m"
        ansi_foreRed="\e[31m"
        ansi_foreGreen="\e[32m"
        ansi_foreYellow="\e[33m"
        ansi_foreBlue="\e[34m"
        ansi_foreMagenta="\e[35m"
        ansi_foreCyan="\e[36m"
        ansi_foreBrightGray="\e[37m"
        ansi_foreDarkGray="\e[90m"
        ansi_foreBrightRed="\e[91m"
        ansi_foreBrightGreen="\e[92m"
        ansi_foreBrightYellow="\e[93m"
        ansi_foreBrightBlue="\e[94m"
        ansi_foreBrightMagenta="\e[95m"
        ansi_foreBrightCyan="\e[96m"
        ansi_foreWhite="\e[97m"

        ##
        ## Background
        ##
        ansi_backDefault="\e[49m"
        ansi_backBlack="\e[40m"
        ansi_backRed="\e[41m"
        ansi_backGreen="\e[42m"
        ansi_backYellow="\e[43m"
        ansi_backBlue="\e[44m"
        ansi_backMagenta="\e[45m"
        ansi_backCyan="\e[46m"
        ansi_backBrightGray="\e[47m"
        ansi_backDarkGray="\e[100m"
        ansi_backBrightRed="\e[101m"
        ansi_backBrightGreen="\e[102m"
        ansi_backBrightYellow="\e[103m"
        ansi_backBrightBlue="\e[104m"
        ansi_backBrightMagenta="\e[105m"
        ansi_backBrightCyan="\e[106m"
        ansi_backWhite="\e[107m"

##
## END ansiColor SEGMENT
##