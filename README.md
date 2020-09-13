# Shell Utils

These are some functions we need at shell all the time.
The aim is to make bash scripts easier.
I know it's not recommended to use shell as a programming language, but sometimes it's very useful (to make cronjobs, script utils, to help in docker images, etc.).

We use the Google guidelines for styling: [https://google.github.io/styleguide/shellguide.html](https://google.github.io/styleguide/shellguide.html)

For information on bash usage, you can see this repo: [https://github.com/dylanaraps/pure-sh-bible](https://github.com/dylanaraps/pure-sh-bible)

**Note**: If you try testing, you will see sometimes dates functions show some errors because of the time, it's OK. It's because the seconds increased in between both variables. But it's working right as long as the difference is only one second (for example, 86400 and 86401, one second elapsed between the first and second function).

# Example


```bash
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
```

# License

MIT @ [Matias Puig](https://www.github.com/matipuig)
