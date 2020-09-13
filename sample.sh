#! /bin/bash

# 
# EXAMPLE FILE.
#

trap "exit" INT TERM
trap "kill 0" EXIT

# Source in all functions.
. ./utils.sh --source-only

# Some random process...
now=$(dates::get_now)
echo::info "${now} Starting process..."
echo::warning "${now} Some warning here.."
user_input::get_yn "Do you want to create a test file in this dir?" confirm_var
if [ $confirm_var = "1" ]; then
  fs::create_file_if_not_exist "./test.txt"
  echo::success "File created!! Check it if you want..."
  echo::info "Waiting for user response..."
  read any_key
fi
now=$(dates::get_now)
echo::info "${now} Removing file..."
fs::remove_file_if_exist "./test.txt"
echo::success "Process finished!! Press any key to finish."
read ANY_KEY
exit_with 0 "Bye..."