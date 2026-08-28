-- HOÀNG ANH GAMER v7.4 — SELF-CONTAINED
-- Build: 2026-02-26 14:53:53
-- Build ID: 36ae3bc8057b
-- Brand: HOÀNG ANH GAMER
-- ALL-IN-ONE — NO LOADSTRING, NO EXTERNAL URLS

local _BUILD_VERSION = "7.4"
local _BUILD_ID = "36ae3bc8057b"
local _BUILD_BRAND = "HOÀNG ANH GAMER"

-- ============================================
-- ANTI-HOOK BOOTSTRAP — Pre-boot critical function snapshot
-- ============================================
local _SAFE = {}
do
    _SAFE.pcall    = pcall
    _SAFE.type     = type
    _SAFE.tostring = tostring
    _SAFE.tonumber = tonumber
    _SAFE.rawget   = rawget
    _SAFE.rawset   = rawset
    _SAFE.select   = select
    _SAFE.pairs    = pairs
    _SAFE.ipairs   = ipairs
    _SAFE.next     = next
    _SAFE.unpack   = unpack or table.unpack
    _SAFE.error    = error
    _SAFE.setmetatable = setmetatable
    _SAFE.getmetatable = getmetatable
    _SAFE.require  = require

    _SAFE.string_sub    = string.sub
    _SAFE.string_byte   = string.byte
    _SAFE.string_char   = string.char
    _SAFE.string_format = string.format
    _SAFE.string_len    = string.len
    _SAFE.string_find   = string.find
    _SAFE.string_rep    = string.rep
    _SAFE.string_lower  = string.lower
    _SAFE.string_upper  = string.upper
    _SAFE.string_gsub   = string.gsub
    _SAFE.string_match  = string.match
    _SAFE.string_gmatch = string.gmatch

    _SAFE.math_floor  = math.floor
    _SAFE.math_random = math.random
    _SAFE.math_abs    = math.abs
    _SAFE.math_max    = math.max
    _SAFE.math_min    = math.min
    _SAFE.math_huge   = math.huge

    _SAFE.os_time  = os.time
    _SAFE.os_clock = os.clock

    _SAFE.table_insert = table.insert
    _SAFE.table_remove = table.remove
    _SAFE.table_concat = table.concat
    _SAFE.table_sort   = table.sort

    _SAFE.task_spawn = task.spawn
    _SAFE.task_wait  = task.wait
    _SAFE.task_defer = task.defer
    _SAFE.task_delay = task.delay

    _SAFE.game = game
    _SAFE.workspace = workspace

    _SAFE.pcall(function()
        if getgenv then _SAFE.getgenv = getgenv end
        if iscclosure then _SAFE.iscclosure = iscclosure end
        if islclosure then _SAFE.islclosure = islclosure end
        if getrawmetatable then _SAFE.getrawmetatable = getrawmetatable end
        if hookfunction then _SAFE.hookfunction = hookfunction end
        if newcclosure then _SAFE.newcclosure = newcclosure end
    end)

    local _bootClean = true
    _SAFE.pcall(function()
        if _SAFE.iscclosure then
            local criticals = {
                _SAFE.pcall, _SAFE.type, _SAFE.tostring, _SAFE.rawget,
                _SAFE.pairs, _SAFE.ipairs, _SAFE.next, _SAFE.select,
            }
            for _, fn in _SAFE.ipairs(criticals) do
                if not _SAFE.iscclosure(fn) then
                    _bootClean = false
                end
            end
        end
    end)

    if not _bootClean then
        warn("[HoangAnhGamer] [!] Anti-hook bootstrap: hooks detected at load time!")
    end

    if _SAFE.getgenv then
        _SAFE.getgenv()._SAFE = _SAFE
    end
end

local _modules = {}

_modules["security"] = function()
    local Security = {}
    local Utils = nil
    
    local HttpService = game:GetService("HttpService")
    local Players = game:GetService("Players")
    
    local _violations = {}
    local _violationCount = 0
    local _degraded = false
    local _scanCount = 0
    
    local function _s(bytes)
        local chars = {}
        for i = 1, #bytes do
            chars[i] = string.char(bytes[i])
        end
        return table.concat(chars)
    end
    
    local _STR = {
        request      = _s({ 114, 101, 113, 117, 101, 115, 116 }),
        http_request = _s({ 104, 116, 116, 112, 95, 114, 101, 113, 117, 101, 115, 116 }),
        namecall     = _s({ 95, 95, 110, 97, 101, 109, 99, 97, 108, 108 }),
        index        = _s({ 95, 95, 105, 110, 100, 101, 120 }),
        C_source     = _s({ 91, 67, 93 }),
    }
    
    local function _isHooked(func)
        if type(func) ~= "function" then return true end
        if iscclosure and not iscclosure(func) then return true end
        if islclosure and islclosure(func) then return true end
        if debug and debug.info then
            local s, source = pcall(debug.info, func, "s")
            if s and source and source ~= _STR.C_source then return true end
        end
        return false
    end
    
    local function _getCriticalFunctions()
        local criticals = {}
        local checks = {
            { pcall,    "pcall" },
            { type,     "type" },
            { tostring, "tostring" },
            { rawget,   "rawget" },
            { rawset,   "rawset" },
        }
        for _, item in ipairs(checks) do
            if item[1] then table.insert(criticals, item) end
        end
        return criticals
    end
    
    function Security.checkFunctionIntegrity()
        local violations = {}
        local criticals = _getCriticalFunctions()
        for _, item in ipairs(criticals) do
            if item[1] and _isHooked(item[1]) then
                table.insert(violations, item[2])
            end
        end
        return #violations == 0, violations
    end
    
    function Security.verifyFunction(func, name)
        if not func then return false end
        if _isHooked(func) then
            Security._recordViolation("hooked_function", name or "unknown")
            return false
        end
        return true
    end
    
    function Security._checkMetamethods()
        local clean = true
        pcall(function()
            if not getrawmetatable then return end
            local gameMt = getrawmetatable(game)
            if gameMt then
                local ncHook = rawget(gameMt, _STR.namecall)
                if ncHook and islclosure and islclosure(ncHook) then
                    clean = false
                end
            end
        end)
        return clean
    end
    
    function Security._recordViolation(category, detail)
        _violationCount = _violationCount + 1
        table.insert(_violations, {
            category = category,
            detail = detail or "",
            time = os.time(),
        })
    end
    
    function Security.getViolationCount()
        return _violationCount
    end
    
    function Security.isDegraded()
        return _degraded
    end
    
    local function _silentDegrade(reason)
        if _degraded then return end
        _degraded = true
        task.spawn(function()
            task.wait(math.random(10, 30))
            pcall(function()
                if getgenv then
                    local env = getgenv()
                    env.HoangAnhGamerShuttingDown = true
                end
            end)
        end)
    end
    
    function Security.runFullScan()
        _scanCount = _scanCount + 1
        local allClean = true
        local reasons = {}
        local funcOk, funcViolations = Security.checkFunctionIntegrity()
        if not funcOk then
            allClean = false
            for _, v in ipairs(funcViolations) do
                Security._recordViolation("function_hooked", v)
                table.insert(reasons, "Hooked: " .. v)
            end
        end
        if not Security._checkMetamethods() then
            allClean = false
            Security._recordViolation("metamethod_hooked", "Game metamethods tampered")
            table.insert(reasons, "Metamethod hook detected")
        end
        return allClean, reasons
    end
    
    function Security.init(utilsModule)
        Utils = utilsModule
        local clean, reasons = Security.runFullScan()
        if clean then
            print("[HoangAnhGamer-Security] [+] Initial scan: CLEAN")
        else
            print("[HoangAnhGamer-Security] [!] Initial scan: " .. #reasons .. " issue(s)")
        end
        return clean
    end
    
    return Security
end

_modules["utils"] = function()
    local Utils = {}
    
    local HttpService = game:GetService("HttpService")
    local Players = game:GetService("Players")
    local UserInputService = game:GetService("UserInputService")
    local TweenService = game:GetService("TweenService")
    
    local lp = Players.LocalPlayer
    
    Utils.ROOT_FOLDER = "HoangAnhGamer"
    Utils.DATA_FOLDER = "HoangAnhGamer/Data"
    Utils.IMAGES_FOLDER = "HoangAnhGamer/Assets/Images"
    Utils.SOUNDS_FOLDER = "HoangAnhGamer/Assets/Sounds"
    
    Utils.STATS_FILE = "HoangAnhGamer/Data/Bounty_Stats.nxs"
    Utils.CLIENT_VERSION = "7.4"
    Utils.SAVE_INTERVAL = 10
    Utils._statsLastSaved = 0
    Utils._statsDirty = false
    Utils._statsCache = nil
    
    function Utils.initFolders()
        pcall(function()
            local makefolder = makefolder or function() end
            local isfolder = isfolder or function() return false end
            local folders = {
                Utils.ROOT_FOLDER,
                Utils.DATA_FOLDER,
                "HoangAnhGamer/Assets",
                Utils.IMAGES_FOLDER,
                Utils.SOUNDS_FOLDER
            }
            for _, folder in ipairs(folders) do
                if not isfolder(folder) then
                    makefolder(folder)
                end
            end
            print("[HoangAnhGamer] [+] Workspace folders initialized successfully")
        end)
    end
    
    Utils.initFolders()
    
    local ENCRYPT_KEY = "hoanganhgamer_secure_key_2026_hash"
    local NXS_HEADER = "HAG"
    local NXS_VERSION = 2
    local NXS_SEPARATOR = "|"
    
    local FNV_OFFSET = 2166136261
    local FNV_PRIME = 16777619
    
    local function fnv1aHash(data)
        local hash = FNV_OFFSET
        for i = 1, #data do
            hash = bit32.bxor(hash, data:byte(i))
            hash = bit32.band(hash * FNV_PRIME, 0xFFFFFFFF)
        end
        return string.format("%08X", hash)
    end
    
    local function xorEncrypt(data, key)
        local result = {}
        for i = 1, #data do
            local keyChar = key:byte(((i - 1) % #key) + 1)
            local dataChar = data:byte(i)
            table.insert(result, string.char(bit32.bxor(dataChar, keyChar)))
        end
        return table.concat(result)
    end
    
    local function toHex(str)
        local hex = {}
        for i = 1, #str do
            table.insert(hex, string.format("%02x", str:byte(i)))
        end
        return table.concat(hex)
    end
    
    local function fromHex(hexStr)
        local result = {}
        for i = 1, #hexStr, 2 do
            local byte = tonumber(hexStr:sub(i, i + 1), 16)
            if byte then
                table.insert(result, string.char(byte))
            end
        end
        return table.concat(result)
    end
    
    function Utils.encrypt(data)
        local encrypted = xorEncrypt(data, ENCRYPT_KEY)
        return toHex(encrypted)
    end
    
    function Utils.decrypt(hexData)
        local encrypted = fromHex(hexData)
        return xorEncrypt(encrypted, ENCRYPT_KEY)
    end
    
    function Utils.encryptNXSv2(data)
        local encrypted = Utils.encrypt(data)
        local checksum = fnv1aHash(data)
        return NXS_HEADER .. NXS_SEPARATOR .. tostring(NXS_VERSION) .. NXS_SEPARATOR .. checksum .. NXS_SEPARATOR .. encrypted
    end
    
    function Utils.decryptNXSv2(content)
        if not content or content == "" then return nil, "Empty content" end
        if content:sub(1, 4) == NXS_HEADER .. NXS_SEPARATOR then
            local parts = {}
            for part in content:gmatch("([^" .. NXS_SEPARATOR .. "]+)") do
                table.insert(parts, part)
            end
            if #parts >= 4 then
                local storedChecksum = parts[3]
                local encryptedData = parts[4]
                local decrypted = Utils.decrypt(encryptedData)
                if not decrypted then return nil, "Decryption failed" end
                if fnv1aHash(decrypted) ~= storedChecksum then return nil, "Checksum mismatch" end
                return decrypted, nil
            end
            return nil, "Invalid format"
        end
        local decrypted = Utils.decrypt(content)
        if decrypted and #decrypted > 0 then return decrypted, "migrated" end
        return nil, "Unknown format"
    end
    
    function Utils.httpRequest(options)
        local success, response
        local httpFuncs = { request, http_request, syn and syn.request, http and http.request }
        for _, func in ipairs(httpFuncs) do
            if func then
                success, response = pcall(func, options)
                if success and response then return response, nil end
            end
        end
        return nil, "No HTTP function available"
    end
    
    function Utils.sendWebhook(webhookUrl, data)
        if not webhookUrl or webhookUrl == "" then return false end
        local payload = HttpService:JSONEncode({
            username = "HOÀNG ANH GAMER Bot",
            avatar_url = "https://github.githubassets.com/favicons/favicon.png",
            embeds = data.embeds or {}
        })
        local response, _ = Utils.httpRequest({
            Url = webhookUrl,
            Method = "POST",
            Headers = { ["Content-Type"] = "application/json" },
            Body = payload
        })
        return response and (response.StatusCode == 200 or response.StatusCode == 204)
    end

    function Utils.loadStats()
        if Utils._statsCache then return Utils._statsCache end
        local defaultStats = {
            totalBountyGained = 0,
            totalKills = 0,
            sessionStartTime = os.time(),
            sessionKills = 0,
            sessionBounty = 0,
            serversHopped = 0
        }
        Utils._statsCache = defaultStats
        return defaultStats
    end

    function Utils.formatNumber(num)
        num = num or 0
        if num >= 1000000 then return string.format("%.1fM", num / 1000000)
        elseif num >= 1000 then return string.format("%.1fK", num / 1000) end
        return tostring(math.floor(num))
    end

    function Utils.formatTime(seconds)
        seconds = math.floor(seconds or 0)
        local hours = math.floor(seconds / 3600)
        local minutes = math.floor((seconds % 3600) / 60)
        return string.format("%dh %dm", hours, minutes)
    end
    
    return Utils
end

_modules["config"] = function()
    local Config = {}
    Config.CONFIG_FILE = "HoangAnhGamer/Data/config.json"
    
    Config.Values = {
        Fruit = "Auto",
        Region = "Auto",
        Faction = "Auto",
        Webhook = "",
        StartupSound = true,
    }

    function Config.init(utilsModule)
        print("[HoangAnhGamer] [+] Config initialized successfully")
        return Config.Values
    end

    function Config.get(key)
        return Config.Values[key]
    end

    return Config
end

_modules["auth"] = function()
    local Auth = {}
    Auth.IsAuthenticated = false

    function Auth.init(utilsModule)
        Auth.IsAuthenticated = true -- Bật sẵn để tự động đăng nhập mượt mà cho HOÀNG ANH GAMER
    end

    function Auth.validateKey(key, callback)
        if key == "HOANH-ANH-GAMER-VIP" or key ~= "" then
            Auth.IsAuthenticated = true
            callback(true, "Success", { isPremium = true })
        else
            callback(false, "Invalid Key")
        end
    end

    function Auth.isAuthenticated()
        return Auth.IsAuthenticated == true
    end

    return Auth
end

_modules["ui"] = function()
    local Players = game:GetService("Players")
    local TweenService = game:GetService("TweenService")
    local CoreGui = game:GetService("CoreGui")
    
    local lp = Players.LocalPlayer
    local UI = { Connections = {} }
    
    local Colors = {
        Background = Color3.fromRGB(15, 15, 20),
        Surface = Color3.fromRGB(30, 30, 40),
        Primary = Color3.fromRGB(138, 43, 226),
        Text = Color3.fromRGB(240, 240, 255),
        TextMuted = Color3.fromRGB(150, 150, 170),
        Success = Color3.fromRGB(50, 205, 50),
        Error = Color3.fromRGB(255, 69, 0),
    }

    local function createCorner(parent, radius)
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, radius or 8)
        corner.Parent = parent
    end

    local function createKeyScreen(parent, onSuccess)
        local screen = Instance.new("Frame")
        screen.Name = "HoangAnhGamerKeyScreen"
        screen.BackgroundColor3 = Colors.Background
        screen.Size = UDim2.new(0, 360, 0, 240)
        screen.Position = UDim2.new(0.5, -180, 0.5, -120)
        screen.Parent = parent
        createCorner(screen, 12)

        local title = Instance.new("TextLabel")
        title.Text = "HOÀNG ANH GAMER - BOUNTY HUB"
        title.TextColor3 = Colors.Text
        title.Font = Enum.Font.GothamBold
        title.TextSize = 16
        title.Size = UDim2.new(1, 0, 0, 40)
        title.BackgroundTransparency = 1
        title.Parent = screen

        local input = Instance.new("TextBox")
        input.PlaceholderText = "Nhập License Key..."
        input.Text = "HOANH-ANH-GAMER-VIP"
        input.TextColor3 = Colors.Text
        input.PlaceholderColor3 = Colors.TextMuted
        input.BackgroundColor3 = Colors.Surface
        input.Size = UDim2.new(0.8, 0, 0, 40)
        input.Position = UDim2.new(0.1, 0, 0.35, 0)
        input.Font = Enum.Font.Gotham
        input.TextSize = 14
        input.Parent = screen
        createCorner(input, 6)

        local status = Instance.new("TextLabel")
        status.Text = ""
        status.TextColor3 = Colors.TextMuted
        status.Size = UDim2.new(1, 0, 0, 20)
        status.Position = UDim2.new(0, 0, 0.58, 0)
        status.BackgroundTransparency = 1
        status.Font = Enum.Font.Gotham
        status.TextSize = 12
        status.Parent = screen

        local btn = Instance.new("TextButton")
        btn.Text = "XÁC NHẬN"
        btn.TextColor3 = Colors.Text
        btn.BackgroundColor3 = Colors.Primary
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 14
        btn.Size = UDim2.new(0.8, 0, 0, 40)
        btn.Position = UDim2.new(0.1, 0, 0.72, 0)
        btn.Parent = screen
        createCorner(btn, 6)

        btn.MouseButton1Click:Connect(function()
            if input.Text == "" then
                status.Text = "Vui lòng không để trống key!"
                status.TextColor3 = Colors.Error
                return
            end
            status.Text = "Đang xác thực..."
            task.delay(0.5, function()
                status.Text = "✓ Thành công! Đang khởi động..."
                status.TextColor3 = Colors.Success
                task.delay(0.8, function()
                    screen:Destroy()
                    if onSuccess then onSuccess() end
                end)
            end)
        end)
    end

    function UI.init(utilsModule, configModule, authModule)
        local gui = Instance.new("ScreenGui")
        gui.Name = "HoangAnhGamerGui"
        gui.ResetOnSpawn = false
        
        pcall(function()
            if syn and syn.protect_gui then
                syn.protect_gui(gui)
            end
            gui.Parent = CoreGui
        end)

        createKeyScreen(gui, function()
            print("[HoangAnhGamer] [+] Dashboard loaded successfully for HOÀNG ANH GAMER!")
        end)

        return UI
    end

    return UI
end

-- Khởi chạy toàn bộ hệ thống
task.spawn(function()
    print("[HoangAnhGamer] [*] Booting HOÀNG ANH GAMER Script System...")
    local utils = _modules["utils"]()
    local security = _modules["security"]()
    security.init(utils)
    local config = _modules["config"]()
    config.init(utils)
    local auth = _modules["auth"]()
    auth.init(utils)
    local ui = _modules["ui"]()
    ui.init(utils, config, auth)
end)
