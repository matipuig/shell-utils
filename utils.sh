#! /bin/bash
#  UTILS
#  Contains some functions are needed in many scripts.

#
#   GLOBALS
#

# Return 1 if the first param is an integer number, 0 if isn't.
# Use: $(is_integer 1) => 1
# Use: $(is_integer "John Doe") => 0
is_integer(){
  [[ "${1}" =~ ^-?[0-9]+$ ]] && echo "1" || echo "0"
}

# If the param is set, returns it, otherwise return the default.
# Use: $(get_param_or_default $1 "Default") => If $1 is not set, return "Default"
# Use: $(get_param_or_default $! "Default") => If $! is not set, return "Default"
get_value_or_default(){
  ! [[ -z "${1}" ]] && echo "${1}" || echo "${2}"
}

# Exits with specified code.
# Use: exit_with 2 "Message to send"
exit_with(){
  if [[ $(is_integer "${1}") = "0" ]]; then
    echo "Received \"${1}\". Not a valid number."
    exit 1
  fi
  exit_with_code=$1
  shift
  echo "$@"
  exit ${exit_with_code}
}


#
#   PARAMS
#

# Returns the param in the specified position (specified in the first param).
# Use: x=$(param_get_at 3 $@) => The third param in $@ 
# Use: x=$(param_get_at 2 "My Testing") => "" (There's no second param)
params::get_at(){
  if [[ $(is_integer "${1}") = "0" ]]; then
    exit_with 1 "Received \"${1}\". Not a valid number."
  fi
  param_get_at=$1
  param_get_at_counter=0
  while [[ ${param_get_at_counter} -lt ${param_get_at} ]]; do 
    shift
    param_get_at_counter=$((${param_get_at_counter}+1))
  done  
  echo "$1"
}

#
#   ECHO
#

# In order to work the same in all OS, it echoes the text and don't start a new line.
# Use: echo::inline Testing echo inline
# Use: echo::inline "Testing echo inline"
# Use: echo::inline "Testing" "echo" "inline"
# It chooses -n or \c according to the system. 
echo::inline(){
  if [[ "`echo -n`" = "-n" ]]; then
    n=""; c="\c"
  else
    n="-n"; c=""
  fi
  echo $n "$@" $c
}

# Echoes a color tag before the text.
# Use: echo::with_color_tag colorCode tag "Rest of the text"
# Vg: echo::with_color_tag "0;33" "ERROR" "An error has ocurred." 
# This page contains code colors: https://misc.flogisoft.com/bash/tip_colors_and_formatting
echo::with_color_tag(){
  color="\033[${1}m"
  tag=$2
  shift; shift;
  NC='\033[0m' # No Color
  echo -e "${color}${tag}${NC}: $@"
}

# Echoes with error.
# Use: echo::error An error has ocurred.
echo::error(){
  echo::with_color_tag "0;31" "ERROR" "  $@"
}

# Echoes with warning.
# Use: echo::warning Something it's important.
echo::warning(){
  echo::with_color_tag "1;33" "WARNING" "$@"
}

# Echoes with info.
# Use: echo::info Something finished.
echo::info(){
  echo::with_color_tag "1;36" "INFO" "   $@"
}

# Echoes with success.
# Use: echo::sucess Something finished OK.
echo::success(){
  echo::with_color_tag "1;32" "SUCCESS" "$@"
}


#
#  USER INPUT
#

# Asks for the user input, and returns the default if it's response is zero.
# Use: x=$(user_input::get_or_default "Message to be prompted" "default") => user message or "Default".
user_input::get_or_default(){
  read -p "$1 : " user_input
  echo $(get_value_or_default "${user_input}" "$2")
}

# Asks for an answer no empty. If it's empty, it asks again.
# Use: x=$(user_input::no_empty "Ask here")
user_input::get_no_empty(){
  while [ true ]; do
    read -p "$@ : " user_input
    if [[ ! -z "${user_input}" ]]; then
      echo "${user_input}"
      break
    fi
  done
}

# Asks for the user input, and must be yes or no. returns 
# Use: user_input::yn "Message to be prompted" "VARIABLE" => $VARIABLE will be then "1" or "0".
user_input::get_yn(){
  return_input="n"
  result=""
  while true; do
    echo::inline "$1 (yes/no) : "
    read user_input
    case "${user_input}" in
      [Yy]* ) result="1";;
      [Nn]* ) result="0";;
      * ) echo "";;
    esac
    if [ "${result}" != "" ]; then
      export ${2}=${result}
      return 0
    fi
  done
}

#   
#   ERRORS
#

# Receives function return ($?) and error description.
# Use: errors::check $? "Here the error description"
# Echoes the error description and returns original error code ("$?").
errors::check(){
  if [ "${1}" -ne "0" ]; then
    echo "Error ${1}: ${2}" >&2
    exit_with ${1} ""
  fi
}

# Check if there's the minimum amount of param required.
# Use: $(errors::check_enough_params 3 $@) => Throw error if not enough params.
errors::check_enough_params(){
  if ! [ $(is_integer $1) ]; then
    exit_with 1 "First param must be a number."
  fi
  params_count=$(($#+1))
  if [[ ${params_count} -lt $1 ]]; then
    exit_with 1 "Not enough params: ${1} required."
  fi
}

#
#   DATES
#

# Gets the day in format "YYYY-MM-DD"
# Use: x=$(dates::get_today) => Vg: 2020-17-08
dates::get_today(){
  echo $(date +'%Y-%m-%d')
}

# Gets the day in format "YYYY-MM-DD HH:MM:SS"
# Use: x=$(dates::get_now) => Vg: 2020-17-08 10:00:40
dates::get_now(){
  echo $(date +'%Y-%m-%d %T')
}

# Gets the day in format "YYYY-MM-DD-HH-MM-SS"
# Use: x=$(dates::get_now_with_no_spaces) => Vg: 2020-17-08-10-00-40
dates::get_now_with_no_spaces(){
  echo $(date +'%Y-%m-%d-%H-%M-%S')
}

# Gets the miliseconds since epoch started.
# Use: x=$(dates::get_seconds) => Vg: 84729384
# Use: x=$(dates::get_seconds YYYY-MM-DD) => VG: 4395793875
dates::get_seconds(){
  [[ $# = 0 ]] && echo $(date +%s) || echo $(date -d "$1" +%s)
}

# Gets the difference in seconds between two dates. 
# Use: x=$(dates::get_diff "2020-01-01") => Vg: 84729384
# Use: x=$(dates::get_diff "2020-01-02" "2020-01-01") => VG: 86400
dates::get_diff(){
  errors::check_enough_params 1 "Date diff must get at least one date."
  first_date=$(dates::get_seconds "$1")
  if [[ $# = 1 ]]; then
    second_date=$(dates::get_seconds)
  else
    second_date=$(dates::get_seconds "$2")
  fi
  result=$((second_date-first_date))
  echo ${result#-}
}

# Gets the difference in days between two dates. 
# Use: x=$(dates::get_diff_in_days "2020-01-01") => Vg: 320
# Use: x=$(dates::get_diff "2020-01-02" "2020-01-01") => VG: 1
dates::get_diff_in_days(){
  seconds=$(dates::get_diff "$1" "$2")
  echo $(($seconds / 86400))
}

#
#   STRINGS
#

# Returns the length of a variable.
# Use: x=$(strings::get_length "VARIABLE")
# Use: x=$(strings::get_length "${VARIABLE}")
strings::get_length(){
  string="$@"
  echo ${#string}
}

# Trims a string.
# Use: $(strings::trim \"   TEST  \") => "Test" 
strings::trim(){
  echo $(echo::inline "$@") | sed 's/ *$//g'
}

# Converts a string to lower case.
# Use: $(strings::to_lower_case "UPPER CASe" ) => "upper case" 
strings::to_lower_case(){
  echo "$@" | tr '[:upper:]' '[:lower:]'
}

# Converts a string to upper case.
# Use: $(strings::to_upper_case "lower case" ) => "LOWER CASE" 
strings::to_upper_case(){
  echo "$@" | tr '[:lower:]' '[:upper:]'
}

# Receives two params. The original text and the subtext to search. Returns "0" or "1".
# Use: $(strings::includes "ORIGINAL TEXT" "NAL") => 1
# Use: $(strings::includes "ORIGINAL TEXT" "RANDOM") => 0
strings::includes(){
  [[ "${1}" = *${2}* ]] && echo "1" || echo "0"
}

# Receives two params and tests with case insensitive. The original text and the subtext to search.
# Returns 1 if yes, or 0 if no.
# Use: $(strings::includes "ORIGINAL TEXT" "nal") => 1
# Use: $(strings::includes "ORIGINAL TEXT" "TEST") => 0
strings::includes_ci(){
  strings_text=$(strings::to_lower_case $1)
  strings_subtext=$(strings::to_lower_case $2)
  echo $(strings::includes "${strings_text}" "${strings_subtext}")
}

# Tests if the first param starts with the second param.
# Returns 1 if yes, or 0 if no.
# Use: $(strings::starts_with "ORIGINAL TEXT" "ORIG") => 1
# Use: $(strings::starts_with "ORIGINAL TEXT" "NOT OR") => 0
strings::starts_with(){
  [[ "${1}" = "${2}"* ]] && echo "1" || echo "0"
}

# Tests if the first param ends with the second param.
# Returns 1 if yes, or 0 if no.
# Use: $(strings::ends_with "ORIGINAL TEXT" "NAL") => 1
# Use: $(strings::ends_with "ORIGINAL TEXT" "NOT NAL") => 0
strings::ends_with(){
  [[ "${1}" = *"${2}" ]] && echo "1" || echo "0"
}

# Replace the first ocurrence of a substring in a string.
# x=$(strings::replace "Original string" "string" "text") => "Original text"
strings::replace(){
 echo "${1}" | sed "s/${2}/${3}/"
}

# Replace all ocurrences of a substring in a string.
# x=$(strings::replace_all "Original string string" "string" "text") => "Original text text"
strings::replace_all(){
 echo "${1}" | sed "s/${2}/${3}/g"
}

# Executes a regex on a string.
# Use: x=$(strings::regex "string with 28472 regex" "[0-9]+") => "28472"
strings::regex() {
  [[ $1 =~ $2 ]] && printf '%s\n' "${BASH_REMATCH[1]}"
}


#
# FILES
#

# Return 1 or 0 depending on if file exists.
# Use: exists=$(fs::file_exists "/test.md") => "1" or "0"
fs::file_exists(){
  [ -e "$1" ] && echo "1" || echo "0"
}

# Return 1 or 0 depending on if dir exists.
# Use: exists=$(fs::dir_exists "/test") => "1" or "0"
fs::dir_exists(){
  [ -d "$1" ] && echo "1" || echo "0"
}

# Creates the file if doesn't exist.
# Use: fs::create_file_if_not_exist "/test.md"
fs::create_file_if_not_exist(){
  [ -e "$1" ] || touch "$1"
}

# Removes the file if exists.
# Use: fs::remove_if_exists "/test.md"
fs::remove_file_if_exist(){
  ! [ -e "$1" ] || rm "$1"
}

# Creates the dir if doesn't exist.
# Use: fs::create_dir_if_not_exist "/test"
fs::create_dir_if_not_exist(){
  [ -d "$1" ] || mkdir -p "$1"
}

# Removes the dir if exists.
# Use: fs::remove_dir_if_exist "/test"
fs::remove_dir_if_exist(){
  ! [ -d "$1" ] || rm -rf "$1"
}

# Creates a tar file.
# Use: fs::tar "/source" "tarname.tar"
fs::tar() {
    fs::remove_file_if_exist "$2"
    tar -czf "${2}" "${1}"
}