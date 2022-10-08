#!/usr/bin/osascript

on is_running(appName)
	tell application "System Events" to (name of processes) contains appName
end is_running

on attempt_focus(appName)
	if is_running(appName) then
		tell application "System Events" to tell process appName to set frontmost to true
		return true
	end if
	return false
end attempt_focus

attempt_focus("iTerm") or attempt_focus("Alacritty") or attempt_focus("kitty") or attempt_focus("Terminal")
