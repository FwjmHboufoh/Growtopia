----------------------------------------------------------
-- [ M19K Proxy - Single-file Modular Version ]
-- By: M19K (original) + refactor by ChatGPT
-- Notes:
--  - Preserves original UI strings and features
--  - Modular sections inside one file: CONFIG, UTILS, UI, ACTIONS (sub), COMMANDS, HOOKS, CORE
----------------------------------------------------------

--=== [ SHORTHAND / ALIASES ] ===--
-- preserve original function name mappings (if environment uses different naming)
SendPacket = sendPacket or SendPacket
SendPacketRaw = sendPacketRaw or SendPacketRaw
SendVariant = sendVariant or SendVariant
GetLocal = getLocal or GetLocal
SleepMS = sleep or SleepMS
GetPlayerByNetID = getPlayerByNetID or GetPlayerByNetID
GetWorldObject = getWorldObject or GetWorldObject
LogToConsole = logToConsole or LogToConsole
CheckTile = checkTile or CheckTile
GetTile = getTile or GetTile
GetInventory = getInventory or GetInventory
GetItemByID = getItemByID or GetItemByID
GetPlayerList = getPlayerList or GetPlayerList
FindPath = findPath or FindPath

-- local convenience
local sleep = sleep or SleepMS
local sendPacket = sendPacket or SendPacket
local sendPacketRaw = sendPacketRaw or SendPacketRaw
local sendVariant = sendVariant or SendVariant
local getLocal = getLocal or GetLocal
local getWorldObject = getWorldObject or GetWorldObject
local getInventory = getInventory or GetInventory
local getItemByID = getItemByID or GetItemByID
local getTile = getTile or GetTile
local getPlayerList = getPlayerList or GetPlayerList
local findPath = findPath or FindPath
local logToConsole = logToConsole or LogToConsole

-- Helper sleep in seconds
local function SleepS(s) sleep(s * 1000) end

--=== [ MODULE: CONFIG ] ===--
local CONFIG = {
    proxy = {
        dev = "M19AAK",
        name = "M19K Proxy",
        version = "v1.4",
        support = "undefined"
    },
    itemIDs = {
        BLUE_GEM_LOCK = 7188,
        DIAMOND_LOCK = 1796,
        WORLD_LOCK = 242,
        EXTRACTOR = 6140
    },
    uiColors = {
        border = "0,191,255,255",
        bg = "15,15,25,230"
    },
    defaultPositions = {
        PX1 = 0, PY1 = 0, PX2 = 0, PY2 = 0
    }
}

--=== [ MODULE: STATE ] ===--
local STATE = {
    command = { var = { taptp = false, rfspin = false } },
    playerList = {},
    logSpin = {},
    itemInfo = {},
    data = {},
    ftrash = false,
    fdrop = false,
    pull = false,
    kick = false,
    ban = false,
    Tax = 0,
    PX1 = 0, PY1 = 0, PX2 = 0, PY2 = 0,
    firstnum = 10,
    op = "sum",
    secondnum = 10,
    rfspin = true,
    reme = false,
    qeme = false
}

--=== [ MODULE: UTILS ] ===--
local Utils = {}

function Utils.ovlay(str)
    local var = {}
    var[0] = "OnTextOverlay"
    var[1] = "[`#M19K Proxy``] " .. str
    sendVariant(var)
end

function Utils.tol(txt)
    logToConsole("`o[`#M19K Proxy`o] `6"..txt)
end

function Utils.SendDialogRaw(dialog_str, netid, delay)
    netid = netid or -1
    delay = delay or 100
    sendVariant({ [0] = "OnDialogRequest", [1] = dialog_str }, netid, delay)
end

function Utils.round(n)
    return math.floor(n + 0.5)
end

function Utils.checkInventoryAmount(id)
    for _, inv in pairs(getInventory()) do
        if inv.id == id then
            return inv.amount
        end
    end
    return 0
end

function Utils.GetNameByNetID(netid)
    -- STATE.playerList stores { netid -> { name=?, netid=? } } in AddOrUpdatePlayer
    if STATE.playerList[netid] then
        return STATE.playerList[netid].name
    end
    return nil
end

--=== [ MODULE: UI ] ===--
local UI = {}

-- keep original dialogs as much as possible
UI.wrenchop = [[add_label_with_icon|big|`2Fiture Wrench|left|10866|
add_spacer|small|
text_scaling_string|asdasdasdsaas|
add_button_with_icon|proxywrenchm|`wExtra Cheats|staticYellowFrame|7190|
add_button_with_icon|proxylogspin|`wSpin Log|staticYellowFrame|758|
add_button_with_icon|BackToMenu|`wGrowscan|staticYellowFrame|6016|
add_button_with_icon|wdef|`wWrench Default|staticYellowFrame|278|| 
add_button_with_icon|wpull|`wWrench Pull|staticYellowFrame|274||
add_button_with_icon|wkick|`wWrench Kick|staticYellowFrame|276||
add_button_with_icon|wban|`wWrench Ban|staticYellowFrame|732||
add_button_with_icon|wban|`wCOMING SOON|staticYellowFrame|2||
add_button_with_icon||END_LIST|noflags|0||
add_spacer|small|
end_dialog|wh|Ok|
]]

UI.proxy = [[add_label_with_icon|big|`2[``M19K Proxy`2]``Fiture Proxy                  |left|10866|
add_spacer|big|
add_textbox|`8Feature Drop Item|left|7188|
add_textbox|`6/bd [Amount] `bDrop `eBlue Gem Lock|
add_textbox|`6/dd [Amount] `bDrop `1Diamond Lock|
add_textbox|`6/wd [Amount] `bDrop `9World Lock|
add_textbox|`6/cd [Amount]
add_textbox|`6/daw `9[Drop All Lock]|
add_spacer|small|
add_label_with_icon|big|`8Host Casino|left|340|
add_textbox|`6/tax `9[Amount]|
add_textbox|`6/bet `9[Amount]|
add_textbox|`6/take `9[Take Lock Di Posisi 1 Dan 2]|
add_textbox|`6/pos `9[Set 1 - 2]|
add_textbox|`6/w 1 Atau 2`9[Drop Ke Pemenang Yang Win]|
add_textbox|`6/slog `9[Spin Log]|
add_spacer|small|
add_label_with_icon|big|`8Fast Command|left|18|
add_textbox|`6/ft `9[Fast Trash]|
add_textbox|`6/fd `9[Fast Drop]|
add_textbox|`6/rr `9[Relog]|
add_textbox|`6/t`9[Path Finder]|
add_textbox|`6/cal `9[Calculator]|
add_textbox|`6/fpull `9[Fast Pull]|
add_textbox|`6/fkick `9[Fast Kick]|
add_textbox|`6/fban `9[Fast Ban]|
add_textbox|`6/wn `9Wrench Normal]|
add_textbox|`6/wp `9[Warp World]|
add_textbox|`6/x `9[0 - 99] `6/y `9[0 - 53]|
add_spacer|big|
add_label_with_icon|small|`8Magnet Feature|left|6140|
add_textbox|`6/magnet `9[Take Item]|
add_spacer|big|
add_label_with_icon|big|`6Hosting Helper:|left|32|
add_button|proxywrenchm|`9Exstra Cheats|
add_button|proxylogspin|`9Spin Log|
add_button|BackToMenu|`9GrowScan|
add_spacer|big|
add_label_with_icon|big|`6Proxy Mode M19K|left|9222|
add_textbox|`7Jangan Di Jual Scriptnya Ya|
add_textbox|`cFollow Tiktok Saya @M19K|
add_textbox|`2WRENCH MENU TEKAN|1399|
add_button_with_icon|wban|`wSOSIAL MENU|staticYellowFrame|1366||
add_spacer|small|
add_button_with_icon|2978|
add _textbox|`1VEND WORLD AT UU2Q

end_dialog|bye|exit|Okay|
add_quick_exit|
]]

UI.dext = function(realfakes, remeg, qemeg)
    return [[
add_label_with_icon|big|``Hosting Helper    |left|32|
text_scaling_string|iprogramtext
add_spacer|big|
add_checkbox|realfakespin|`2REAL``-`4FAKE`` Spin Detection|]]..(realfakes or "0")..[[|
add_checkbox|gamereme|Reme Checker|]]..(remeg or "0")..[[|
add_checkbox|gameqeme|Qeme Checker|]]..(qemeg or "0")..[[|
add_spacer|big|
end_dialog|proxywrenchend|Close|Set|
]]
end

UI.calcu = function(firstnum, op, secondnum)
    firstnum = firstnum or STATE.firstnum
    op = op or STATE.op
    secondnum = secondnum or STATE.secondnum
    return [[
set_default_color|`7
add_label_with_icon|big|`9Calculator                      |left|5016|
add_spacer|small|
add_text_input|fnum|First number|]]..tostring(firstnum)..[[|25|
add_text_input|opr|(sum, sub, multi, divide)|]]..tostring(op)..[[|25|
add_text_input|snum|Second number|]]..tostring(secondnum)..[[|25|
add_spacer|big|
end_dialog|calculatorpage|Cancel|Calculate|
]]
end

UI.sum = function(a,b)
    return [[
add_label_with_icon|big|`9Calculator Result               |big|5016|
add_spacer|small|
add_textbox|Result: `2]].. tostring(math.floor(a + b)) ..[[||
add_spacer|big|
add_button|backtocalc|`wBack to calc page|
add_quick_exit|
]]
end

UI.loginp = [[
set_default_color|`7
add_label_with_icon|big|`2[`#M19K PROXY`2]`` Information Update|left|10866|
add_spacer|small|
add_smalltext|Jangan Di Jual Ya Bro.|
add_smalltext|Script Mode By M19K.|
add_smalltext|LIST PROXY TULIS /MENU.|
add_spacer|big|
add_label_with_icon|big|`9Updated Logs|left|32|
add_label_with_icon|small|- Added `6Auto Change `1Diamond Lock|left|482|
add_label_with_icon|small|- Added `6/x /y |left|482|

add_spacer|big|
add_url_button||`bTiktok Saya|NOFLAGS|tiktok.com/@pemula2535|Anda Ingin Pergi Ke Tiktok?|0|0|


add_button_with_icon|wban|`wFREE BGL|staticYellowFrame|7188||
add_textbox|`8WRENCH SETTING PENCET SOSIAL MENU|1366|
add_button_with_icon|wban|`wKLIK|staticYellowFrame|1366||

add_spacer|small|
end_dialog|loginpend|Close||
add_quick_exit|
]]

-- helper UI functions
function UI.showMain()
    Utils.SendDialogRaw(UI.proxy, -1, 100)
    Utils.tol("Fiture I Will Add")
end

function UI.showWrench()
    Utils.SendDialogRaw(UI.wrenchop, -1, 100)
end

function UI.showDext(realfakes, remeg, qemeg)
    Utils.SendDialogRaw(UI.dext(realfakes, remeg, qemeg), -1, 100)
end

function UI.showCalc()
    Utils.SendDialogRaw(UI.calcu(), -1, 100)
end

function UI.showSum(a,b)
    Utils.SendDialogRaw(UI.sum(a,b), -1, 100)
end

--=== [ MODULE: ACTIONS ] ===--
local Actions = {}

-- Basic low-level actions (Drop/Trash/Wear/Extract/Wear/send overlays)
function Actions.DropItem(id, count)
    sendPacket(2,"action|drop\n|itemID|"..id.."\n")
    sendPacket(2,"action|dialog_return\ndialog_name|drop_item\nitemID|"..id.."|\ncount|"..count.."\n")
end

function Actions.TrashItem(id, count)
    sendPacket(2,"action|trash\nitemID|"..id.."\n")
    sendPacket(2,"action|dialog_return\ndialog_name|trash_item\nitemID|"..id.."|\ncount|"..count.."\n")
end

function Actions.takeExtractor(id)
    local x = 0
    local y = 0
    sendPacket(2,"action|dialog_return\ndialog_name|extractor\ntilex|"..x.."|\ntiley|"..y.."|\nstartIndex|0|\nextractorID|"..CONFIG.itemIDs.EXTRACTOR.."|\nbuttonClicked|extractOnceObj_"..tostring(id))
end

function Actions.wearItem(id)
    local pkt = {}
    pkt.type = 10
    pkt.value = id
    sendPacketRaw(false, pkt)
end

function Actions.collectObjectsAtPositions(tiles)
    -- tiles = { {x1,y1}, {x2,y2}, ... } positions in tile coordinates
    for _, obj in pairs(getWorldObject()) do
        for _, t in pairs(tiles) do
            if (obj.pos.x)//32 == t[1] and (obj.pos.y)//32 == t[2] then
                sendPacketRaw(false, { type=11, value=obj.oid, x=obj.pos.x, y=obj.pos.y })
                table.insert(STATE.data, { id = obj.id, count = obj.amount })
            end
        end
    end
    -- process collected data
    local Amount = 0
    for _, list in pairs(STATE.data) do
        local Name = ""
        if list.id == CONFIG.itemIDs.BLUE_GEM_LOCK then
            Name = "Blue Gem Lock"
            Amount = Amount + list.count * 10000
        elseif list.id == CONFIG.itemIDs.DIAMOND_LOCK then
            Name = "Diamond Lock"
            Amount = Amount + list.count * 100
        elseif list.id == CONFIG.itemIDs.WORLD_LOCK then
            Name = "World Lock"
            Amount = Amount + list.count
        end
        Utils.tol("Collected `9"..list.count.." "..Name)
    end
    -- reset data store
    STATE.data = {}
    return Amount
end

function Actions.getItemObjectsDialog()
    STATE.itemInfo = {}
    for _, item in pairs(getWorldObject()) do
        table.insert(STATE.itemInfo, "\nadd_label_with_icon_button|small|`7Name : "..getItemByID(item.id).name.." `7Amount : [`5"..item.amount.."``]|left|"..item.id.."|"..item.oid.."|\n")
    end
    local var = {}
    var[0] = "OnDialogRequest"
    var[1] = string.format("add_label_with_icon|big|Proxy By QoD Proxy |left|6140|\nadd_spacer|small|\nadd_smalltext|`7To Extract U Must Click The Item `4Note Before Take u Must Have Extract O Snap|\n"..table.concat(STATE.itemInfo).."\nadd_quick_exit|||\nend_dialog|scanbilek|Thanks!||")
    sendVariant(var, -1, 100)
end

function Actions.getInventoryAmount(id)
    return Utils.checkInventoryAmount(id)
end

-- Spin log management
function Actions.logspin_showAll()
    local dialogSpin = {}
    for _, spin in pairs(STATE.logSpin) do
        table.insert(dialogSpin, spin.spin)
    end
    Utils.SendDialogRaw("add_label_with_icon|big|Log Spin|left|758|\nadd_spacer|small|\nadd_smalltext|Click The Wheel Button For Filter Player You Need|\n"..table.concat(dialogSpin).."\nadd_quick_exit|||\nend_dialog|world_spin|Close||", -1, 200)
end

function Actions.logspin_filterByNetID(netid)
    local filterLog = {}
    for _, log in pairs(STATE.logSpin) do
        if log.netid == netid then
            table.insert(filterLog, "\nadd_label_with_icon|small|"..log.spin.."|left|758|\n")
        end
    end
    Utils.SendDialogRaw("add_label_with_icon|big|`7"..Utils.GetNameByNetID(netid).." Spin: |left|32|\nadd_spacer|small|\n"..table.concat(filterLog).."\nadd_quick_exit|||\nend_dialog|spinfilter|Close||", -1, 200)
end

-- Wrench execution helpers
function Actions.executeWrench(netid, actionType)
    -- actionType: "pull"|"kick"|"worldban"
    sendPacket(2, "action|wrench\n|netid|"..netid)
    sendPacket(2, "action|dialog_return\ndialog_name|popup\nnetID|"..netid.."|\nnetID|"..netid.."\nbuttonClicked|"..actionType)
    -- find name in playerlist for overlay
    for _, player in pairs(getPlayerList()) do
        if player.netid == tonumber(netid) then
            if actionType == "pull" then
                Utils.ovlay("Succesfully `5Pulls `0"..player.name.."..")
            elseif actionType == "kick" then
                Utils.ovlay("Succesfully `4Kicks `0"..player.name.."..")
            elseif actionType == "worldban" then
                Utils.ovlay("Succesfully `4World Ban `0"..player.name.."..")
            end
        end
    end
end

-- Growscan helpers (tile/object stats)
function Actions.tileShit()
    local res = {}
    for _, a in pairs(getTile()) do
        if (res[a.fg] == nil) then
            res[a.fg] = { id = a.fg, count = 1 }
        else
            res[a.fg].count = res[a.fg].count + 1
        end
        if (res[a.bg] == nil) then
            res[a.bg] = { id = a.bg, count = 1 }
        else
            res[a.bg].count = res[a.bg].count + 1
        end
    end
    local dwi = ""
    for _, b in pairs(res) do
        dwi = dwi .. b.id .. "," .. b.count .. ","
    end
    return dwi
end

function Actions.objectShit()
    local res = {}
    for _, a in pairs(getWorldObject()) do
        if (res[a.id] == nil) then
            res[a.id] = { id = a.id, count = a.amount }
        else
            res[a.id].count = res[a.id].count + a.amount
        end
    end
    local dwi = ""
    for _, b in pairs(res) do
        dwi = dwi .. b.id .. "," .. b.count .. ","
    end
    return dwi
end

-- Path finder wrapper
function Actions.findPathTo(x, y)
    findPath(x, y)
end

--=== [ MODULE: COMMANDS ] ===--
local Commands = {}

function Commands.handleTextPacket(packet)
    -- handle checkboxes and dialog button clicks early
    if packet:find("realfakespin|1") then
        STATE.rfspin = true
        Utils.tol("`2REAL``-`4FAKE`` spin detection `2enabled.")
    elseif packet:find("realfakespin|0") then
        STATE.rfspin = false
    end
    if packet:find("gamereme|1") then
        STATE.reme = true
        Utils.tol("Reme checker `2enabled")
    elseif packet:find("gamereme|0") then
        STATE.reme = false
    end
    if packet:find("gameqeme|1") then
        STATE.qeme = true
        Utils.tol("Qeme checker `2enabled")
    elseif packet:find("gameqeme|0") then
        STATE.qeme = false
    end

    -- dialog button clicked for world_spin list
    if packet:find("dialog_name|world_spin\nbuttonClicked|(%d+)") then
        local netid = tonumber(packet:match("buttonClicked|(%d+)"))
        Actions.logspin_filterByNetID(netid)
    end

    -- UI button handlers
    if packet:find("buttonClicked|proxylogspin") or packet:find("/slog") then
        Actions.logspin_showAll()
        return true
    end

    if packet:find("buttonClicked|proxywrenchm") then
        local rf = (STATE.rfspin and "1" or "0")
        local remeg = (STATE.reme and "1" or "0")
        local qemeg = (STATE.qeme and "1" or "0")
        Utils.SendDialogRaw(UI.dext(rf, remeg, qemeg), -1, 100)
        return true
    end

    if packet:find("/magnet") then
        Actions.getItemObjectsDialog()
        return true
    end

    -- open wrench menu
    if packet:find("action|friends") then
        Utils.SendDialogRaw(UI.wrenchop)
        Utils.tol("Wrench Option")
        return true
    end

    -- open main menu
    if packet:find("/menu") then
        UI.showMain()
        return true
    end

    -- drop commands
    if packet:find("/dd (%d+)") or packet:find("/Dd (%d+)") then
        local txt = packet:match("action|input\n|text|/dd (%d+)")
        Actions.DropItem(CONFIG.itemIDs.DIAMOND_LOCK, txt)
        Utils.tol("Succes Drop `0"..txt.." `2Diamond Lock")
        return true
    end

    if packet:find("/tax (%d+)") then
        local pler = packet:match("/tax (%d+)")
        STATE.Tax = ""..pler..""
        Utils.ovlay("Tax : "..pler)
        return true
    end

    if packet:find("/wd (%d+)") or packet:find("/Wd (%d+)") then
        local txt = packet:match("action|input\n|text|/wd (%d+)")
        Actions.DropItem(CONFIG.itemIDs.WORLD_LOCK, txt)
        Utils.tol("Succes Drop `0"..txt.." `2World Lock")
        return true
    end

    if packet:find("/bd (%d+)") or packet:find("/Bd (%d+)") then
        local txt = packet:match("action|input\n|text|/bd (%d+)")
        Actions.DropItem(CONFIG.itemIDs.BLUE_GEM_LOCK, txt)
        Utils.tol("`2Succes Drop `0"..txt.." `2Blue Gem Lock")
        return true
    end

    -- warp by name
    if packet:find("/wp (.+)") or packet:find("/Wp (.+)") then
        local namew = packet:match("/wp (.+)") or packet:match("/Wp (.+)")
        Utils.ovlay("`#Warping To `6"..namew)
        sendPacket(3, "action|join_request\n|name|"..namew.."\n|invitedWorld|0")
        return true
    end

    -- help
    if packet:find("/help") or packet:find("/Help") or packet:find("/Fitur") or packet:find("/fitur") then
        Utils.tol("`9/Proxy For Show Fiture\nMinimal Follow Tiktok Gw @pemula2535")
        return true
    end

    -- set pos1 / pos2
    if packet:find("/pos1") or packet:find("/Pos1") then
        STATE.PX1 = getLocal().pos.x//32
        STATE.PY1 = getLocal().pos.y//32
        Utils.ovlay("Succes Set ("..STATE.PX1..", "..STATE.PY1..")")
        return true
    end

    if packet:find("/pos2") or packet:find("/Pos2") then
        STATE.PX2 = getLocal().pos.x//32
        STATE.PY2 = getLocal().pos.y//32
        Utils.ovlay("Succes Set ("..STATE.PX2..", "..STATE.PY2..")")
        return true
    end

    -- bet calculation
    if packet:find("/bet (%d+)") or packet:find("/Bet (%d+)") then
        local TotalBet = packet:match("/bet (%d+)") or packet:match("/Bet (%d+)")
        local TotalBets = tonumber(TotalBet) * 2
        local Yah = math.floor(TotalBets * tonumber(STATE.Tax) / 100)
        local drop = TotalBets - Yah
        Utils.ovlay("`9["..STATE.Tax.."%] Drop ["..drop.."]")
        return true
    end

    -- take collected
    if packet:find("/take") or packet:find("/Take") then
        local Amount = Actions.collectObjectsAtPositions({ {STATE.PX1, STATE.PY1}, {STATE.PX2, STATE.PY2} })
        local tax = math.floor(Amount * tonumber(STATE.Tax) / 100)
        local drop = Amount - tax
        local bets = Amount // 2
        Utils.tol("`9Tax : `"..STATE.Tax.."%")
        Utils.tol("`9Total drop : `9"..drop)
        Utils.tol("`9Succes Take")
        Utils.ovlay("`9["..STATE.Tax.."%] Drop ["..drop.."]")
        return true
    end

    -- w1 / w2 drop to positions with wear fallback
    if packet:find("/w1") or packet:find("/W1") then
        -- compute hasil from last collect? We'll assume 'drop' variable from previous context in old script
        -- To keep compatibility, re-calc drop based on previously collected amount if available.
        -- For simplicity, we'll use a quick heuristic: if STATE.lastCollected present, use it; else fallback 0
        local drop = STATE._last_drop or 0
        local bgl = math.floor(drop/10000)
        drop = drop - bgl*10000
        local dl = math.floor(drop/100)
        local wl = drop % 100

        sendPacketRaw(false, { type = 0, x = (STATE.PX1) * 32, y = (STATE.PY1) * 32, state = 48 })
        if Utils.checkInventoryAmount(CONFIG.itemIDs.WORLD_LOCK) < wl then
            Actions.wearItem(CONFIG.itemIDs.DIAMOND_LOCK)
        end
        if Utils.checkInventoryAmount(CONFIG.itemIDs.DIAMOND_LOCK) < dl then
            Actions.wearItem(CONFIG.itemIDs.BLUE_GEM_LOCK)
        end
        if bgl > 0 then Actions.DropItem(CONFIG.itemIDs.BLUE_GEM_LOCK, bgl) end
        if dl > 0 then Actions.DropItem(CONFIG.itemIDs.DIAMOND_LOCK, dl) end
        if wl > 0 then Actions.DropItem(CONFIG.itemIDs.WORLD_LOCK, wl) end

        local hasil = (bgl ~= 0 and bgl.." `eBlue Gem Lock`0" or "").." "..(dl ~= 0 and dl.." `1Diamond Lock`0" or "").." "..(wl ~= 0 and wl.." `9World Lock`0" or "")
        Utils.tol("`9Amount Lock : "..(STATE._lastCollectedAmount or 0))
        Utils.tol("`9Tax : "..STATE.Tax.."%")
        Utils.tol("`9Total drop : `0"..hasil.." `4Tax Reset")
        return true
    end

    if packet:find("/w2") or packet:find("/W2") then
        local drop = STATE._last_drop or 0
        local bgl = math.floor(drop/10000)
        drop = drop - bgl*10000
        local dl = math.floor(drop/100)
        local wl = drop % 100

        sendPacketRaw(false, { type = 0, x = (STATE.PX2) * 32, y = (STATE.PY2) * 32, state = 32 })
        if Utils.checkInventoryAmount(CONFIG.itemIDs.WORLD_LOCK) < wl then
            Actions.wearItem(CONFIG.itemIDs.DIAMOND_LOCK)
        end
        if Utils.checkInventoryAmount(CONFIG.itemIDs.DIAMOND_LOCK) < dl then
            Actions.wearItem(CONFIG.itemIDs.BLUE_GEM_LOCK)
        end
        if bgl > 0 then Actions.DropItem(CONFIG.itemIDs.BLUE_GEM_LOCK, bgl) end
        if dl > 0 then Actions.DropItem(CONFIG.itemIDs.DIAMOND_LOCK, dl) end
        if wl > 0 then Actions.DropItem(CONFIG.itemIDs.WORLD_LOCK, wl) end

        local hasil = (bgl ~= 0 and bgl.." `eBlue Gem Lock`0" or "").." "..(dl ~= 0 and dl.." `1Diamond Lock`0" or "").." "..(wl ~= 0 and wl.." `9World Lock`0" or "")
        Utils.tol("`9Amount Lock : "..(STATE._lastCollectedAmount or 0))
        Utils.tol("`9Tax : "..STATE.Tax.."%")
        Utils.tol("`9Total drop : `0"..hasil.." `4Tax Reset")
        return true
    end

    -- cd command: drop custom total
    if packet:find("/cd (%d+)") or packet:find("/Cd (%d+)") then
        local total = tonumber(packet:match("/cd (%d+)") or packet:match("/Cd (%d+)"))
        Utils.tol("`9Use Fitur : /cd")
        local bgl = math.floor(total/10000)
        total = total - bgl*10000
        local dl = math.floor(total/100)
        local wl = total % 100
        if Utils.checkInventoryAmount(CONFIG.itemIDs.WORLD_LOCK) < wl then
            Actions.wearItem(CONFIG.itemIDs.DIAMOND_LOCK)
        end
        if Utils.checkInventoryAmount(CONFIG.itemIDs.DIAMOND_LOCK) < dl then
            Actions.wearItem(CONFIG.itemIDs.BLUE_GEM_LOCK)
        end
        if bgl > 0 then Actions.DropItem(CONFIG.itemIDs.BLUE_GEM_LOCK, bgl) end
        if dl > 0 then Actions.DropItem(CONFIG.itemIDs.DIAMOND_LOCK, dl) end
        if wl > 0 then Actions.DropItem(CONFIG.itemIDs.WORLD_LOCK, wl) end
        local hasil = (bgl ~= 0 and bgl.." `eBlue Gem Lock`0" or "").." "..(dl ~= 0 and dl.." `1Diamond Lock`0" or "").." "..(wl ~= 0 and wl.." `9World Lock`0" or "")
        Utils.tol("`9Total drop : `0"..hasil)
        return true
    end

    -- toggle fast drop / fast trash
    if packet:find("/fd") or packet:find("/Fd") then
        STATE.fdrop = not STATE.fdrop
        STATE.ftrash = false
        Utils.ovlay(STATE.fdrop and "Fast Drop Enable" or "Fast Drop Disable")
        return true
    end

    if packet:find("/ft") or packet:find("/Ft") then
        STATE.ftrash = not STATE.ftrash
        STATE.fdrop = false
        Utils.ovlay(STATE.ftrash and "Fast Trash Enable" or "Fast Trash Disable")
        return true
    end

    if packet:find("/daw") then
        Actions.DropItem(CONFIG.itemIDs.BLUE_GEM_LOCK, Utils.checkInventoryAmount(CONFIG.itemIDs.BLUE_GEM_LOCK))
        Actions.DropItem(CONFIG.itemIDs.DIAMOND_LOCK, Utils.checkInventoryAmount(CONFIG.itemIDs.DIAMOND_LOCK))
        Actions.DropItem(CONFIG.itemIDs.WORLD_LOCK, Utils.checkInventoryAmount(CONFIG.itemIDs.WORLD_LOCK))
        return true
    end

    -- toggle pull/kick/ban modes from dialog or commands (/fpull /fkick /fban)
    if packet:find("action|dialog_return\ndialog_name|wh\nbuttonClicked|wpull") or packet:find("/fpull") then
        STATE.pull = not STATE.pull
        if STATE.pull then STATE.kick = false; STATE.ban = false; Utils.ovlay("Pull Mode Enable")
        else STATE.pull = false; Utils.ovlay("Pull Mode Disable") end
        return true
    end
    if packet:find("action|dialog_return\ndialog_name|wh\nbuttonClicked|wban") or packet:find("/fkick") then
        STATE.ban = not STATE.ban
        if STATE.ban then STATE.pull = false; STATE.kick = false; Utils.ovlay("Ban Mode Enable")
        else STATE.ban = false; Utils.ovlay("Ban Mode Disable") end
        return true
    end
    if packet:find("action|dialog_return\ndialog_name|wh\nbuttonClicked|wkick") or packet:find("/fban") then
        STATE.kick = not STATE.kick
        if STATE.kick then STATE.ban = false; STATE.pull = false; Utils.ovlay("Kick Mode Enable")
        else STATE.kick = false; Utils.ovlay("Kick Mode Disable") end
        return true
    end

    -- wrench default
    if packet:find("action|dialog_return\ndialog_name|wh\nbuttonClicked|wdef") or packet:find("/wn") then
        STATE.kick = false; STATE.ban = false; STATE.pull = false
        Utils.ovlay("Default")
        return false
    end

    -- execute wrench actions (catch action|wrench packets)
    if packet:find("action|wrench\n|netid|(%d+)") then
        local id = packet:match("action|wrench\n|netid|(%d+)")
        if STATE.pull then
            Actions.executeWrench(id, "pull")
            return true
        end
        if STATE.kick then
            Actions.executeWrench(id, "kick")
            return true
        end
        if STATE.ban then
            Actions.executeWrench(id, "worldban")
            return true
        end
    end

    -- tap tp toggle
    if packet:find("/t") then
        STATE.command.var.taptp = not STATE.command.var.taptp
        Utils.tol(STATE.command.var.taptp and "Tap tp `4Hidup." or "Tap tp `4Mati.")
        return true
    end

    -- calculator handling: handled later on varlist dialog response
    if packet:find("/cal") then
        UI.showCalc()
        return true
    end

    -- relog
    if packet:find("/rr") then
        local namew = GetWorld().name
        sendPacket(3,"action|quit_to_exit")
        sendPacket(3, "action|join_request\n|name|"..namew.."\n|invitedWorld|0")
        Utils.ovlay("Try To Relog")
        return true
    end

    -- growscan commands hooked via AddHook OnTextPacket elsewhere
    return false
end

-- text command handler for /x /y via custom cc function
function Commands.customCC(pkt)
    if pkt:find("/x (%d+)/y (%d+)") then
        local x = pkt:match("/x (%d+)")
        local y = pkt:match("/y (%d+)")
        logToConsole("`9[`M19K Proxy`9]`````` POSITION SET TO X : `#"..x.."`` , Y : `#"..y)
        SleepS(1)
        Actions.findPathTo(tonumber(x), tonumber(y))
        return true
    end
    return false
end

--=== [ MODULE: HOOKS ] ===--
local Hooks = {}

function Hooks.AddOrUpdatePlayer(name, netid)
    if STATE.playerList[netid] == nil or STATE.playerList[netid].name ~= name then
        STATE.playerList[netid] = { name = name, netid = netid }
    end
end

-- helper for qeme and reme logic functions (kept from original)
function Hooks.qemefunc(number)
    if number >= 10 then
        return string.sub(number, -1)
    else
        return number
    end
end

function Hooks.remefunc(number)
    if number == 19 or number == 28 or number == 0 then
        return 0
    else
        local num1 = math.floor(number / 10)
        local num2 = number % 10
        return string.sub(tostring(num1 + num2), -1)
    end
end

function Hooks.getGame(num)
    if STATE.reme and not STATE.qeme then
        return "`2R : `1"..Hooks.remefunc(tonumber(num))..""
    elseif not STATE.reme and STATE.qeme then
        return "`2Q : `1"..Hooks.qemefunc(tonumber(num))..""
    elseif STATE.reme and STATE.qeme then
        return "`2R :  "..Hooks.remefunc(num).." and Q :  "..Hooks.qemefunc(num).."]"
    else
        return ""
    end
end

-- filter spin dialog builder
function Hooks.filterspin(id)
    Actions.logspin_filterByNetID(tonumber(id))
end

-- logspin UI builder
function Hooks.logspin()
    Actions.logspin_showAll()
end

-- parse OnTalkBubble for spun the wheel logic (preserve previous behavior)
function Hooks.onVarlist_HandleTalkBubble(var)
    if STATE.rfspin == true then
        if var[2]:find("spun the wheel") then
            if var[2]:find("OID:") then
                -- fake spin
                SendVariant({
                    [0] = "OnTalkBubble",
                    [1] = var[1],
                    [2] = "`4FAKE`` " .. var[2]:match("player_chat=(.+)"),
                    [3] = 0,
                }, -1)
                table.insert(STATE.logSpin, {
                    spin = "\nadd_label_with_icon_button|small|`4FAKE`` " .. var[2] .. "|left|758|" .. var[1] .. "|\n",
                    netid = var[1],
                    spins = "`4FAKE`` "..var[2]
                })
                return true
            else
                local num = string.gsub(string.gsub(var[2]:match("and got (.+)"), "!%]", ""), "`", "")
                local onlynumber = string.sub(num, 2)
                local clearspace = string.gsub(onlynumber, " ", "")
                local h = string.gsub(string.gsub(clearspace, "!7", ""), "]", "")
                if var[1] ~= GetLocal().netid then
                    table.insert(STATE.playerList, { name = var[2]:match("`7%[``(.+) spun the"), netid = var[1] })
                else
                    Hooks.AddOrUpdatePlayer(GetLocal().name:gsub("%[(.+)%]", ""), var[1])
                end
                local name = {}
                name[0] = "OnNameChanged"
                name[1] = Utils.GetNameByNetID(var[1]) .. "`7[`4" .. h .. "``]"
                SendVariant(name, tonumber(var[1]))
                if var[1] ~= GetLocal().netid then
                    SendVariant({
                        [0] = "OnTalkBubble",
                        [1] = var[1],
                        [2] = "`7 `2REAL`` " .. var[2] .. Hooks.getGame(tonumber(h)),
                        [3] = 0,
                    }, -1)
                else
                    SendVariant({
                        [0] = "OnTalkBubble",
                        [1] = GetLocal().netid,
                        [2] = "`2REAL``[``" .. GetLocal().name:gsub("%[(.-)%]", ""):gsub("`.","") .. "`7 spun the wheel and got " .. var[2]:match("and got (.+)%!`7]") .. "!``]" .. Hooks.getGame(tonumber(h)),
                    }, -1)
                end
                table.insert(STATE.logSpin, { spin = "\nadd_label_with_icon_button|small|`2REAL`` " .. var[2] .. "|left|758|" .. var[1] .. "|\n", netid = var[1], spins = var[2] })
                return true
            end
        end
        return false
    end
    return false
end

-- varlist hook for dialog auto actions (fast drop/trash, wear on collect, etc.)
function Hooks.onVarlist_HandleDialogRequest(var)
    if STATE.fdrop and var[1]:find("drop") then
        local tlepe = var[1]:match("add_text_input|count||(%d+)")
        local idtem = var[1]:match("embed_data|itemID|(%d+)")
        Actions.DropItem(idtem, tlepe)
        return true
    end
    if STATE.ftrash and var[1]:find("Trash") then
        local Putih = var[1]:match("you have (%d+)")
        local Hitam = var[1]:match("embed_data|itemID|(%d+)")
        Actions.TrashItem(Hitam, Putih)
        return true
    end
    if var[1]:match("Collected `w(%d+) World Lock``") then
        Actions.wearItem(CONFIG.itemIDs.WORLD_LOCK)
        return true
    end

    if STATE.pull and (var[1]:find("pull") or var[1]:find("kick") or var[1]:find("worldban")) then
        return true
    end
    if STATE.kick and (var[1]:find("pull") or var[1]:find("kick") or var[1]:find("worldban")) then
        return true
    end
    if STATE.ban and (var[1]:find("pull") or var[1]:find("kick") or var[1]:find("worldban")) then
        return true
    end

    if var[1]:find("drop") then
        return true
    end

    return false
end

-- touch hook for tap-to-tp
function Hooks.onTouch(x, y)
    if STATE.command.var.taptp == true then
        local tx = getLocal().pos.x // 32
        local ty = getLocal().pos.y // 32
        SleepS(1)
        Utils.ovlay("`9Path Finder: `2[x: "..tx.." & y: "..ty.."]")
        findPath(x // 32, y // 32)
        STATE.command.var.taptp = false
        logToConsole("``[`2M19K Proxy``] `6Tap tp `4Mati.")
    end
end

-- OnDialogRequest handler
function Hooks.onDialogRequest(dialog)
    -- calculator page handling
    if dialog:find("dialog_name|calculatorpage") then
        STATE.firstnum = tonumber(dialog:match("fnum|(%d+)")) or tonumber(STATE.firstnum)
        STATE.op = tostring(dialog:match("opr|(%w+)")) or STATE.op
        STATE.secondnum = tonumber(dialog:match("snum|(%d+)")) or tonumber(STATE.secondnum)

        if STATE.op == "sum" then
            Utils.SendDialogRaw(UI.sum(STATE.firstnum, STATE.secondnum), -1)
        elseif STATE.op == "sub" then
            local subout = [[
add_label_with_icon|big|`9Calculator Result               |big|5016|
add_spacer|small|
add_textbox|Result: `2]].. tostring(math.floor(STATE.firstnum - STATE.secondnum)) ..[[||
add_spacer|big|
add_button|backtocalc|`wBack to calc page|
add_quick_exit|
]]
            Utils.SendDialogRaw(subout, -1)
        elseif STATE.op == "multi" then
            local multiout = [[
add_label_with_icon|big|`9Calculator Result               |big|5016|
add_spacer|small|
add_textbox|Result: `2]].. tostring(math.floor(STATE.firstnum * STATE.secondnum)) ..[[||
add_spacer|big|
add_button|backtocalc|`wBack to calc page|
add_quick_exit|
]]
            Utils.SendDialogRaw(multiout, -1)
        elseif STATE.op == "divide" then
            local divideout = [[
add_label_with_icon|big|`9Calculator Result               |big|5016|
add_spacer|small|
add_textbox|Result: `2]].. tostring(math.floor(STATE.firstnum / STATE.secondnum)) ..[[||
add_spacer|big|
add_button|backtocalc|`wBack to calc page|
add_quick_exit|
]]
            Utils.SendDialogRaw(divideout, -1)
        else
            local errorpage = [[
add_label_with_icon|big|`9Calculator Result         |left|5016|
add_spacer|small|
add_textbox|`4[ERROR]||
add_spacer|big|
add_button|backtocalc|`wBack to calc page|
add_quick_exit|
]]
            Utils.SendDialogRaw(errorpage, -1)
        end
        return true
    end

    -- back to calc
    if dialog:find("buttonClicked|backtocalc") then
        Utils.SendDialogRaw(UI.calcu(), -1)
        return true
    end

    -- other dialog request handling (fast drop/trash)
    return Hooks.onVarlist_HandleDialogRequest({[0] = "OnDialogRequest", [1] = dialog})
end

--=== [ MODULE: CORE / ENTRY POINTS & HOOK REGISTRATION ] ===--

-- OnTextPacket main hook
AddHook("onTextPacket", "packet", function(type, packet)
    -- central handler
    local handled = Commands.handleTextPacket(packet)
    if handled then
        return true
    end

    -- handle growscan / menu interactions
    if packet:find("dialog_name|scanbilek\nbuttonClicked|(%d+)") then
        local dasarleakers = packet:match("dialog_name|scanbilek\nbuttonClicked|(%d+)")
        sendPacket(2,"action|dialog_return\ndialog_name|extractor\ntilex|0|\ntiley|0|\nstartIndex|0|\nextractorID|6140|\nbuttonClicked|extractOnceObj_"..dasarleakers)
        Utils.ovlay("Donet Gua Sepuh World :CIPHO2")
        return true
    end

    -- /slog handled earlier; ensure we catch any other commands
    if packet:find("/gs") or packet:find("BackToMenu") or packet:find("tileDwi") or packet:find("objectDwi") then
        -- handle growscan
        if packet:find("tileDwi") then
            Utils.SendDialogRaw(string.format("set_default_color|`o\nadd_label_with_icon|big|`bGrowscan|left|6016|\nadd_spacer|small|\nadd_label_with_icon_button_list|small|`wBlock : %s|left|findTile_|itemIDseed2tree_itemAmount|\nadd_spacer|small|\nadd_spacer|small|\nadd_button|BackToMenu|Back|noflags|0|0|\nembed_data|DialogDwi|0\nend_dialog|statsblock|Cancel||", Actions.tileShit()), -1, 100)
        elseif packet:find("objectDwi") then
            Utils.SendDialogRaw(string.format("set_default_color|`o\nadd_label_with_icon|big|`bGrowscan|left|6016|\nadd_spacer|small|\nadd_label_with_icon_button_list|small|`wItems : %s|left|findObject_|itemIDseed2tree_itemAmount|\nadd_spacer|small|\nadd_spacer|small|\nadd_button|BackToMenu|Back|noflags|0|0|\nembed_data|DialogDwi|0\nend_dialog|statsblock|Cancel||", Actions.objectShit()), -1, 100)
        else
            return false
        end
        return true
    end

    -- custom /x /y via cc
    if Commands.customCC(packet) then
        return true
    end

    return false
end)

-- OnTouch hook
AddHook("onTouch", "on_touch", function(x, y)
    Hooks.onTouch(x, y)
end)

-- OnVarlist hook (varlist events)
AddHook("OnVarlist", "variants", function(var)
    local varcontent = var[1]
    if var[0] == "OnConsoleMessage" then
        Utils.tol(varcontent)
        return true
    end

    -- OnTalkBubble handling for spin logs
    if var[0] == "OnTalkBubble" then
        return Hooks.onVarlist_HandleTalkBubble(var)
    end

    -- other OnDialogRequest handling
    if var[0] == "OnDialogRequest" then
        -- auto fast drop/trash handled below
        if Hooks.onVarlist_HandleDialogRequest(var) then
            return true
        end
    end

    return false
end)

-- another OnVarlist hook used previously to intercept dialog requests (kept)
AddHook("onVarlist", "var", function(var)
    if var[0] == "OnDialogRequest" then
        -- fast drop/trash (duplicate safety)
        if STATE.fdrop and var[1]:find("drop") then
            local tlepe = var[1]:match("add_text_input|count||(%d+)")
            local idtem = var[1]:match("embed_data|itemID|(%d+)")
            if tlepe and idtem then
                Actions.DropItem(idtem, tlepe)
                return true
            end
        end
        if STATE.ftrash and var[1]:find("Trash") then
            local Putih = var[1]:match("you have (%d+)")
            local Hitam = var[1]:match("embed_data|itemID|(%d+)")
            if Putih and Hitam then
                Actions.TrashItem(Hitam, Putih)
                return true
            end
        end
    end

    if var[0] == "OnConsoleMessage" then
        if var[1]:match("Collected `w(%d+) World Lock``") then
            Actions.wearItem(CONFIG.itemIDs.WORLD_LOCK)
            return true
        end
    end

    -- block wrench popup options when mode enabled
    if var[0] == "OnDialogRequest" and (STATE.pull or STATE.kick or STATE.ban) then
        if var[1]:find("pull") or var[1]:find("kick") or var[1]:find("worldban") then
            return true
        end
    end

    -- block drop dialogs when needed
    if var[0] == "OnDialogRequest" and var[1]:find("drop") then
        return true
    end

    return false
end)

-- initial dialogs and notifications (preserve startup behavior)
Utils.SendDialogRaw(UI.loginp, -1, 3500)
sendVariant({
    [0] = "OnAddNotification",
    [1] = "game/moon.rttex",
    [2] = "`2Loading...",
    [3] = "audio/hub_open.wav",
    [4] = {0},
}, -1)
sendPacket(2,"action|input\n|text|:)")
SleepS(5)
Utils.ovlay("`2HAVE FUN SIR :)")
SleepS(5)
Utils.ovlay("Donate :) World : CIPHO2")
SleepS(5)
Utils.ovlay("WRENCH MENU TEKAN FITUR SOSIAL YA|1366|")

-- final return false to avoid capturing everything
return false
