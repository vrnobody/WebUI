-- args用法: loadfile("./path/to/server.lua")(url, logLevel)
local args = {...}

-- 如果4000端口已在使用，可修改为其他端口
local url = #args > 0 and args[1] or "http://localhost:4000/"
local public = "./lua/webui"

-- confings
local Logger = require('lua.modules.logger')

local version = "0.0.1.1"
local pageSize = 50

local logLevel = #args > 0 and Logger.logLevels.Info or Logger.logLevels.Debug

-- code
local haServ = require('lua.modules.httpServ').new()
local json = require('lua.libs.json')
local utils = require('lua.libs.utils')

local sLog = Logger.new(nil, logLevel)

local function Clamp(v, min, max)
    if v < min then
        return min
    end
    if v > max then
        return max
    end
    return v
end

local function Concat(t, sep)
    sep = sep or " "
    local r = {}
    for _, v in pairs(t) do
        local p = tostring(v)
        if p and string.len(p) > 15 then
            p = string.sub(p, 1, 15) .. "..."
        end
        table.insert(r, p)
    end
    return table.concat(r, sep)
end

local function Response(ok, result)
    local r = {
        ["ok"] = ok,
        ["r"] = result,
    }
    return json.encode(r)
end

local function GetterTags(coreState)
    local t = {}
    table.insert(t, coreState:GetStatus())
    table.insert(t, coreState:GetMark())
    table.insert(t, coreState:GetRemark())
    table.insert(t, coreState:GetTag1())
    table.insert(t, coreState:GetTag2())
    table.insert(t, coreState:GetTag3())
    local r = {}
    for _, v in pairs(t) do
        if not string.isempty(v) then
            table.insert(r, v)
        end
    end
    return r
end

local function GetterCoreServInfo(coreServ)
    local t = {}
    if coreServ == nil then
        return t
    end
    local coreState = coreServ:GetCoreStates()
    local coreCtrl = coreServ:GetCoreCtrl()
    t["index"] = coreState:GetIndex()
    t["name"] = coreState:GetName()
    t["summary"] = coreState:GetSummary()
    t["uid"] = coreState:GetUid()
    t["on"] = coreCtrl:IsCoreRunning()
    t["selected"] = false
    t["tags"] = GetterTags(coreState)
    return t
end

local function SearchAllServer(servs, first, last)
    local d = {}
    for i = first, last do
        local coreServ = servs[i]
        local t = GetterCoreServInfo(coreServ)
        table.insert(d, t)
    end
    return d
end

local function FilterServsByName(servs, keyword)
    local r = {}
    for coreServ in Each(servs) do
        local coreState = coreServ:GetCoreStates()
        local name = string.lower(coreState:GetName())
        if string.find(name, keyword) then
            table.insert(r, coreServ)
        end
    end
    return r
end

local function FilterServsBySummary(servs, keyword)
    local r = {}
    for coreServ in Each(servs) do
        local coreState = coreServ:GetCoreStates()
        local summary = string.lower(coreState:GetSummary())
        if string.find(summary, keyword) then
            table.insert(r, coreServ)
        end
    end
    return r
end

local function IsInTags(tags, keyword)
    for _, tag in pairs(tags) do
        local t = string.lower(tag)
        if string.find(t, keyword) then
            return true
        end
    end
    return false
end

local function FilterServsByTags(servs, keyword)
    local r = {}
    for coreServ in Each(servs) do
        local coreState = coreServ:GetCoreStates()
        local tags = GetterTags(coreState)
        if IsInTags(tags, keyword) then
            table.insert(r, coreServ)
        end
    end
    return r
end

local function FilterServs(servs, searchType, keyword)
    keyword = string.lower(keyword)
    if searchType == "title" then
        return FilterServsByName(servs, keyword)
    elseif searchType == "tags" then
        return FilterServsByTags(servs, keyword)
    end
    return FilterServsBySummary(servs, keyword)
end

local function CalcTotalPageNumber(total)
    local pages = math.ceil(total / pageSize)
    if pages < 1 then
        pages = 1
    end
    return pages
end

function ChangeServIndex(uid, idx)
    local coreServ = utils.GetFirstServerWithUid(uid)
    if not coreServ then
        return false
    end
    local coreState = coreServ:GetCoreStates()
    coreState:SetIndex(idx)
    Server:ResetIndexes()
    return true
end

function GetAppVersion()
    return Sys:GetAppVersion()
end

function GetSerializedServers(pageNum, searchType, keyword)
    pageNum = tonumber(pageNum) or 1
    searchType = searchType or ""
    keyword = keyword or ""
    -- sLog:Debug("params:", pageNum, searchType, keyword)
    local servs = Server:GetAllServers()
    local r = {
        ["pages"] = 0,
        ["data"] = {},
    }
    
    if servs.Count < 1 then
        return r
    end
    
    local min = 0
    local max = servs.Count - 1
    local first = Clamp((pageNum - 1) * pageSize, min, max)
    local last = Clamp((pageNum) * pageSize - 1, first, max)
    if string.isempty(searchType) or string.isempty(keyword) then
        -- print("search all")
        r["pages"] = CalcTotalPageNumber(servs.Count)
        r["data"] = SearchAllServer(servs, first, last)
        return r
    end
    
    if searchType == "index" then
        local idx = math.floor((tonumber(keyword) or 0) - 1)
        if idx < 0 or idx >= servs.Count then
            return r
        end
        r["pages"] = 1
        r["data"] = { GetterCoreServInfo(servs[idx]) }
        return r
    end
    
    local filtered = FilterServs(servs, searchType, keyword)
    local max = #filtered
    r["pages"] = CalcTotalPageNumber(#filtered)
    local d = {}
    for i = first + 1, last + 1 do
        if i <= max then
            local coreServ = filtered[i]
            local t = GetterCoreServInfo(coreServ)
            table.insert(d, t)
        end
    end
    r["data"] = d
    return r
end 

function RestartServ(uid)
    uid = uid or ""
    local coreServ = utils.GetFirstServerWithUid(uid)
    if coreServ ~= nil then
        local coreCtrl = coreServ:GetCoreCtrl()
        Server:StopAllServers()
        coreCtrl:RestartCore()
        return true
    end
    return false
end

function StopServ(uid)
    uid = uid or ""
    local coreServ = utils.GetFirstServerWithUid(uid)
    if coreServ ~= nil then
        local coreCtrl = coreServ:GetCoreCtrl()
        coreCtrl:StopCore()
        return true
    end
    return false
end

function GetServerVersion()
    return version
end

function GetSettings()
    return Misc:GetUserSettings()
end

function SaveServerConfig(uid, config)
    uid = uid or ""
    config = config or ""
    
    if string.isempty(config) then
        return "config is empty!"
    end
    
    if string.isempty(uid) then
        local ok = Server:Add(config)
        if not ok then
            return "add server failed!"
        else
            return nil
        end
    end
    
    local coreServ = utils.GetFirstServerWithUid(uid)
    if coreServ == nil then
        return "server not found!"
    end
    
    local coreConfiger = coreServ:GetConfiger()
    coreConfiger:SetConfig(config)
    return nil
end

function GetServerConfig(uid)
    local coreServ = utils.GetFirstServerWithUid(uid)
    if coreServ then
        local coreConfiger = coreServ:GetConfiger()
        local config = coreConfiger:GetConfig()
        return config
    end
    return nil
end

function DeleteServersByUids(uids)
    if type(uids) ~= "table" then
        return false
    end
    Server:DeleteServerByUids(uids)
    return true
end

function ImportShareLinks(ps)
    local links = #ps > 0 and ps[1] or ""
    local mark = #ps > 1 and ps[2] or ""
    local c = Misc:ImportLinks(links, mark)
    Misc:RefreshFormMain()
    return c
end

local function Handler(req)
    local ok, j = pcall(json.decode, req)
    if not ok then
        sLog:Debug("parse request error:", req)
        return Response(false, "parse request error")
    end
    
    local fn = j["fn"]
    local f = _G[fn]
    local p = j["ps"]
    if type(f) ~= "function" then
        local msg = "function not exists. " .. fn .. "()"
        sLog:Debug(msg)
        return Response(false, msg)
    end
    if type(p) ~= "table" then
        local msg = "params is not a table"
        sLog:Debug(msg)
        return Response(false, msg)
    end
    
    sLog:Debug("Call", fn .. "(" .. Concat(p, ", ") .. ")")
    local ok, r = pcall(f, table.unpack(p))
    if ok then
        return Response(true, r)
    end
    return Response(false, "call " .. fn .. " error: " .. r)
end

local function Main()
    local ver = GetServerVersion()
    print("server.lua v", ver)
    haServ:Create(url, public, Handler, false)
    print("请打开网址: ", url)
    haServ:Run()
end

Main()