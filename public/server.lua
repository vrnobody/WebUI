--[[
用法1: 
loadfile("./lua/webui/server.lua")("http://localhost:1234/")

用法2: 
loadfile("./lua/webui/server.lua")({
    ["url"] = "http://localhost:1234/",
    ["password"] = "123456",
    ["salt"] = "485c5940-cccd-484c-883c-66321d577992",
    ["pageSize"] = "50",
    ["public"] = "./lua/webui",
})
--]]

local version = "0.0.2.6"

-- for debugging only
local url = "http://localhost:4000/"
local public = "./lua/webui"
local password = "123456"

-- code
local Logger = require('lua.modules.logger')
local httpServ = require('lua.modules.httpServ').new()
local json = require('lua.libs.json')
local utils = require('lua.libs.utils')
local reader = require('lua.modules.reader')
local writer = require('lua.modules.writer')

local args = {...}
local options = {}
local sLog = Logger.new(nil, Logger.logLevels.Debug)

local function ParseOptions()
    local o = {}
    if #args == 1 and type(args[1]) == "table" then
        o = args[1]
    end
    if #args < 1 and not string.isempty(password) then
        o['password'] = password
    end
    o['salt'] = o['salt'] or '485c5940-cccd-484c-883c-66321d577992'
    o['logLevel'] = o['logLevel'] or (#args > 0 and Logger.logLevels.Info or Logger.logLevels.Debug)
    o['pageSize'] = o['pageSize'] or 50
    o['public'] = o['public'] or public
    if string.isempty(o['url']) then
        -- backward compactible
        if #args > 0 and type(args[1]) == "string" then
            o['url'] = args[1]
        else
            o['url'] = url
        end
    end
    if not string.isempty(o['password']) then
        local str = o['salt'] .. o['password']
        o['token'] = Misc:Sha512(str)
        o['password'] = nil
    end
    options = o
end

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

local function GetTags(coreState)
    local r = {}
    r["mark"] = coreState:GetMark()
    r["remark"] = coreState:GetRemark()
    r["tag1"] = coreState:GetTag1()
    r["tag2"] = coreState:GetTag2()
    r["tag3"] = coreState:GetTag3()
    r["status"] = coreState:GetStatus()
    r["isAutoRun"] = coreState:IsAutoRun()
    return r
end

local function GetInboundInfo(coreState)
    local mode = coreState:GetInboundType()
    if mode == 0 then
        return "Config"
    end
    if mode == 3 then
        return "Custom"
    end
    if mode == 1 or mode == 2 then
        local prefix = (mode == 1 and "http" or "socks")
        return prefix .. "://" .. coreState:GetInboundAddr()
    end
    return "Unknow"
end

local function GetterCoreServInfo(coreServ)
    local t = {}
    if coreServ == nil then
        return t
    end
    local coreState = coreServ:GetCoreStates()
    local coreCtrl = coreServ:GetCoreCtrl()
    t["tags"] = GetTags(coreState)
    t["index"] = coreState:GetIndex()
    t["name"] = coreState:GetName()
    t["summary"] = coreState:GetSummary()
    t["uid"] = coreState:GetUid()
    t["on"] = coreCtrl:IsCoreRunning()
    t["inbound"] = GetInboundInfo(coreState)
    local cSharpTicks = coreState:GetLastModifiedUtcTicks()
    t["modified"] = utils.ToLuaTicks(cSharpTicks)
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
        if type(tag) == "string" then
            local t = string.lower(tag)
            if string.find(t, keyword) then
                return true
            end
        end
    end
    return false
end

local function FilterServsByTags(servs, keyword)
    local r = {}
    for coreServ in Each(servs) do
        local coreState = coreServ:GetCoreStates()
        local tags = GetTags(coreState)
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
    local pages = math.ceil(total / options['pageSize'])
    if pages < 1 then
        pages = 1
    end
    return pages
end

function GetSalt()
    return options['salt']
end

function RunLatencyTestByUid(uid)
    return Server:RunSpeedTestByUids({uid})
end

function StopLatencyTest()
    Server:StopSpeedTest()
end

function GetAllLuaVmsInfo()
    return Sys:LuaVmGetAllVmsInfo()
end

function RemoveAllStoppedLuaVms()
    Sys:LuaVmRemoveStopped()
end

function GetScriptFromLuaVm(luavm)
    return Sys:LuaVmGetScript(luavm)
end

function GetShareLink(uid)
    local coreServ = utils.GetFirstServerWithUid(uid)
    if coreServ ~= nil then
        local coreConfiger = coreServ:GetConfiger()
        return coreConfiger:GetShareLink()
    end
    return ''
end

function WrtieFile(filename, content)
    local w = writer.new(filename)
    w:WriteAllText(content)
end

function ReadFile(filename)
    local r = reader.new(filename)
    return r:ReadAllText()
end

function Ls(path, exts)
    return Sys:Ls(path, exts)
end

function UpdateSubscriptions()
    local proxyPort = Web:GetProxyPort()
    return Web:UpdateSubscriptions(proxyPort)
end

function SaveSubscriptions(subs)
    Misc:SetSubscriptionConfig(subs)
end

function GetSubscriptions()
    return Misc:GetSubscriptionConfig()
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

function LuaAnalyzeCode(code)
    return Sys:LuaAnalyzeCode(code)
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

function RestartLuaCore(name)
    Sys:LuaServRestart(name)
end

function StopLuaCore(name)
    Sys:LuaServStop(name)
end

function AbortLuaCore(name)
    Sys:LuaServAbort(name)
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

function RunLuaScript(name, script, isLoadClr)
    local luavm = Sys:LuaVmCreate()
    if string.isempty(luavm) then
        return ""
    end
    isLoadClr = isLoadClr == true
    Sys:LuaVmRun(luavm, name, script, isLoadClr)
    return luavm
end

function StopLuaVm(luavm)
    Sys:LuaVmStop(luavm)
end

function AbortLuaVm(luavm)
    Sys:LuaVmAbort(luavm)
end

function FilterSelections(uids)
    local servs = Server:GetServersByUids(uids)
    local r = {}
    for coreServ in Each(servs) do
        local coreState = coreServ:GetCoreStates()
        local uid = coreState:GetUid()
        table.insert(r, uid)
    end
    return r
end

function GetAllServersUid()
    local servs = Server:GetAllServers()
    local r = {}
    for coreServ in Each(servs) do
        local coreState = coreServ:GetCoreStates()
        local uid = coreState:GetUid()
        table.insert(r, uid)
    end
    return r
end

function GetAllNotTtestedServersUid()
    local servs = Server:GetAllServers()
    local r = {}
    for coreServ in Each(servs) do
        local coreState = coreServ:GetCoreStates()
        local latency = coreState:GetSpeedTestResult()
        if latency < 1 then
            local uid = coreState:GetUid()
            table.insert(r, uid)
        end
    end
    return r
end

function GetAllNotTimeoutedServersUid()
    local servs = Server:GetAllServers()
    local r = {}
    for coreServ in Each(servs) do
        local coreState = coreServ:GetCoreStates()
        local latency = coreState:GetSpeedTestResult()
        if latency > 0 and latency < utils.Timeout then
            local uid = coreState:GetUid()
            table.insert(r, uid)
        end
    end
    return r
end

function GetAllTimeoutedServersUid()
    local servs = Server:GetAllServers()
    local r = {}
    for coreServ in Each(servs) do
        local coreState = coreServ:GetCoreStates()
        if coreState:GetSpeedTestResult() == utils.Timeout then
            local uid = coreState:GetUid()
            table.insert(r, uid)
        end
    end
    return r
end

function SortServersByLatency(uids)
    Server:SortServersBySpeedTest(uids)
end

function SortServersByModifyDate(uids)
    Server:SortServersByLastModifiedDate(uids)
end

function SortServersBySummary(uids)
    Server:SortServersBySummary(uids)
end

function ReverseServersByIndex(uids)
    Server:ReverseServersByIndex(uids)
end

function CopyShareLinkOfServers(uids)
    local servs = Server:GetServersByUids(uids)
    local links = {}
    for coreServ in Each(servs) do
        local coreConfiger = coreServ:GetConfiger()
        local link = coreConfiger:GetShareLink()
        if not string.isempty(link) then
            table.insert(links, link)
        end
    end
    return table.concat(links, '\n') or ''
end

function RunLatencyTestOnServers(uids)
    return Server:RunSpeedTestByUids(uids)
end

function ChangeServersSetting(uids, s)
    local keys = {"inbMode", "inbIp", "inbPort", "isAutoRun", "mark", "remark", "tag1", "tag2", "tag3"}
    local servs = Server:GetServersByUids(uids)
    for coreServ in Each(servs) do
        local coreState = coreServ:GetCoreStates()
        for _, key in pairs(keys) do
            local v = s[key]
            if v ~= nil then
                if key == "inbMode" then
                    coreState:SetInboundType(tonumber(v))
                elseif key == "inbIp" then
                    local port = coreState:GetInboundPort()
                    coreState:SetInboundAddr(v, port)
                elseif key == "inbPort" then
                    local ip = coreState:GetInboundIp()
                    coreState:SetInboundAddr(ip, tonumber(v))
                elseif key == "isAutoRun" then
                    coreState:SetIsAutoRun(v)
                elseif key == "mark" then
                    coreState:SetMark(v)
                elseif key == "remark" then
                    coreState:SetRemark(v)
                elseif  key == "tag1" then
                    coreState:SetTag1(v)
                elseif key == "tag2" then
                    coreState:SetTag2(v)
                elseif  key == "tag3" then
                    coreState:SetTag3(v)
                end
            end
        end
    end 
    return true
end

function GetFirstServSettings(uids)
    local servs = Server:GetServersByUids(uids)
    if servs.Count < 1 then
        return nil
    end
    local coreServ = servs[0]
    local coreState = coreServ:GetCoreStates()
    local uid = coreState:GetUid()
    return GetServSettings(uid)
end

function GetServSettings(uid)
    local coreServ = utils.GetFirstServerWithUid(uid)
    if not coreServ then
        return nil
    end
    local coreState = coreServ:GetCoreStates()
    local r = GetTags(coreState)
    r["index"] = coreState:GetIndex()
    r["name"] =coreState:GetName()
    r["inbMode"] = coreState:GetInboundType()
    r["inbIp"] = coreState:GetInboundIp()
    r["inbPort"] = coreState:GetInboundPort()
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
    
    coreState:SetInboundType(tonumber(s["inbMode"]))
    coreState:SetInboundAddr(s["inbIp"], tonumber(s["inbPort"]))
    
    coreState:SetIsAutoRun(s["isAutoRun"])
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
        ["pages"] = 1,
        ["data"] = {},
        ["isTesting"] = Server:IsRunningSpeedTest(),
        ["count"] = servs.Count,
    }
    
    if servs.Count < 1 then
        return r
    end
    
    local min = 0
    local max = servs.Count - 1
    local first = Clamp((pageNum - 1) * options['pageSize'], min, max)
    local last = Clamp((pageNum) * options['pageSize'] - 1, first, max)
    if string.isempty(searchType) or string.isempty(keyword) then
        -- print("search all")
        r["pages"] = CalcTotalPageNumber(servs.Count)
        r["data"] = SearchAllServer(servs, first, last)
        return r
    end
    
    if searchType == "index" then
        local idx = math.floor((tonumber(keyword) or 0) - 1)
        if idx < 0 or idx >= servs.Count then
            r["count"] = 0
            return r
        end
        r["pages"] = 1
        r["data"] = { GetterCoreServInfo(servs[idx]) }
        r["count"] = 1
        return r
    end
    
    local filtered = FilterServs(servs, searchType, keyword)
    local max = #filtered
    r["pages"] = CalcTotalPageNumber(#filtered)
    r["count"] = max
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

function RestartServ(uid, stopOthers)
    uid = uid or ""
    local coreServ = utils.GetFirstServerWithUid(uid)
    if coreServ ~= nil then
        local coreCtrl = coreServ:GetCoreCtrl()
        if stopOthers == true then
            Server:StopAllServers()
        end
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

function SetUserSettings(props)
    local p = json.encode(props)
    return Misc:SetUserSettings(p)
end

function GetUserSettings(props)
    local p = json.encode(props)
    return Misc:GetUserSettings(p)
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

function DeleteServByUids(uids)
    return Server:DeleteServerByUids(uids)
end

function ImportShareLinks(links, mark)
    local c = Misc:ImportLinks(links, mark)
    Misc:RefreshFormMain()
    return c
end

function IsValidToken()
    return true
end

local function IsAuthorized(j)
    local allowFuncs = {'GetSalt', 'GetAppVersion', 'GetServerVersion'}
    if table.contains(allowFuncs, j['fn']) then
        return true
    end
    local token = options['token']
    if string.isempty(token) or j['token'] == token then
        return true
    end
    return false
end

local function Handler(req)
    local ok, j = pcall(json.decode, req)
    if not ok then
        sLog:Debug("parse request error:", req)
        return Response(false, "parseReqError")
    end
    
    if not IsAuthorized(j) then
        return Response(false, 'unAuthorizedOperation')
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
    return Response(false, "callFuncError", fFullName, tostring(r))
end

local function Main()
    ParseOptions()
    sLog:SetLogLevel(options['logLevel'])
    print("server.lua v" .. GetServerVersion())
    httpServ:Create(options['url'], options['public'], Handler, false)
    print("please visit", options['url'])
    httpServ:Run()
end

Main()