#!/usr/bin/osascript

on is_running(appName)
  tell application "System Events" to (name of processes) contains appName
end is_running

on attempt_focus(appName)
  if is_running(appName) then
    tell application "System Events" to tell process appName to set frontmost to true
  end if
end attempt_focus

attempt_focus("Terminal")
attempt_focus("kitty")
attempt_focus("Alacritty")
attempt_focus("iTerm")
