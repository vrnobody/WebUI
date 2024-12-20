--[[

local Logger = require('3rd/neolua/mods/logger')

local options = {
    ["url"] = "http://localhost:5000/",
    ["password"] = "123abc中文😀",
    ["adminpassword"] = "123456",
    ["salt"] = "485c5940-cccd-484c-883c-66321d577992",
    ["pageSize"] = "50",
    ["public"] = "./3rd/neolua/webui",
    ["logLevel"] = Logger.logLevels.Info,
}

local serv = '3rd/neolua/webui/server.lua'
loadfile(serv)(options)

--]]

local args = {...}

local Logger = require('3rd/neolua/mods/logger')

local version = "1.0.2.1"

-- code
local httpServ = require('3rd/neolua/mods/httpServ').new()
local json = require('3rd/neolua/libs/json')
local utils = require('3rd/neolua/libs/utils')

local options = {}
local sLog = Logger.new(nil, false, Logger.logLevels.Debug)

local lowerAdminFuncList = {}
local forbiddenFuncList = {}
for k, _ in pairs(_G) do
    forbiddenFuncList[k] = true
end

local adminFunctions = {'ls', 'readfile', 'writefile', 'getusersettings', 'setusersettings'}

local function ParseOptions()
    local o = {
        ["url"] = "http://localhost:4000/",
        ["password"] = "",
        ["adminpassword"] = "",
        ["salt"] = "485c5940-cccd-484c-883c-66321d577992",
        ["pageSize"] = "50",
        ["public"] = "./3rd/neolua/webui",
        ['logLevel'] = Logger.logLevels.Info,
    }

    if #args == 1 and type(args[1]) == 'table' then
        local a = args[1]
        foreach kv in o do
            local key = kv.Key
            if a[key] ~= nil and type(a[key]) == type(o[key]) then
                o[key] = a[key]
            end
        end
    end

    local keys = {"", "admin"}
    for idx, key in ipairs(keys) do
        local pk = key .. "password"
        local tk = key .. "token"
        if not string.isempty(o[pk]) then
            local str = o['salt'] .. o[pk]
            o[tk] = std.Misc:Sha512(str)
            o[pk] = nil
        end
    end
    
    options = o
end

local function ToLower(t)
    local r = {}
    for idx, v in ipairs(t) do
        v = v or ""
        table.insert(r, v:lower())
    end
    return r
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

local function GetAllServers()
    local r = {}
    local servs = std.Server:GetAllServers()
    foreach serv in servs do
        table.insert(r, serv)
    end
    return r
end

local function GetFilteredServers(keyword)
    if string.isempty(keyword) then
        return GetAllServers()
    end
    
    local r = {}
    local servs = std.Server:GetFilteredServers(keyword)
    foreach serv in servs do
        table.insert(r, serv)
    end
    return r
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
    t["inbound"] = coreState:GetInboundName()
    local cSharpTicks = coreState:GetLastModifiedUtcTicks()
    t["modified"] = utils.ToLuaTicks(cSharpTicks)
    return t
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
    return std.Server:RunSpeedTestByUids({uid})
end

function StopLatencyTest()
    std.Server:StopSpeedTest()
end

function GetAllLuaVmsInfo()
    return std.Sys:LuaVmGetAllVmsInfo()
end

function RemoveAllStoppedLuaVms()
    std.Sys:LuaVmRemoveStopped()
end

function GetScriptFromLuaVm(luavm)
    return std.Sys:LuaVmGetScript(luavm)
end

function GetShareLink(uid)
    local coreServ = std.Server:GetServerByUid(uid)
    if coreServ ~= nil then
        local coreConfiger = coreServ:GetConfiger()
        return coreConfiger:GetShareLink()
    end
    return ''
end

function WriteFile(filename, content)
    std.Sys:WriteAllText(filename, content)
end

function ReadFile(filename)
    return std.Sys:ReadAllText(filename)
end

function Ls(path, exts)
    return std.Sys:Ls(path, exts)
end

function UpdateSubscriptions()
    local proxyPort = std.Web:GetProxyPort()
    return std.Web:UpdateSubscriptions(proxyPort)
end

function SaveSubscriptions(subs)
    std.Misc:SetSubscriptionConfig(subs)
end

function GetSubscriptions()
    return std.Misc:GetSubscriptionConfig()
end

function GetLog(uid)
    if string.isempty(uid) then
        return std.Misc:GetLogAsString()
    end
    local coreServ = std.Server:GetServerByUid(uid)
    if coreServ == nil then
        return nil
    end
    local coreLogger = coreServ:GetLogger()
    return coreLogger:GetLogAsString()
end

function LuaAnalyzeCode(code)
    return std.Sys:LuaAnalyzeCode(code)
end

function GenLuaModuleSnippets(code)
    return std.Sys:LuaGenModuleSnippets(code)
end

function GetLuaStaticSnippets()
    return std.Sys:LuaGetStaticSnippets()
end

function ChangeLuaCoreIndex(name, index)
    return std.Sys:LuaServSetIndex(name, index)
end    

function StartLuaCore(name)
    std.Sys:LuaServStart(name)
end

function RestartLuaCore(name)
    std.Sys:LuaServRestart(name)
end

function StopLuaCore(name)
    std.Sys:LuaServStop(name)
end

function AbortLuaCore(name)
    std.Sys:LuaServAbort(name)
end

function RemoveLuaCore(name)
    return std.Sys:LuaServRemove(name)
end

function ChangeLuaCoreInfo(name, settings)
    return std.Sys:LuaServChangeSettings(name, settings)
end

function GetAllLuaCoreInfos()
    return std.Sys:LuaServGetAllCoreInfos()
end

function AddLuaScript(name, script)
    return std.Sys:LuaServAdd(name, script)
end

function GetAllLuaScripts()
    return std.Sys:LuaServGetAllScripts()
end

function RemoveLuaVm(luavm)
    std.Sys:LuaVmRemove(luavm)
end

function ClearLuaVmLog(luavm)
    std.Sys:LuaVmClearLog(luavm)
end

function GetLuaVmLog(luavm)
    return std.Sys:LuaVmGetLog(luavm)
end

function RunLuaScript(name, script, isLoadClr)
    local luavm = std.Sys:LuaVmCreate(name)
    if string.isempty(luavm) then
        return ""
    end
    isLoadClr = isLoadClr == true
    std.Sys:LuaVmRun(luavm, script, isLoadClr)
    return luavm
end

function StopLuaVm(luavm)
    std.Sys:LuaVmStop(luavm)
end

function AbortLuaVm(luavm)
    std.Sys:LuaVmAbort(luavm)
end

function FilterSelections(uids)
    local servs = std.Server:GetServersByUids(uids)
    local r = {}
    foreach coreServ in servs do
        local coreState = coreServ:GetCoreStates()
        local uid = coreState:GetUid()
        table.insert(r, uid)
    end
    return r
end

function GetAllServersUid()
    local servs = GetAllServers()
    local r = {}
    for _, coreServ in ipairs(servs) do
        local coreState = coreServ:GetCoreStates()
        local uid = coreState:GetUid()
        table.insert(r, uid)
    end
    return r
end

function GetAllNotTtestedServersUid()
    local servs = GetAllServers()
    local r = {}
    for _, coreServ in ipairs(servs) do
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
    local servs = GetAllServers()
    local r = {}
    for _, coreServ in ipairs(servs) do
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
    local servs = GetAllServers()
    local r = {}
    for _, coreServ in ipairs(servs) do
        local coreState = coreServ:GetCoreStates()
        if coreState:GetSpeedTestResult() == utils.Timeout then
            local uid = coreState:GetUid()
            table.insert(r, uid)
        end
    end
    return r
end

function SortServersByLatency(uids)
    std.Server:SortServersBySpeedTest(uids)
end

function SortServersByModifyDate(uids)
    std.Server:SortServersByLastModifiedDate(uids)
end

function SortServersBySummary(uids)
    std.Server:SortServersBySummary(uids)
end

function ReverseServersByIndex(uids)
    std.Server:ReverseServersByIndex(uids)
end

function CopyShareLinkOfServers(uids)
    local servs = std.Server:GetServersByUids(uids)
    local links = {}
    foreach coreServ in servs do
        local coreConfiger = coreServ:GetConfiger()
        local link = coreConfiger:GetShareLink()
        if not string.isempty(link) then
            table.insert(links, link)
        end
    end
    return table.concat(links, '\n') or ''
end

function RunLatencyTestOnServers(uids)
    return std.Server:RunSpeedTestByUids(uids)
end

function ChangeServersSetting(uids, s)
    local keys = {"coreName", "inbName", "inbIp", "inbPort", "isAutoRun", "mark", "remark", "tag1", "tag2", "tag3"}
    local servs = std.Server:GetServersByUids(uids)
    foreach coreServ in servs do
        local wserv = coreServ:Wrap()
        for _, key in pairs(keys) do
            local v = s[key]
            if v ~= nil then
                if key == "coreName" then
                    wserv:SetCustomCoreName(v)
                elseif key == "inbName" then
                    wserv:SetInboundName(v)
                elseif key == "inbIp" then
                    local port = wserv:GetInboundPort()
                    wserv:SetInboundAddr(v, port)
                elseif key == "inbPort" then
                    local ip = wserv:GetInboundIp()
                    wserv:SetInboundAddr(ip, tonumber(v))
                elseif key == "isAutoRun" then
                    wserv:SetIsAutoRun(v)
                elseif key == "mark" then
                    wserv:SetMark(v)
                elseif key == "remark" then
                    wserv:SetRemark(v)
                elseif  key == "tag1" then
                    wserv:SetTag1(v)
                elseif key == "tag2" then
                    wserv:SetTag2(v)
                elseif  key == "tag3" then
                    wserv:SetTag3(v)
                end
            end
        end
    end 
    return true
end

function GetFirstServSettings(uids)
    local servs = std.Server:GetServersByUids(uids)
    if servs.Count < 1 then
        return nil
    end
    local coreServ = servs[1]
    local coreState = coreServ:GetCoreStates()
    local uid = coreState:GetUid()
    return GetServSettings(uid)
end

function GetServSettings(uid)
    local coreServ = std.Server:GetServerByUid(uid)
    if not coreServ then
        return nil
    end
    local wserv = coreServ:Wrap()
    local r = GetTags(wserv)
    r["index"] = wserv:GetIndex()
    r["name"] = wserv:GetName()
    r["coreName"] = wserv:GetCustomCoreName()
    r["inbName"] = wserv:GetInboundName()
    r["inbIp"] = wserv:GetInboundIp()
    r["inbPort"] = wserv:GetInboundPort()
    return r
end

function SaveServSettings(uid, s)
    local coreServ = std.Server:GetServerByUid(uid)
    if not coreServ then
        return false
    end
    local wserv = coreServ:Wrap()
    wserv:SetCustomCoreName(s["coreName"])
    wserv:SetName(s["name"])
    local coreConfiger = coreServ:GetConfiger()
    coreConfiger:UpdateSummary() -- fix name is empty bug
    
    wserv:SetMark(s["mark"])
    wserv:SetRemark(s["remark"])
    wserv:SetMark(s["mark"])
    wserv:SetTag1(s["tag1"])
    wserv:SetTag2(s["tag2"])
    wserv:SetTag3(s["tag3"])
    
    wserv:SetIndex(tonumber(s["index"]) or 1)
    
    wserv:SetInboundName(s["inbName"])
    wserv:SetInboundAddr(s["inbIp"], tonumber(s["inbPort"]))
    
    wserv:SetIsAutoRun(s["isAutoRun"])
    std.Server:ResetIndexes()
    
    return true
end

function ChangeServIndex(uid, idx)
    local coreServ = std.Server:GetServerByUid(uid)
    if not coreServ then
        return false
    end
    local coreState = coreServ:GetCoreStates()
    coreState:SetIndex(idx)
    std.Server:ResetIndexes()
    return true
end

function GetAppVersion()
    return std.Sys:GetAppVersion()
end

function GetSerializedServers(pageNum, keyword)
    pageNum = tonumber(pageNum) or 1
    keyword = keyword or ""
    -- sLog:Debug("params:", pageNum, keyword)
    local filtered = GetFilteredServers(keyword)
    local max = #filtered
    local r = {
        ["pages"] = 1,
        ["data"] = {},
        ["isTesting"] = std.Server:IsRunningSpeedTest(),
        ["count"] = max,
    }
    
    if max < 1 then
        return r
    end
    
    local first = Clamp((pageNum - 1) * options['pageSize'] + 1, 1, max)
    local last = Clamp((pageNum) * options['pageSize'], first, max)
   
    r["pages"] = CalcTotalPageNumber(max)
    r["count"] = max
    local d = {}
    for i = first, last do
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
    local coreServ = std.Server:GetServerByUid(uid)
    if coreServ ~= nil then
        local coreCtrl = coreServ:GetCoreCtrl()
        if stopOthers == true then
            std.Server:StopAllServers()
        end
        coreCtrl:RestartCoreIgnoreError()
        return true
    end
    return false
end

function StopServ(uid)
    uid = uid or ""
    local coreServ = std.Server:GetServerByUid(uid)
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
    return std.Misc:SetUserSettings(p)
end

function GetUserSettings(props)
    local p = json.encode(props)
    return std.Misc:GetUserSettings(p)
end

function SaveServerConfig(uid, name, config)
    uid = uid or ""
    name = name or ""
    config = config or ""
    
    if string.isempty(config) then
        return "configIsEmpty"
    end
    
    if string.isempty(uid) then
        local ok = std.Server:Add(name, config, "")
        if not ok then
            return "addServerFailed"
        else
            return nil
        end
    end
    
    local coreServ = std.Server:GetServerByUid(uid)
    if coreServ == nil then
        return "serverNotFound"
    end
    
    local coreConfiger = coreServ:GetConfiger()
    coreConfiger:SetConfig(config)
    return nil
end

function GetServerFinalConfig(uid)
    local wserv = std.Server:GetWrappedServerByUid(uid)
    if wserv then
        wserv:GetFinalConfig()
        local config = wserv:GetFinalConfig()
        local ty = std.Misc:DetectConfigType(config)
        return {
            ["config"] = config,
            ["type"] = ty,
        }
    end
    return nil
end

function GetServerConfig(uid)
    local coreServ = std.Server:GetServerByUid(uid)
    if coreServ then
        local coreConfiger = coreServ:GetConfiger()
        local config = coreConfiger:GetConfig()
        local ty = std.Misc:DetectConfigType(config)
        return {
            ["config"] = config,
            ["type"] = ty,
        }
    end
    return nil
end

function DeleteServByUids(uids)
    return std.Server:DeleteServerByUids(uids)
end

function ImportShareLinks(links, mark)
    local c = std.Misc:ImportLinks(links, mark)
    std.Misc:RefreshFormMain()
    return c
end

function IsValidToken()
    return true
end

local function IsWhiteListedFunctions(j)
    local allowFuncs = {'GetSalt', 'GetAppVersion', 'GetServerVersion'}
    if table.contains(allowFuncs, j['fn']) then
        return true
    end
    return false
end

local function IsAuthorized(j)
    local token = options['token']
    if string.isempty(token) or j['token'] == token then
        return true
    end
    return false
end

local function IsAdminFunctions(j)
    local fn = string.lower(j["fn"])
    if not table.contains(lowerAdminFuncList, fn)
        and string.find(fn, "luacore", 1, true) == nil
        and string.find(fn, "luavm", 1, true) == nil
        and string.find(fn, "luascript", 1, true) == nil
    then
        return false
    end
    return true
end

local function CheckAdminPrivilege(j)
    if not IsAdminFunctions(j) then
        return true
    end
    local token = options['admintoken']
    if string.isempty(token) or j['admintoken'] == token then
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
    
    if not IsWhiteListedFunctions(j) then
        if not IsAuthorized(j) then
            std.Misc:Sleep(1000)
            return Response(false, 'unAuthorizedOperation')
        end
        if not CheckAdminPrivilege(j) then
            std.Misc:Sleep(1000)
            return Response(false, 'requireAdminPrivilege')
        end
    end
    
    local fn = j["fn"]
    if forbiddenFuncList[fn] then
        sLog:Warn("call forbidden function:", fn)
        return Response(false, "funcNotExists", fn)
    end
    
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

local function ListAllFunctions()
    local r = {
        ["no"] = {},
        ["all"] = {},
        ["admin"] = {},
        ["user"] = {},
    }
    local j = {}
    for key, _ in pairs(_G) do
        j['fn'] = key
        if forbiddenFuncList[key] then
            table.insert(r["no"], key)
        elseif IsWhiteListedFunctions(j) then
            table.insert(r["all"], key)
        elseif IsAdminFunctions(j) then
            table.insert(r["admin"], key)
        else
            table.insert(r["user"], key)
        end
    end
    sLog:Debug("Functions:", table.dump(r))
end

local function Main()
    lowerAdminFuncList = ToLower(adminFunctions)
    ParseOptions()
    local level = options['logLevel']
    sLog:SetLogLevel(level)
    -- sLog:Debug(table.dump(options))
    if level == Logger.logLevels.Debug then
        ListAllFunctions()
    end
    print("server.lua v" .. GetServerVersion())
    httpServ:Create(options['url'], options['public'], Handler, false)
    
    print("please visit", options['url'])
    httpServ:Run()
end

Main()
