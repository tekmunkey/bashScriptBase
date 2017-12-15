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
# A value telling consumers that stringExtends is included, so we don't over-include the script
#
declare -i stringExtends=1

#
# Strips the character or string specified by $2 from the string specified by $1
#
function stripString
{
    local stripFrom=$1
    local stripThis=$2
    # default stripThis to a space if it is undefined
    : ${stripThis:=' '}

    local -i r_startOffset=0
    local -i r_endOffset=${#stripFrom}

    if [ "${#stripFrom}" -gt 0 ] && [ "${#stripFrom}" -ge "${#stripThis}" ]; then
        for (( i=0; i<${#stripFrom}; i+=1 )); do
            if [ ${#stripFrom} -ge $((${i}+${#stripThis})) ]; then
                local stripTest=${stripFrom:i:${#stripThis}}
                if [ "${stripTest}" != "${stripThis}" ]; then
                    # if no match, then we're done stripping from the beginning entirely
                    break
                else
                    r_startOffset=$((${i}+${#stripThis}))
                fi
            fi
        done

        for (( i=$((${#stripFrom}-${#stripThis})); i>-1; i-=1 )); do
            local stripTest=${stripFrom:i:${#stripThis}}
            if [ "${stripTest}" != "${stripThis}" ]; then
                # if no match, then we're done stripping from the end entirely
                break
            else
                r_endOffset=${i}
            fi
        done
    fi
    stripFrom=${stripFrom:r_startOffset:$((${r_endOffset}-${r_startOffset}))}
    echo "${stripFrom}"
}

#
# Counts the number of times the single character $2 repeats in the string $1, starting the search at index $3 in string $1
# * If $2 is unspecified, it defaults to a space
# * If $2 is more than 1 character, it defaults back to a space
# * If $3 is unspecified, it defaults to 0
#
function countRepeatingChar
{
    # $1 is the word to search in
    local findInString="${1}"
    # $2 is the character to search for
    local findThisChar="${2}"
    # if $2 is nothing then make it be a space by default
    : ${findThisChar:=' '}
    if [ ! "${#findThisChar}" == 1 ]; then
        # set findThisChar to space if the value is more than 1 character long
        findThisChar=' '
    fi
    # $3 is the start index in $word
    local -i startAtIndex="${3}"
    : ${startAtIndex:=0}
    if [ ${startAtIndex} -lt 0 ] || [ ${startAtIndex} -ge ${#findInString} ]; then
        # set startAtIndex to 0 if it's invalid, meaning < 0 or >= string length (which is 0-base indexed)
        startAtIndex=0
    fi
    
    local -i r=0
    for (( i=${startAtIndex}; i<${#findInString}; i+=1 )); do
        if [ ! "${findInString:i:1}" == "${findThisChar}" ]; then
            # if the char at index i doesn't match $findThisChar then we're finished here
            break
        else
            r+=1
        fi
    done
    echo ${r}
}

#
# Repeats char $1 count $2 times
#
function repeatChar
{
    local repeatChar=$1
    # if $1 is undefined, default it to a dash
    : ${repeatChar:='-'}
    local -i repeatCount=$2
    # if $2 is undefined, default it to screen width
    : ${repeatCount:=$(tput cols)}

    local -i repeater=0
    local r=''
    while [ ${repeater} -lt ${repeatCount} ]; do
        r+="${repeatChar}"
        repeater+=1
    done
    echo "${r}"
}




