#!/bin/bash

#
#   TEST UTILS
#
. $(cd $(dirname $(dirname "$0")); pwd)/utils.sh

TOTAL_TESTS=0
TOTAL_ERRORS=0
TOTAL_SUCCESS=0

# Shows an error if is not equal.
do_test(){
    TOTAL_TESTS=$(($TOTAL_TESTS+1))
    TEST_RESULT=$(eval $1)
    if [[ "${TEST_RESULT}" == "$2" ]]; then
        echo::success "\"${1}\" passed (Result: \"$2\")."
        TOTAL_SUCCESS=$(($TOTAL_SUCCESS+1))
    else 
        echo::error "\"${1}\" had error."
        echo::error ""
        echo::error "Details:"
        echo::error "Executed: ${1}"
        echo::error "Expected: ${2}"
        echo::error "Received: ${TEST_RESULT}"
        echo::error 
        TOTAL_ERRORS=$(($TOTAL_ERRORS+1))
    fi
}

# Shows how console will show things.
echo::info "Consoling info example."
echo::warning "Consoling warning example."
echo::error "Consoling error example."
echo::success "Consoling success example."
echo 

echo::info "Starting test."
echo

#
# IS INTEGER
#
echo ""
echo::info "Testing is_integer"
do_test "is_integer 10" 1 
do_test "is_integer -5" 1 
do_test "is_integer 125" 1 
do_test "is_integer \"Hola\"" 0
do_test "is_integer 34234-234" 0
do_test "is_integer 34234-234" 0


#
# GET VALUE OR DEFAULT
#
echo ""
echo::info "Testing get_value_or_default"
do_test "get_value_or_default \"\" 0" "0"
do_test "get_value_or_default \"1\" 0" "1"
do_test "get_value_or_default \"Hey\" \"Nothing\"" "Hey"
do_test "get_value_or_default \"\" \"Nothing\"" "Nothing"



#
# PARAMS GET AT
#
echo ""
echo::info "Testing params::get_at"
do_test "params::get_at 1 First second third fourth" "First"
do_test "params::get_at 2 First second third fourth" "second"
do_test "params::get_at 3 First second third fourth" "third"
do_test "params::get_at 4 First second third fourth" "fourth"
do_test "params::get_at 5 First second third fourth" ""

#
# DATES GET TODAY
#
echo ""
echo::info "Testings dates::get_today"
today=$(date +'%Y-%m-%d')
do_test "dates::get_today" "$today"

#
# DATES GET NOW
#
echo ""
echo::info "Testings dates::get_now"
now=$(date +'%Y-%m-%d %T')
do_test "dates::get_now" "$now"

#
# DATES GET NOW WITH NO SPACES
#
echo ""
echo::info "Testings dates::get_now_with_no_spaces"
now=$(date +'%Y-%m-%d-%H-%M-%S')
do_test "dates::get_now_with_no_spaces" "$now"

#
# DATES SECONDS
#
echo ""
echo::info "Testings dates::get_seconds"
seconds=$(date +%s)
do_test "dates::get_seconds" "$seconds"
seconds=$(date -d "2020-09-01" +%s)
do_test "dates::get_seconds \"2020-09-01\"" "$seconds"

#
# DATES GET DIFF IN SECONDS
#
echo ""
echo::info "Testings dates::get_diff"
do_test "dates::get_diff \"2020-09-02\" \"2020-09-01\"" "86400"
first_date=$(date -d "2020-09-01" +%s)
second_date=$(date +%s)
seconds=$((second_date-first_date))  
do_test "dates::get_diff \"2020-09-01\"" "$seconds"

#
# DATES GET DIFF IN DAYS
#
echo ""
echo::info "Testings dates::get_diff_in_days"
do_test "dates::get_diff_in_days \"2020-09-03\" \"2020-09-01\"" "2"
first_date=$(date -d "2020-09-01" +%s)
second_date=$(date +%s)
seconds=$((second_date-first_date))
days=$((seconds / 86400))  
do_test "dates::get_diff_in_days \"2020-09-01\"" "$days"


#
# STRING GET LENGTH
#
echo ""
echo::info "Testing strings::get_length"
do_test "strings::get_length \"123456789\"" 9
do_test "strings::get_length \"123456\"" 6
do_test "strings::get_length \"123456 789\"" 10
do_test "strings::get_length " 0

#
# STRING TRIM
#
echo ""
echo::info "Testing strings::trim"
do_test "strings::trim \"      many spaces     \"" "many spaces"

#
# STRING TO UUPER CASE
#
echo ""
echo::info "Testing strings::to_upper_case"
do_test "strings::to_upper_case \"StRiNg iN lOwEr CasE\"" "STRING IN LOWER CASE"
do_test "strings::to_upper_case \"abcdefghijklmnopqrstuvwxyz\"" "ABCDEFGHIJKLMNOPQRSTUVWXYZ"

#
# STRING TO LOWER CASE
#
echo ""
echo::info "Testing strings::to_lower_case"
do_test "strings::to_lower_case \"StRiNg iN lOwEr CasE\"" "string in lower case"
do_test "strings::to_lower_case \"ABCDEFGHIJKLMNOPQRSTUVWXYZ\"" "abcdefghijklmnopqrstuvwxyz" 


#
# Strings COUNT
#
echo ""
echo::info "Testing strings::count"
do_test "strings::count \"One Two Three Four\"" "4"
do_test "strings::count \"One Two Three Four five\"" "5" 
do_test "strings::count \"One\"" "1" 
do_test "strings::count \"\"" "0" 

#
# STRING INCLUDES
#
echo ""
echo::info "Testing strings::includes"
do_test "strings::includes \"THIS IS A TEST AND I AM TESTING\" \"TEST\"" 1
do_test "strings::includes \"THIS IS A ANOTHER TEST AND I AM TESTING\" \"OTH\"" 1
do_test "strings::includes \"THIS IS A ANOTHER TEST AND I AM TESTING\" \"NOT IN TEXT\"" 0
do_test "strings::includes \"THIS IS A ANOTHER TEST AND I AM TESTING\" \"test\"" 0

#
# STRING INCLUDES CI
#
echo ""
echo::info "Testing strings::includes_ci"
do_test "strings::includes_ci \"ThIs iS a TeSt aNd Im TeStInG\" \"tEsT\"" 1
do_test "strings::includes \"ThIs iS aNotHeR TeSt aND Im TeStInG\" \"NOT IN TEST\"" 0

#
# FILES FUNCTIONS.
#
echo ""
echo::info "Creating, checking and deleting test.txt file"
file="./test.txt"
echo::info "Creating file..."
fs::create_file_if_not_exist ${file}
fs::create_file_if_not_exist ${file}
do_test "fs::file_exists \"${file}\"" "1"
echo::info "Removing file..."
fs::remove_file_if_exist ${file}
fs::remove_file_if_exist ${file}
do_test "fs::file_exists \"${file}\"" "0"

#
# DIRS FUNCTIONS.
#
echo ""
echo::info "Creating, checking and deleting /test dir"
dir="./test"
echo::info "Creating dir..."
fs::create_dir_if_not_exist ${dir}
fs::create_dir_if_not_exist ${dir}
do_test "fs::dir_exists \"${dir}\"" "1"
echo::info "Removing dir..."
fs::remove_dir_if_exist ${dir}
fs::remove_dir_if_exist ${dir}
do_test "fs::dir_exists \"${dir}\"" "0"



#
# FINAL RESULT.
#
echo 
echo ""
echo::info "FINISHED! Tests executed: ${TOTAL_TESTS}. Total succeded: ${TOTAL_SUCCESS}. Total errors: ${TOTAL_ERRORS}."

#
# TESTING INPUT.
#

echo::info "Asking for user input:"
input=$(user_input::get_or_default "Send something or I will return \"NOTHING\"" "NOTHING")
echo "Received: \"${input}\""
input=$(user_input::get_or_default "Again. Send something or I will return \"NOTHING\"" "NOTHING")
echo "Received: \"${input}\""

echo ""
echo::info "Now I will ask until you send something:"
input=$(user_input::get_no_empty "Send something or I will ask again")
echo "Received: \"${input}\""

echo ""
echo::info "Now I will ask until you send YES or NO:"
user_input::get_yn "Send yes or no" input
echo "Received: \"${input}\""
echo::info "Now I will ask again until you send YES or NO:"
user_input::get_yn "Send yes or no" input
echo "Received: \"${input}\""

echo::success "Test finished!!!"
echo::info "Press enter to exit."
read ANY_KEY

