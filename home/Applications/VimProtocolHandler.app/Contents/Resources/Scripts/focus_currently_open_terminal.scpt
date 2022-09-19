#!/usr/bin/osascript

on is_running(appName)
	tell application "System Events" to (name of processes) contains appName
end is_running

on attempt_focus(appName)
	if is_running(appName) then
		tell application "System Events" to tell process appName to set frontmost to true
		return false
	end if
	return true
end attempt_focus

attempt_focus("Terminal") and attempt_focus("kitty") and attempt_focus("Alacritty") and attempt_focus("iTerm")
