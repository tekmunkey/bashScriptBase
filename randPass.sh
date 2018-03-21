#!/bin/bash
trap "exit 1" TERM
export SCRIPT_PID=$$ # use 'kill -s TERM $SCRIPT_PID' to pop this from anywhere in the script

#
# You will probably need to run the following from the commandline before this script will run
#   * Do that for THIS SCRIPT ONLY!
#
# chmod 770 your_shell_script.sh
#

#####
# HOPEFULLY THIS IS THE FIRST THING YOU DO AFTER GETTING YOUR NEWLY HOSTED SERVER ONLINE, OTHERWISE IT MAY BORK SOME SETTINGS YOU SET UP
#####

#
# This particular script is tweaked for ubuntu 16 server.
# 
# BEFORE YOU BEGIN:
#   * Ensure that your network is fully and properly configured, especially your DNS.
#   * Pre-testing sudo apt-get update && sudo apt-get upgrade to see if there are any errors may be one way of doing this
#
#   * This script will pull everything you need to successfully compile PennMUSH v1.8.6rc1p1 with MySQL support enabled.
#   * This script will pull everything you need to have a lAMP (linux-based Apache MySQL Preprocessor server running
#     ** This script will install both PHP and Python as well as run the Apache Mod configurations needed to run both 
#        PHP and Python scripts as CGI Preprocessor pages.
#     ** Successfully configuring individual sites via sites-available, sites-enabled, .htaccess, and PHP or Python scripts 
#        is still up to you.
#

export DEBIAN_FRONTEND=noninteractive

#
# This function generates a random password between $1 and $2 characters in length
#
function getRandPass
{
    #
    ## $1 must be the minimum number of characters requested
    ## $2 must be the maximum number of characters requested
    #

    local -i minLength=8
    #
    # When referencing this value in code, DO NOT enclose in single or double quotes
    #
    local isNumRegEx="^[0-9]+$"
    ## Validate that $1 is not null and is a number and is > 4 (an oldschool minimum password length)
    if [[ ! -z "${1}" ]] && [[ "${1}" =~ ${isNumRegEx} ]] && [ "${1}" -gt 4 ]; then
        minLength=${1}
    fi

    local -i maxLength=12
    #
    ## Validate that $2 is not null and is a number and is > 4 (an oldschool minimum password length)
    #
    if [[ ! -z "${2}" ]] && [[ "${2}" =~ ${isNumRegEx} ]] && [ "${2}" -gt 4 ]; then
        maxLength=${2}
    fi

    #
    ## Ensuring that minlength isn't > maxLength - if it is then reverse them
    ##   * DO NOT TRY TO PUT THIS ABOVE, INTO THE VALUE VALIDATIONS... IF ANY VALUE VALIDATION FAILS THEN EITHER MIN OR MAX LENGTH MAY BE DEFAULTED
    ##     THIS METHOD ABSOLUTELY ENSURES THAT randPass WILL ALWAYS RETURN A LEGITIMATELY RANDOM-LENGTH AND RANDOM-CHARS PASSWORD, EVEN IF IT THROWS OUT INVALID PARAMETERS
    #
    if [ "${minLength}" -gt "${maxLength}" ]; then
        local -i minBak=${minLength}
        minLength=${maxLength}
        maxLength=${minBak}
    fi
    
    #
    ## Get a random number between minLength and maxLength and that is the actual password length for output
    #
    local -i passLength=$(shuf --input-range="${minLength}-${maxLength}" --head-count=1)

    echo $(< /dev/urandom tr -dc '!@#$%^&*=+<>:_A-Z-a-z-0-9' | head --bytes="${passLength}";echo;)
}

#
# The minimum length of the password to be returned.  Use scriptName.sh -min=# to set the minimum length
#
declare -i minPassLength=8
#
# The maximum length of the password to be returned.  Use scriptName.sh -max=# to set the maximum length
#
declare -i maxPassLength=12

#
# Process the CLI Parameters
#
for cliParam in "$@"; do
    #
    # $(cliParam,,) syntax converts the variable value to all lowercase
    # $(cliParam^^) syntax converts the variable value to all uppercase
    #
    #   * In this fashion parameter matching is case-insensitive
    #
    case ${cliParam,,} in
        -min=*|--minpasslength=*)
            #
            # Need to pick parameter apart using string match specifications in your consuming function.
            #  ** Bash' native string matching/manipulation functions are quite simple:
            #      # removes the shortest match from the beginning of a string
            #      ## removes the longest match from the beginning
            #      % removes the shortest match from the end of a string
            #      %% removes the longest match from the end
            #  ***  As of 2017-08-27, https://spin.atomicobject.com/2014/02/16/bash-string-maniuplation/
            #       had some great information on Bash-native string manipulation
            #
            minPassLength="${cliParam#*=}"
            shift 1
        ;;
        -max=*|--maxpasslength=*)
            maxPassLength="${cliParam#*=}"
            shift 1
        ;;
        *)
            #
            # Default case is when the CLI parameter matches no defined script parameters.
            #
            # Shift CLI Parameters array left by 1 to eliminate this value
            #
            shift 1
            echo "Invalid command line parameter:  ${cliParam%%=*}"
            exit 1
        ;;
    esac
done

echo $(getRandPass ${minPassLength} ${maxPassLength})