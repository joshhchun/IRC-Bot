#!/bin/sh

# Globals

URL="https://forecast.weather.gov/zipcity.php"
ZIPCODE=46556
FORECAST=0
CELSIUS=0
# To get the Fahrenheit you have to search for the tag 'current-lrg'
TEMPSEARCH='current-lrg'

# Functions

usage() {
    cat 1>&2 <<EOF
Usage: $(basename $0) [zipcode]

-c    Use Celsius degrees instead of Fahrenheit for temperature
-f    Display forecast text

If zipcode is not provided, then it defaults to $ZIPCODE.
EOF
    exit $1
}

weather_information() {
    # Fetch weather information fclearrom URL based on ZIPCODE
    curl -sL $URL?inputstring=$ZIPCODE
}

temperature() {
    # Extract temperature information from weather source
    # If user indicated they wanted Celsius switch temperature search tag from 'lrg' to 'sm'
    if [ $CELSIUS = 1 ]; then
        TEMPSEARCH='current-sm'
    fi
    # Using digit character class to get only the temperature. Using the question mark quantifier
    # to get a dash if the temperature is negative. 
    weather_information | grep $TEMPSEARCH | grep -oE '\-?[[:digit:]]+'
}

forecast() {
    # Extract forecast information from weather source
    # Using sed and grouping to replace the whole forecast line with just the desired substring
    # and printing it out. Use the "\s*" to remove leading and trailing whitespace.
    weather_information | sed -En 's/^.*myforecast-current">\s*(.*)\s*<.*/\1/p'
}


# Parse Command Line Options
# If the user inputs no flags or zipcode then call temperature and use default zipcode
while [ $# -gt 0 ]; do
    case $1 in
        -h) usage 0;;
        -c) CELSIUS=1;;
        -f) FORECAST=1;;
        # If user inputs anything after the flags assume it is the zipcode
        *) ZIPCODE=$1;;
    esac
    shift
done


# If user indicates they want to see forecast
if [ $FORECAST -eq 1 ]; then
    echo "Forecast:    $(forecast)"
fi

# Displaying the temperature
echo "Temperature: $(temperature) degrees"