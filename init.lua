-- hyper, hyper!
-- this key is mapped to SHIFT_R in Karabiner, from private.xml:
-- <item>
--    <name>Right Shift to CmdShiftCtrlAlt</name>
--    <identifier>private.shift_r_to_hyper</identifier>
--    <autogen>__KeyToKey__ KeyCode::SHIFT_R, KeyCode::SHIFT_R, ModifierFlag::COMMAND_L | ModifierFlag::CONTROL_L | ModifierFlag::OPTION_L</autogen>
-- </item>
local hyper = {"⌘", "⌥", "⌃", "⇧"}

-- definitions
hs.grid.MARGINX = 0
hs.grid.MARGINY = 0
hs.grid.GRIDWIDTH = 2
hs.grid.GRIDHEIGHT = 2

-- screens
local display_thunderbolt = "Thunderbolt Display"
local display_cinemahd = "Cinema HD"
local display_internal = "Color LCD"

local screenWatcher = nil

local internal_display = {
    -- on Cinema HD display
    {"Unibox",                      nil,        nil,       nil, nil, nil},
    {"OmniFocus",                   nil,        nil,       nil, nil, nil},
    {"FirefoxDeveloperEdition",     nil,        nil,       nil, nil, nil},
    {"Slack",                       nil,        nil,       nil, nil, nil},
    {"Skype",                       nil,        nil,       nil, nil, nil},
    {"Messages",                    nil,        nil,       nil, nil, nil},
    {"Gitter",                      nil,        nil,       nil, nil, nil},
    {"Hipchat",                     nil,        nil,       nil, nil, nil},


    -- on Thunderbolt Display
    {"Xcode",                       nil,        nil,       nil, nil, nil},
    {"IntelliJ IDEA 14 CE",         nil,        nil,       nil, nil, nil}
}

local dual_display = {
    -- on Cinema HD display
    {"Unibox",                      nil,        display_cinemahd,       nil, nil, nil},
    {"OmniFocus",                   nil,        display_cinemahd,       nil, nil, nil},
    {"FirefoxDeveloperEdition",     nil,        display_cinemahd,       nil, nil, nil},
    {"Slack",                       nil,        display_cinemahd,       nil, nil, nil},
    {"Skype",                       nil,        display_cinemahd,       nil, nil, nil},
    {"Messages",                    nil,        display_cinemahd,       nil, nil, nil},
    {"Gitter",                      nil,        display_cinemahd,       nil, nil, nil},
    {"Hipchat",                     nil,        display_cinemahd,       nil, nil, nil},


    -- on Thunderbolt Display
    {"Xcode",                       nil,        display_thunderbolt,    nil, nil, nil},
    {"IntelliJ IDEA 14 CE",         nil,        display_thunderbolt,    nil, nil, nil}
}

function screensHaveChanged()
    newNumberOfScreens = #hs.screen.allScreens()

    -- FIXME: This is awful if we swap primary screen to the external display. all the windows swap around, pointlessly.
    if lastNumberOfScreens ~= newNumberOfScreens then
        if newNumberOfScreens == 1 then
            print("not doing anything :)")
        elseif newNumberOfScreens == 2 then
            hs.layout.apply(dual_display)
        end
    end

    lastNumberOfScreens = newNumberOfScreens
end

screenWatcher = hs.screen.watcher.new(screensHaveChanged)
screenWatcher:start()

-- a helper function that returns another function that resizes the current window
-- to a certain grid size.
local gridset = function(x, y, w, h)
    return function()
        cur_window = hs.window.focusedWindow()
        hs.grid.set(
            cur_window,
            {x=x, y=y, w=w, h=h},
            cur_window:screen()
        )
    end
end

-- function to move window one screen left or back if it's already on the
-- leftmost
local toNextScreen = function()
    return function()
        currentWindow = hs.window.focusedWindow()
        s = hs.screen{x=1,y=0}
        
        if s == currentWindow:screen() then
            s = hs.screen{x=0,y=0}
            currentWindow:moveToScreen(s)
        else
            currentWindow:moveToScreen(s)
        end
    end
end

-- movement keys
hs.hotkey.bind(hyper, 'j', toNextScreen())
hs.hotkey.bind(hyper, 'h', gridset(0, 0, 1, 2)) -- left half
hs.hotkey.bind(hyper, 'k', hs.grid.maximizeWindow)
hs.hotkey.bind(hyper, 'l', gridset(1, 0, 1, 2)) -- right half

-- layout keys
hs.hotkey.bind(hyper, '2', function() hs.layout.apply(dual_display) end)
hs.hotkey.bind(hyper, '1', function() hs.layout.apply(single_display) end)

-- locking
hs.hotkey.bind(hyper, 'x', function()
    os.execute("/System/Library/CoreServices/Menu\\ Extras/User.menu/Contents/Resources/CGSession -suspend")
end)

-- screensaver
hs.hotkey.bind(hyper, 's', function()
    os.execute("sleep 3 && open -a /System/Library/Frameworks/ScreenSaver.framework/Versions/A/Resources/ScreenSaverEngine.app")
end)

-- Applications
hs.hotkey.bind(hyper, 'i', function()
    os.execute("open /Applications/iTerm.app")
end)

-- watch config for changes and reload when they occur
function reloadConfig(files)
    doReload = false
    for _,file in pairs(files) do
        if file:sub(-4) == ".lua" then
            doReload = true
        end
    end
    if doReload then
        hs.reload()
    end
end

hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/", reloadConfig):start()
hs.alert.show("Config reloaded")
