----------------------------------------------------------
-- [ Proxy By Evil x ChatGPT ]
-- Clean Modular Version + Drop Dialog Blocker
----------------------------------------------------------

--=== [ MODULE: UI ] ===--
local UI = {}

UI.dialog = [[
set_border_color|0,191,255,255
set_bg_color|15,15,25,230
add_label_with_icon|big|`9Proxy By Evil x ChatGPT``|left|14788|
add_spacer|small|
add_label|small|`wHello `c]]..getLocal().name..[[``!|left|
add_label|small|`oIf you have any question, feel free to ask me!``|left|
add_spacer|small|
add_label|small|`c───────────────────────────────``|left|
add_label_with_icon|small|`wYour UID: `c]]..getLocal().userId..[[``|left|482|
add_label_with_icon|small|`wPosition: `c]]..(getLocal().pos.x // 32)..[[, ]]..(getLocal().pos.y // 32)..[[``|left|482|
add_label|small|`c───────────────────────────────``|left|
add_label_with_icon|big|`4 Be Careful!``|left|3102|
add_spacer|small|
add_label_with_icon|small|`wUse `c/Menu`` for commands|left|482|
add_label_with_icon|small|`wPress `cFriend`` button for more features|left|482|
add_label_with_icon|small|`wUsing `cPos1`` will drop on left side|left|482|
add_label_with_icon|small|`wUsing `cPos2`` will drop on right side|left|482|
add_spacer|small|
add_custom_button|next0|textLabel:`c                  Next                 ;middle_colour:255;border_colour:0,191,255;display:block;|
]]

UI.menu = [[
set_border_color|0,191,255,255
set_bg_color|15,15,25,230
add_label_with_icon|big|`9Proxy By Evil x ChatGPT``|left|14788|
add_spacer|small|
add_label_with_icon|big|`bDrop Commands``|left|7188|
add_spacer|small|
add_label_with_icon|small|`w/wd``  Drop World Lock|left|242|
add_label_with_icon|small|`w/dd``  Drop Diamond Lock|left|1796|
add_label_with_icon|small|`w/bg``  Drop Blue Gem Lock|left|7188|
add_label_with_icon|small|`w/daw``  Drop All Locks|left|482|
add_spacer|small|
add_label_with_icon|big|`bWin/Pos Commands``|left|7188|
add_spacer|small|
add_label_with_icon|small|`w/w1``  Drop Lock to Winner 1 (`4Soon``)|left|482|
add_label_with_icon|small|`w/w2``  Drop Lock to Winner 2 (`4Soon``)|left|482|
add_label_with_icon|small|`w/p1``  Mark Player 1 (Left Room)|left|482|
add_label_with_icon|small|`w/p2``  Mark Player 2 (Right Room)|left|482|
add_label_with_icon|small|`w/take``  Take Bets (`cp1`` + `cp2``)|left|482|
add_spacer|small|
add_custom_button|next1|textLabel:`c                  Next                  ;middle_colour:255;border_colour:0,191,255;display:block;|
]]

UI.advMenu = [[
set_border_color|0,191,255,255
set_bg_color|15,15,25,230
add_label_with_icon|big|`9Advanced Menu``|left|14788|
add_spacer|small|

-- Actions
add_label_with_icon|small|`bActions``|left|7188|
add_label_with_icon|small|`wTake``  Take Bet|left|6140|
add_label_with_icon|small|`w1``  Drop To Winner 1 (Soon)|left|7188|
add_label_with_icon|small|`w2``  Drop To Winner 2 (Soon)|left|7188|
add_label_with_icon|small|`wrench``  Wrench Mode (Soon)|left|32|
add_spacer|small|

-- Utilities
add_label_with_icon|small|`bUtilities``|left|7188|
add_label_with_icon|small|`p1``  Save Pos1 (Left)|left|1422|
add_label_with_icon|small|`p2``  Save Pos2 (Right)|left|1422|
add_label_with_icon|small|`slog``  Save Log (Soon)|left|758|
add_spacer|small|

-- Navigation
add_label_with_icon|small|`bNavigation``|left|7188|
add_custom_button|wh|textLabel:`c                  home                  ;middle_colour:255;border_colour:0,191,255;display:block;|
add_spacer|small|

-- Done Button
add_custom_button|done|textLabel:`c                  Done                  ;middle_colour:255;border_colour:0,191,255;display:block;|
]]

----------------------------------------------------------
--=== [ MODULE: UTILS ] ===--
----------------------------------------------------------
local Utils = {}

function Utils.console(str)
    logToConsole("``[`cEvilxChatGPT``] " .. str)
end

function Utils.checkitm(id)
    for _, inv in pairs(getInventory()) do 
        if inv.id == id then 
            return inv.amount 
        end 
    end 
    return 0 
end 

function Utils.dropItem(id, count)
    sendPacket(2,"action|drop\n|itemID|"..id.."\n")
    sendPacket(2,"action|dialog_return\ndialog_name|drop_item\nitemID|"..id.."|\ncount|"..count.."\n")
end

----------------------------------------------------------
--=== [ MODULE: LOGIC ] ===--
----------------------------------------------------------
local Logic = {}

function Logic.collect()
    local tiles = {
        {p1x, p1y}, 
        {p2x, p2y}
    }

    for _, obj in pairs(getWorldObject()) do
        for _, t in pairs(tiles) do
            if (obj.pos.x)//32 == t[1] and (obj.pos.y)//32 == t[2] then
                sendPacketRaw(false, {type=11, value=obj.oid, x=obj.pos.x, y=obj.pos.y})
            end
        end
    end
end

----------------------------------------------------------
--=== [ MODULE: HOOKS ] ===--
----------------------------------------------------------
AddHook("onTextPacket", "Evil_onText", function(type, packet)
    if packet:find("action|friends") then
        sendVariant({[0] = "OnDialogRequest", [1] = UI.advMenu})
    end

    if packet:find("buttonClicked|next0") then
        sendVariant({[0] = "OnDialogRequest", [1] = UI.menu})
        Utils.console("`cNext  Menu Opened")
        return true
    end

    if packet:find("buttonClicked|next1") then
        sendVariant({[0] = "OnDialogRequest", [1] = UI.advMenu})
        Utils.console("`cNext  Advanced Menu Opened")
        return true
    end

    if packet:find("buttonClicked|wh") then
        sendVariant({[0] = "OnDialogRequest", [1] = UI.dialog})
        Utils.console("`cBack  Dialog Opened")
        return true
    end

    if packet:find("buttonClicked|done") then
        sendPacket(2, "action|dialog_return\ndialog_name|close\n")
        Utils.console("`cDialog closed successfully.")
        return true
    end

    if packet:find("buttonClicked|p1") or packet:find("/p1") then
        p1x, p1y = getLocal().pos.x // 32, getLocal().pos.y // 32
        Utils.console("`cPos1 ["..p1x.."], ["..p1y.."]")
        return true
    end

    if packet:find("buttonClicked|p2") or packet:find("/p2") then
        p2x, p2y = getLocal().pos.x // 32, getLocal().pos.y // 32
        Utils.console("`cPos2 ["..p2x.."], ["..p2y.."]")
        return true
    end

    if packet:find("buttonClicked|Take") or packet:find("/take") then
        Logic.collect()
        Utils.console("`cCollecting Bets")
    end

    if packet:find("/menu") or packet:find("buttonClicked|menu") then
        sendVariant({[0] = "OnDialogRequest", [1] = UI.menu})
        Utils.console("`cMenu Opened")
    end

    if packet:find("/daw") then
        Utils.dropItem(7188, Utils.checkitm(7188))
        Utils.dropItem(1796, Utils.checkitm(1796))
        Utils.dropItem(242, Utils.checkitm(242))
        return true
    end

    if packet:find("/dd (%d+)") then
        local txt = packet:match("action|input\n|text|/dd (%d+)")
        Utils.dropItem(1796, txt)
        Utils.console("Succes Drop `0"..txt.." `2Diamond Lock")
        return true
    end

    if packet:find("/wd (%d+)") then
        local txt = packet:match("action|input\n|text|/wd (%d+)")
        Utils.dropItem(242, txt)
        Utils.console("Succes Drop `0"..txt.." `2World Lock")
        return true
    end

    if packet:find("/bg (%d+)") then
        local txt = packet:match("action|input\n|text|/bg (%d+)")
        Utils.dropItem(7188, txt)
        Utils.console("Succes Drop `0"..txt.." `2Blue Gem Lock")
        return true
    end
end)

----------------------------------------------------------
--=== [ MODULE: DROP DIALOG BLOCKER ] ===--
----------------------------------------------------------
local lastDropCommand = nil

AddHook("OnTextPacket", "Evil_DropCommandTrack", function(type, packet)
    if packet:find("action|input\n|text|/wd") then
        lastDropCommand = "wd"
    elseif packet:find("action|input\n|text|/dd") then
        lastDropCommand = "dd"
    elseif packet:find("action|input\n|text|/bg") then
        lastDropCommand = "bg"
    elseif packet:find("action|input\n|text|/daw") then
        lastDropCommand = "daw"
    end
end)

AddHook("OnVarlist", "Evil_DropDialogBlock", function(var)
    if var[0] == "OnDialogRequest" then
        local dialog = (var[1] or ""):lower() -- bikin lowercase semua
        if lastDropCommand and (
            dialog:find("drop world lock")
            or dialog:find("drop diamond lock")
            or dialog:find("drop blue gem lock")
        ) then
            lastDropCommand = nil
            return true -- blokir dialog sepenuhnya
        end
    end
end)

----------------------------------------------------------
--=== [ MAIN INIT ] ===--
----------------------------------------------------------
Utils.console("`cProxy by Evil x ChatGPT Loaded!")
sendVariant({[0] = "OnDialogRequest", [1] = UI.dialog})

