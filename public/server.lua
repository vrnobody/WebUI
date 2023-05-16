-- args用法: loadfile("./path/to/server.lua")(url, logLevel)
local args = {...}

-- 如果4000端口已在使用，可修改为其他端口
local url = #args > 0 and args[1] or "http://localhost:4000/"
local public = "./lua/webui"

-- confings
local Logger = require('lua.modules.logger')

local version = "0.0.1.3"
local pageSize = 50

local logLevel = #args > 1 and args[2] or Logger.logLevels.Debug

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

local function Response(ok, result, ...)
    local r = {
        ["ok"] = ok,
        ["r"] = result,
        ["ps"] = { ... },
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

function GetLog(uid)
    if string.isempty(uid) then
        return Misc:GetLogAsString()
    end
    local coreServ = utils.GetFirstServerWithUid(uid)
    if coreServ == nil then
        return nil
    end
    local coreLogger = coreServ:GetLogger()
    return coreLogger:GetLogAsString()
end

function GenLuaModuleSnippets(code)
    return Sys:LuaGenModuleSnippets(code)
end

function GetLuaStaticSnippets()
    return Sys:LuaGetStaticSnippets()
end

function ChangeLuaCoreIndex(name, index)
    return Sys:LusServSetIndex(name, index)
end    

function StartLuaCore(name)
    Sys:LuaServStart(name)
end

function StopLuaCore(name)
    Sys:LuaServStop(name)
end

function RemoveLuaCore(name)
    return Sys:LuaServRemove(name)
end

function ChangeLuaCoreInfo(name, settings)
    return Sys:LuaServChangeSettings(name, settings)
end

function GetAllLuaCoreInfos()
    return Sys:LuaServGetAllCoreInfos()
end

function AddLuaScript(name, script)
    return Sys:LuaServAdd(name, script)
end

function GetAllLuaScripts()
    return Sys:LuaServGetAllScripts()
end

function RemoveLuaVm(luavm)
    Sys:LuaVmRemove(luavm)
end

function ClearLuaVmLog(luavm)
    Sys:LuaVmClearLog(luavm)
end

function GetLuaVmLog(luavm)
    return Sys:LuaVmGetLog(luavm)
end

function RunLuaScript(name, script)
    local luavm = Sys:LuaVmCreate()
    if string.isempty(luavm) then
        return ""
    end
    Sys:LuaVmRun(luavm, name, script)
    return luavm
end

function StopLuaVm(luavm)
    Sys:LuaVmStop(luavm)
end

function AbortLuaVm(luavm)
    Sys:LuaVmAbort(luavm)
end

function ScanQrCode(mark)
    mark = string.isempty(mark) and "" or mark
    local link = Misc:ScanQrcode()
    return Misc:ImportLinks(link, mark)
end

function GetServSettings(uid)
    local coreServ = utils.GetFirstServerWithUid(uid)
    if not coreServ then
        return nil
    end
    local coreState = coreServ:GetCoreStates()
    local r = {}
    r["index"] = coreState:GetIndex()
    r["name"] =coreState:GetName()
    r["mark"] = coreState:GetMark()
    r["remark"] = coreState:GetRemark()
    r["tag1"] = coreState:GetTag1()
    r["tag2"] = coreState:GetTag2()
    r["tag3"] = coreState:GetTag3()
    return r
end

function SaveServSettings(uid, s)
    local coreServ = utils.GetFirstServerWithUid(uid)
    if not coreServ then
        return false
    end
    local coreState = coreServ:GetCoreStates()
    
    coreState:SetName(s["name"])
    local coreConfiger = coreServ:GetConfiger()
    coreConfiger:UpdateSummary() -- fix name is empty bug
    
    coreState:SetMark(s["mark"])
    coreState:SetRemark(s["remark"])
    coreState:SetMark(s["mark"])
    coreState:SetTag1(s["tag1"])
    coreState:SetTag2(s["tag2"])
    coreState:SetTag3(s["tag3"])
    
    coreState:SetIndex(tonumber(s["index"]) or 1)
    Server:ResetIndexes()
    
    return true
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
        return "configIsEmpty"
    end
    
    if string.isempty(uid) then
        local ok = Server:Add(config)
        if not ok then
            return "addServerFailed"
        else
            return nil
        end
    end
    
    local coreServ = utils.GetFirstServerWithUid(uid)
    if coreServ == nil then
        return "serverNotFound"
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
        return Response(false, "parseReqError")
    end
    
    local fn = j["fn"]
    local f = _G[fn]
    local p = j["ps"]
    if type(f) ~= "function" then
        local fName = fn .. "()"
        sLog:Debug("function not exists:", fName)
        return Response(false, "funcNotExists", fName)
    end
    if type(p) ~= "table" then
        sLog:Debug("param is not a table")
        return Response(false, "paramIsNotTable")
    end
    
    local fFullName = fn .. "(" .. Concat(p, ", ") .. ")"
    sLog:Debug("Call", fFullName)
    local ok, r = pcall(f, table.unpack(p))
    if ok then
        return Response(true, r)
    end
    return Response(false, "callFuncError", fFullName, r)
end

local function Main()
    local ver = GetServerVersion()
    print("server.lua v" .. ver)
    haServ:Create(url, public, Handler, false)
    print("请打开网址: ", url)
    haServ:Run()
end

Main()