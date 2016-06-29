
local xavante = require "xavante"
local filehandler = require "xavante.filehandler"
local cgiluahandler = require "xavante.cgiluahandler"
local redirecthandler = require "xavante.redirecthandler"

local config = require("config")
local conman = require("conman")

-- Define here where Xavante HTTP documents scripts are located
local webDir = "./www"

local mnigs_logo = '[meshnet-mgr]'

-- Xavante HTTP documents scripts are located
local webDir = config.server.webdir

xavante.HTTP{
    server = {host = "::", port = config.server.rpcport},
    
    defaultHost = {
    	rules = rules
    },
}

local rules = {}

-- index (redirect)
table.insert(rules, {
  match  = "^[^%./]*/$",
  with   = redirecthandler,
  params = { "index.html" }
})

-- rpc (redirect)
table.insert(rules, {
  match  = "^[^%./]*/jsonrpc/?$",
  with   = redirecthandler,
  params = { "jsonrpc.lua" }
})


-- cgi
table.insert(rules, {
  match = {
    "%.lp$", "%.lp/.*$", "%.lua$", "%.lua/.*$"
  },
  with  = cgiluahandler.makeHandler(webDir)
})

-- static content
table.insert(rules, {
  match  = ".",
  with   = filehandler,
  params = { baseDir = webDir }
})

local listenOn = {}

local function xavante_params(addr, port)
  return { host = addr, port = port }
end

if (config.server.listenIpv6) then
  table.insert(listenOn, xavante_params('::', config.server.rpcport))
end

if (config.server.listenIpv4) then
  table.insert(listenOn, xavante_params('0.0.0.0', config.server.rpcport))
end

for ifs, server in pairs(listenOn) do

  print(mnigs_logo,
    'Xavante listening on ' .. server.host ..
    ' port ' .. server.port)

  xavante.HTTP {
    defaultHost = { rules = rules },
    server = server
  }

end

local thread = require "llthreads2".new[[
	local conman = require("conman")
	conman.startConnectionManager()
]]

thread:start(true, true)

xavante.start()

print(mnigs_logo, "Shutting down")

thread:join()
