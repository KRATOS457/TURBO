local url = "https://raw.githubusercontent.com/KRATOS457/TURBO/main/main.lua"
local success, scriptContent = pcall(function()
    return game:HttpGet(url)
end)

if success then
    loadstring(scriptContent)()
else
    warn("Failed to load main.lua:", scriptContent)
end
