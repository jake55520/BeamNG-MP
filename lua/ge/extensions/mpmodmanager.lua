--====================================================================================
-- All work by Titch2000 and jojos38.
-- You have no permission to edit, redistribute or upload. Contact us for more info!
--====================================================================================



local M = {}
print("MPModManager initialising...")



local timer = 0
local serverMods = {}
local mods = {"beammp"}



-- TRY CATCH FROM: https://gist.github.com/cwarden/1207556/a3c7caa194cad0c22871ac650159b40a88ecd702
function catch(what)
   return what[1]
end



function try(what)
	local status, result = pcall(what[1])
	if not status then
		what[2](result)
	end
	return result
end



local function IsModAllowed(n)
	for k,v in pairs(mods) do
		if string.lower(v) == string.lower(n) then
			return true
		end
	end
	for k,v in pairs(serverMods) do
		if string.lower(v) == string.lower(n) then
			return true
		end
	end
end



local function cleanUpSessionMods()
	for k,v in pairs(serverMods) do
		core_modmanager.deactivateMod(string.lower(v))
		core_modmanager.deleteMod(string.lower(v))
	end
	Lua:requestReload() -- reload Lua to make sure we don't have any leftover GE files
end



local function onUpdate(dt)
  if timer >= 8 then -- Checking mods every 8 seconds
    timer = 0
    --print("Checking Mods...")
    try {
		function()
			for modname,mdata in pairs(core_modmanager.getModList()) do
				if mdata.active then
					if not IsModAllowed(modname) then -- This mod is not allowed to be running
						print("This mod should not be running: "..modname)
						core_modmanager.deactivateMod(modname)
						core_modmanager.deleteMod(modname)
					end
				else -- The mod is not active but lets check if it should be
					if IsModAllowed(modname) then
						print("Inactive Mod but Should be Active: "..modname)
						core_modmanager.activateMod(string.lower(modname))--'/mods/'..string.lower(v)..'.zip')
					end
				end
			end
		end,
		catch {
			function(error)
				print('caught error: ' .. error)
				if string.match(error, "(a nil value)") and string.match(error, "getModList") then
					print("Time to reload lua as our custom mod manager was not loaded.")
					Lua:requestReload()
				end
			end
		}
    }
  end
  timer = timer + dt
end



local function setServerMods(mods)
  --print("Server Mods Set:")
  dump(mods)
  serverMods = mods
end



local function showServerMods()
  print(serverMods)
  dump(serverMods)
end



M.onUpdate = onUpdate
M.cleanUpSessionMods = cleanUpSessionMods
M.showServerMods = showServerMods
M.setServerMods = setServerMods



return M