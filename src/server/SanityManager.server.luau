local Players = game:GetService("Players")

local SANITY_ATTRIBUTE_NAME = "Sanity"
local SANITY_STARTING_VALUE = 100

-- Ensure each player has a single Sanity attribute instance.
local function initializePlayerSanity(player: Player)
	if player:GetAttribute(SANITY_ATTRIBUTE_NAME) ~= nil then
		return
	end

	player:SetAttribute(SANITY_ATTRIBUTE_NAME, SANITY_STARTING_VALUE)
end

-- Initialize Sanity for players who join after the script runs.
Players.PlayerAdded:Connect(initializePlayerSanity)

-- Initialize Sanity for players already present when the script runs.
for _, player in Players:GetPlayers() do
	initializePlayerSanity(player)
end