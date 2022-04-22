#!/bin/sh

# Globals

URL=https://www.zipcodestogo.com/
STATE='Indiana'
CITY=

# Functions

usage() {
    cat 1>&2 << EOF
Usage: $(basename $0) 

  -c      CITY    Which city to search
  -s      STATE   Which state to search (Indiana)

If no CITY is specified, then all the zip codes for the STATE are displayed.

EOF
# If user activates usage function with -h flag exit with success, else exit with failure
    exit $1;
}

zipcode_information() {
    # Fetch zip code information from zip code website
    # Searching for a substring that has 5 digits (zip code). If a user specified a city, then
    # search for the city sbustring as well.
    if [ -n "$CITY" ]; then
        curl -s $URL"$STATE"/ | grep -E "\/$CITY\/" | grep -Eo '[[:digit:]]{5}' | sort -n | uniq
    else 
        curl -s $URL"$STATE"/ | sed -En 's:.*\/([0-9]{5})\/.*:\1:p' | sort | uniq
    fi
}            

# Parse Command Line Options
while [ $# -gt 0 ]; do
    case $1 in
    -h) usage 0;;
    # If the user inputs a 2 letter word repace the space with a "%20"
    -s) STATE=$(echo "$2" | sed 's/\s/%20/'); shift;;
    -c) CITY="$2"; shift;;
     *) usage 1;;
    esac
    shift
done

echo "$(zipcode_information)"
