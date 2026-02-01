---
title: "Current Zen Browser Tab"
author: ["Yejun Su"]
date: 2026-02-02T01:20:00+08:00
tags: ["alfred"]
draft: false
---

The Automation Task block in Alfred workflow doesn't support Zen (based on Firefox), I asked Gemini to write an AppleScript as a workaround:

```applescript
tell application "Zen" to activate

tell application "System Events"
    -- Target the Zen process
    tell process "Zen"
        -- 1. Get the Window Title
        if (count of windows) > 0 then
            set theTitle to name of front window
        else
            set theTitle to "No Window Found"
        end if

        -- 2. Get the URL (Simulate Cmd+L to highlight, Cmd+C to copy)
        keystroke "l" using command down
        delay 0.2 -- Short delay to allow focus
        keystroke "c" using command down
        delay 0.2 -- Short delay to allow copy

        -- 3. Deactivate (Hide) Zen
        set visible to false
    end tell
end tell

-- 4. Retrieve URL from clipboard
set theURL to the clipboard

-- 5. Return Title and URL separated by a Tab
return theTitle & tab & theURL
```

The output is `Title\tURL`, exactly the same as the Output Format of the "Current Chromium Browser Tab" automation task.
