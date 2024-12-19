#!/usr/bin/env bash

ssplit() {
 # example usage: arr=(); ssplit "," "a,b,c" arr
 local delim="$1"
 local s="$2"
 local -n x="$3" # use nameref for output array
 IFS="$delim" read -ra x <<< "$s"
}

sjoin() {
    # example: sjoin "," "${x[@]}"
    local delimiter="$1"
    shift
    printf -v result "%s$delimiter" "$@"
    echo "${result%$delimiter}"  # Remove trailing delimiter
}

########## Examples ############
# x=(red green noir)
# echo $(sjoin ","  "${x[@]}" )
# x2=()
# ssplit "," "a,b,c" x2
# echo "${x[@]}"
