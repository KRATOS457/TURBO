-- Your loader (no key)
local src = "https://raw.githubusercontent.com/KRATOS457/TURBO/main/main.lua"
local success, response = pcall(function()
    return game:HttpGet(src)
end)

if success then
    loadstring(response)()
else
    warn("Failed to load script:", response)
end
