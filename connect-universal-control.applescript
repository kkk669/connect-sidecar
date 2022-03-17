use AppleScript version "2.4" -- Yosemite (10.10) or later
use scripting additions

on run argv
    set deviceName to item 1 of argv

    tell application "System Events"
        tell its application process "ControlCenter"
            -- Click the Control Center menu.
            click menu bar item "Control Center" of menu bar 1

            -- Give the window time to draw.
            delay 1

            -- Get all of the checkboxes in the Control Center menu.
            set ccCheckboxes to name of (every checkbox of window "Control Center")

            if ccCheckboxes contains "Link keyboard and mouse" then
                -- If one of the checkboxes is named "Link keyboard and mouse," click that checkbox.
                set sidecarToggle to checkbox "Link keyboard and mouse" of window "Control Center"
                click sidecarToggle

                -- This opens a secondary window that contains the button to actually connect to the device. Give the window time to draw.
                delay 1

                -- In masOS Monterey, the device toggle (checkbox) is inside of a scroll area.
                -- Rather than assume that it's in scroll area 1, get all of the scroll areas, loop through them, and find the device toggle.
                set scrollAreas to (every scroll area of window "Control Center")
                set saCounter to 1
                set displayCheckboxes to ""

                repeat with sa in scrollAreas
                    set displayCheckboxes to name of (every checkbox of sa)

                    if displayCheckboxes contains deviceName then
                        -- Device toggle found.
                        exit repeat
                    end if

                    -- We didn't find the device toggle. Try the next scroll area.
                    set saCounter to saCounter + 1
                end repeat

                if displayCheckboxes contains deviceName then
                    -- If we found the a checkbox with the iPad's name, `saCounter` tells us which scroll area contains the device toggle.
                    set deviceToggle to checkbox deviceName of scroll area saCounter of window "Control Center"

                    -- Click the toggle to connect to the device with Universal Control.
                    click deviceToggle

                    -- Click the Control Center menu to close the secondary menu and return to the main menu.
                    click menu bar item "Control Center" of menu bar 1

                    -- Click the Control Center menu again to close the main menu.
                    click menu bar item "Control Center" of menu bar 1
                else
                    -- Universal Control is available, but no devices with deviceName were found.
                    log "The device " & deviceName & " can't be found. Please verify the name of your iPad and update the `deviceName` variable if necessary."
                end if
            else
                -- A checkbox named "Link keyboard and mouse" wasn't found.
                set isConnected to false
                repeat with cb in ccCheckboxes
                    -- Loop through the checkboxes and determine if the device is already connected.
                    if cb contains "Disconnect" then
                        -- If one of the checkboxes has "Disconnect" in its name, the device is already connected.
                        -- Break out of the loop.
                        set isConnected to true
                        exit repeat
                    end if
                end repeat

                if isConnected is equal to true then
                    -- Click the checkbox to disconnect the device.
                    set sidecarToggle to ((checkbox 1 of window "Control Center") whose name contains "Disconnect")
                    click sidecarToggle

                    -- Click the Control Center menu again to close the main menu.
                    click menu bar item "Control Center" of menu bar 1
                else
                    -- The device isn't connected, and no devices are available to connect to. Show an error message.
                    log "No Universal Control devices are in range."
                end if
            end if
        end tell
    end tell
end run
