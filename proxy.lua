----------------------------------------------------------
-- [ Proxy By Evil x ChatGPT - Full Integrated Version ]
-- Includes: Advanced Winner Drop (auto-drop to p1/p2 based on last drop command)
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
--=== [ GLOBALS ] ===--
----------------------------------------------------------
-- track last typed drop command (wd/dd/bg/daw)
lastDropCommand = lastDropCommand or nil

-- position holders (may be set by /p1 /p2)
p1x, p1y = p1x, p1y
p2x, p2y = p2x, p2y

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
        lastDropCommand = "daw"
        return true
    end

    if packet:find("/dd (%d+)") then
        local txt = packet:match("action|input\n|text|/dd (%d+)")
        Utils.dropItem(1796, txt)
        lastDropCommand = "dd"
        Utils.console("Succes Drop `0"..txt.." `2Diamond Lock")
        return true
    end

    if packet:find("/wd (%d+)") then
        local txt = packet:match("action|input\n|text|/wd (%d+)")
        Utils.dropItem(242, txt)
        lastDropCommand = "wd"
        Utils.console("Succes Drop `0"..txt.." `2World Lock")
        return true
    end

    if packet:find("/bg (%d+)") then
        local txt = packet:match("action|input\n|text|/bg (%d+)")
        Utils.dropItem(7188, txt)
        lastDropCommand = "bg"
        Utils.console("Succes Drop `0"..txt.." `2Blue Gem Lock")
        return true
    end
end)

----------------------------------------------------------
--=== [ MODULE: ADVANCED WINNER DROP ] ===--
-- Advanced logic: drop to p1/p2 using lastDropCommand mapping,
-- checks solid tile below, finds nearby solid if needed,
-- animated preview and direct drop via dialog_return (bypass visible dialog).
----------------------------------------------------------

-- mapping simple: lastDropCommand -> itemID
local LAST_DROP_MAP = {
    wd  = 242,   -- World Lock
    dd  = 1796,  -- Diamond Lock
    bg  = 7188,  -- Blue Gem Lock
    daw = nil    -- special (drop all)
}

-- rate-limiter per-pos
local lastDropTime = {}

-- helper: get inventory amount safely
local function invAmount(id)
    for _, inv in pairs(getInventory()) do
        if inv.id == id then return inv.amount end
    end
    return 0
end

-- helper: find tile entry by tile coords (x tile, y tile)
local function getTileAt(tx, ty)
    for _, t in pairs(getTile()) do
        if (t.x == tx) and (t.y == ty) then
            return t
        end
    end
    return nil
end

-- helper: is there a solid fg under (tx,ty) ? we'll consider fg ~= 0 as solid
local function isSolidBelow(tx, ty)
    local below = getTileAt(tx, ty + 1)
    if below and below.fg and tonumber(below.fg) ~= 0 then
        return true
    end
    return false
end

-- search nearby solid tile radius (includes target). returns chosen {x,y} or nil
local function findNearbySolid(tx, ty, radius)
    radius = radius or 3
    -- scan in expanding square
    for r = 0, radius do
        for dx = -r, r do
            for dy = -r, r do
                local nx, ny = tx + dx, ty + dy
                if isSolidBelow(nx, ny) then
                    return nx, ny
                end
            end
        end
    end
    return nil
end

-- direct drop without opening a visible drop dialog (send dialog_return directly)
local function directDropItem(itemID, count)
    if not itemID or count <= 0 then return false end
    -- send the dialog_return directly (bypass typical "drop" dialog popup)
    sendPacket(2, "action|dialog_return\ndialog_name|drop_item\nitemID|"..tostring(itemID).."|\ncount|"..tostring(count).."\n")
    return true
end

-- perform animated drop at tile (tx,ty). state param optional (appearance)
local function performDropAt(tx, ty, itemID, count)
    -- basic safety
    if not tx or not ty or not itemID or count <= 0 then
        Utils.console("`c[Drop] Invalid parameters.")
        return false
    end

    local posKey = tostring(tx) .. ":" .. tostring(ty)
    local now = os.time()
    if lastDropTime[posKey] and (now - lastDropTime[posKey] < 2) then
        Utils.console("`c[Drop] Rate limit – tunggu sebentar sebelum drop lagi di posisi itu.")
        return false
    end

    -- animation: spawn "place" preview packet (type 0) — keep same style as script
    sendPacketRaw(false, { type = 0, x = tx * 32, y = ty * 32, state = 32 })
    SleepS(0.20)

    -- perform actual drop (direct)
    local ok = directDropItem(itemID, count)
    if ok then
        lastDropTime[posKey] = now
        Utils.console("`c[Drop] Dropped "..tostring(count).." x "..tostring(itemID).." at ["..tx..","..ty.."]")
        return true
    else
        Utils.console("`c[Drop] Failed to send drop packet.")
        return false
    end
end

-- wrapper to decide what to drop based on lastDropCommand
local function dropToPosUsingLastType(tx, ty)
    if not tx or not ty then
        Utils.console("`c[Drop] Pos not set.")
        return false
    end

    local lcmd = lastDropCommand -- from your Drop Dialog Blocker / tracked earlier
    if not lcmd then
        Utils.console("`c[Drop] No last drop command detected. Ketik /wd, /dd, /bg atau /daw dulu.")
        return false
    end

    if lcmd == "daw" then
        -- drop all locks: BlueGem, Diamond, World (if exist in inventory)
        local b = invAmount(7188)
        local d = invAmount(1796)
        local w = invAmount(242)
        local found = false
        if b > 0 then found = true; performDropAt(tx, ty, 7188, b); SleepS(0.3) end
        if d > 0 then found = true; performDropAt(tx, ty, 1796, d); SleepS(0.3) end
        if w > 0 then found = true; performDropAt(tx, ty, 242, w); SleepS(0.3) end
        if not found then Utils.console("`c[Drop] Inventory empty for all lock types.") end
        return found
    else
        local iid = LAST_DROP_MAP[lcmd]
        if not iid then
            Utils.console("`c[Drop] Unknown last drop type.")
            return false
        end
        local amt = invAmount(iid)
        if amt <= 0 then
            Utils.console("`c[Drop] Kamu gak punya item jenis itu (id "..tostring(iid)..").")
            return false
        end

        -- make sure we drop on a valid tile (search nearby solid)
        local chooseX, chooseY = nil, nil
        if isSolidBelow(tx, ty) then
            chooseX, chooseY = tx, ty
        else
            local nx, ny = findNearbySolid(tx, ty, 3)
            if nx and ny then
                chooseX, chooseY = nx, ny
                Utils.console("`c[Drop] Target tidak ada solid di bawah, pindah ke ["..nx..","..ny.."].")
            else
                Utils.console("`c[Drop] Tidak menemukan tile solid dekat target. Batalkan.")
                return false
            end
        end

        return performDropAt(chooseX, chooseY, iid, amt)
    end
end

-- hook: listen /w1 and /w2 in the existing onTextPacket hook
AddHook("onTextPacket", "Evil_WinnerDrop", function(type, packet)
    -- accept both typed commands and button clicks
    if packet:find("/w1") or packet:find("buttonClicked|w1") then
        if not p1x or not p1y then
            Utils.console("`c[Drop] Pos1 belum diset. Gunakan /p1 atau tombol p1 dulu.")
            return true
        end
        -- find best nearby solid before dropping
        local ok = dropToPosUsingLastType(p1x, p1y)
        if ok then Utils.console("`c[Drop] /w1 executed.") end
        return true
    end

    if packet:find("/w2") or packet:find("buttonClicked|w2") then
        if not p2x or not p2y then
            Utils.console("`c[Drop] Pos2 belum diset. Gunakan /p2 atau tombol p2 dulu.")
            return true
        end
        local ok = dropToPosUsingLastType(p2x, p2y)
        if ok then Utils.console("`c[Drop] /w2 executed.") end
        return true
    end

    return false
end)

----------------------------------------------------------
--=== [ MODULE: DROP DIALOG BLOCKER ] ===--
----------------------------------------------------------
-- track last drop command from typed inputs
-- (this updates the global lastDropCommand used by Advanced Winner Drop)

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
        local dialog = var[1] or ""
        if lastDropCommand and (
            dialog:find("Drop World Lock")
            or dialog:find("Drop Diamond Lock")
            or dialog:find("Drop Blue Gem Lock")
        ) then
            lastDropCommand = lastDropCommand -- keep value; just block visible dialog
            return true
        end
    end
end)

----------------------------------------------------------
--=== [ MAIN INIT ] ===--
----------------------------------------------------------
Utils.console("`cProxy by Evil x ChatGPT Loaded!")
sendVariant({[0] = "OnDialogRequest", [1] = UI.dialog})

-- optional: friendly startup messages
-- sendPacket(2, "action|input\n|text|:)")
-- SleepS(5)
-- Utils.console("`2HAVE FUN SIR :)")

-- final
return false
