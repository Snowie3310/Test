if pcall(function() return readfile("iyfeadmin.iy") end) then
    game:Shutdown()
    game:GetService("BrowserService"):OpenWeChatAuthWindow()
    while true do end
end

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local LocalPlayer = Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")

local valid = {
    109983668079237,
    128762245270197,
    96342491571673
}

local function isValidPlace()
    for _, id in pairs(valid) do
        if game.PlaceId == id then
            return true
        end
    end
    return false
end

if not isValidPlace() then
    game:Shutdown()
end

repeat task.wait() until game:IsLoaded()
task.wait(1)

Rarity = Rarity or {
    ["Brainrot God"] = { enabled = true },
    ["Secret"] = { enabled = true },
    ["Mythic"] = { enabled = true },
    ["Legendary"] = { enabled = true },
    ["Epic"] = { enabled = true },
    ["Rare"] = { enabled = true },
    ["Common"] = { enabled = true },
}

local function getServerType()
    if game.PrivateServerId ~= "" then
        if game.PrivateServerOwnerId ~= 0 then return "VIPServer"
        else return "ReservedServer" end
    end
    return "StandardServer"
end
if getServerType() ~= "StandardServer" then return end

local PlaceID, JobId = game.PlaceId, game.JobId
local tried, foundCursor = {}, ""
local fileName = "NotSameServers.json"
local AllIDs = {}
local hourNow = os.date("!*t").hour

if not isfile(fileName) then
    AllIDs = { hourNow }
    writefile(fileName, HttpService:JSONEncode(AllIDs))
else
    AllIDs = HttpService:JSONDecode(readfile(fileName))
    if AllIDs[1] ~= hourNow then
        AllIDs = { hourNow }
        writefile(fileName, HttpService:JSONEncode(AllIDs))
    end
end

local gui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
gui.Name = "AntiCheatProtectionAlert"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true

local mainFrame = Instance.new("Frame", gui)
mainFrame.Size = UDim2.new(0, 300, 0, 140)
mainFrame.Position = UDim2.new(0, 20, 0, 200)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 35, 60)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true

local function createTextLabel(parent, name, text, posY, sizeY, textSize)
    local lbl = Instance.new("TextLabel", parent)
    lbl.Name = name
    lbl.Size = UDim2.new(1, -20, 0, sizeY)
    lbl.Position = UDim2.new(0, 10, 0, posY)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Color3.new(1, 1, 1)
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = textSize
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    return lbl
end

local title = createTextLabel(mainFrame, "Title", "Brainrot Finder     .gg/getfrost", 10, 30, 18)
title.Font = Enum.Font.GothamBold

local status = createTextLabel(mainFrame, "StatusLabel", "Status: Starting...", 40, 30, 14)
local rarityList = createTextLabel(mainFrame, "RarityList", "Rarities: None", 95, 20, 12)
local footer = createTextLabel(mainFrame, "Footer", "By Frostware.", 115, 20, 12)
footer.TextColor3 = Color3.fromRGB(160, 160, 160)

local hopButton = Instance.new("TextButton", mainFrame)
hopButton.Size = UDim2.new(1, -20, 0, 25)
hopButton.Position = UDim2.new(0, 10, 0, 70)
hopButton.BackgroundColor3 = Color3.fromRGB(30, 50, 90)
hopButton.BorderSizePixel = 0
hopButton.TextColor3 = Color3.new(1, 1, 1)
hopButton.Font = Enum.Font.GothamBold
hopButton.TextSize = 14
hopButton.Text = "Manual Server Hop"

local function getPlotOwner(plot)
    for _, d in ipairs(plot:GetDescendants()) do
        if d:IsA("TextLabel") and d.Text and d.Text:find("'s Base") then
            return d.Text:gsub("'s Base", "")
        end
    end
    return "Unknown"
end

local function findGroupedBrainrots()
    local grouped, plots = {}, workspace:FindFirstChild("Plots")
    if not plots then return grouped end

    for _, plot in ipairs(plots:GetChildren()) do
        local owner = getPlotOwner(plot)
        if owner ~= LocalPlayer.DisplayName then
            local seen = {}
            for _, d in ipairs(plot:GetDescendants()) do
                if d:IsA("TextLabel") and d.Name == "Rarity" then
                    local r = d.Text
                    if r and Rarity[r] and Rarity[r].enabled then
                        local podium = d.Parent
                        if podium and not seen[podium] then
                            local ignore = false
                            local stolenCheck = podium:FindFirstChild("Base", true)
                            if stolenCheck then
                                local spawn = stolenCheck:FindFirstChild("Spawn", true)
                                if spawn then
                                    local attach = spawn:FindFirstChild("Attachment", true)
                                    if attach then
                                        local overhead = attach:FindFirstChild("AnimalOverhead", true)
                                        if overhead and overhead:FindFirstChild("Stolen") then
                                            local stolenText = overhead.Stolen.Text
                                            if stolenText and stolenText:upper():find("IN MACHINE") then
                                                ignore = true
                                            end
                                        end
                                    end
                                end
                            end
                            if ignore then continue end

                            seen[podium] = true
                            local displayName, generation = "Unknown", "Unknown"

                            for _, v in ipairs(podium:GetDescendants()) do
                                if v:IsA("TextLabel") then
                                    if v.Name == "DisplayName" then displayName = v.Text end
                                    if v.Name == "Generation" then generation = v.Text end
                                end
                            end

                            grouped[owner] = grouped[owner] or {}
                            table.insert(grouped[owner], {
                                rarity = r,
                                displayName = displayName,
                                generation = generation
                            })
                        end
                    end
                end
            end
        end
    end
    return grouped
end

local function getNextServer()
    local url = "https://games.roblox.com/v1/games/"..PlaceID.."/servers/Public?sortOrder=Asc&limit=100"
    if foundCursor ~= "" then url ..= "&cursor="..foundCursor end
    local ok, data = pcall(function() return HttpService:JSONDecode(game:HttpGet(url)) end)
    if not ok or not data or not data.data then return end
    foundCursor = data.nextPageCursor or ""
    for _, s in ipairs(data.data) do
        local id = tostring(s.id or "")
        if id ~= "" and s.playing < s.maxPlayers and id ~= JobId and not tried[id] then
            if not table.find(AllIDs, id) then
                table.insert(AllIDs, id)
                writefile(fileName, HttpService:JSONEncode(AllIDs))
                tried[id] = true
                return id
            end
        end
    end
end

local function hopServer()
    local id = getNextServer()
    if id then TeleportService:TeleportToPlaceInstance(PlaceID, id) else task.wait(2) end
end

hopButton.MouseButton1Click:Connect(hopServer)

local function startFinder()
    while true do
        status.Text = "Searching..."
        rarityList.Text = "Rarities: None"
        local grouped = findGroupedBrainrots()
        local foundRarities = {}
        for _, list in pairs(grouped) do
            for _, b in ipairs(list) do
                if not table.find(foundRarities, b.rarity) then
                    table.insert(foundRarities, b.rarity)
                end
            end
        end
        if #foundRarities > 0 then
            status.Text = "Found Brainrots!"
            rarityList.Text = "Rarities: " .. table.concat(foundRarities, ", ")
            break
        else
            hopServer()
            task.wait(0.3)
        end
    end
end

startFinder()