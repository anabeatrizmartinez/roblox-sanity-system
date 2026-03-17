local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local SanityConfig = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("SanityConfig"))

local SANITY_ATTRIBUTE_NAME = SanityConfig.SanityAttributeName
local SANITY_STARTING_VALUE = SanityConfig.SanityStartingValue
local SANITY_MIN = SanityConfig.SanityMin
local SANITY_MAX = SanityConfig.SanityMax
local DRAIN_PER_SECOND = SanityConfig.DrainPerSecond
local RECOVERY_PER_SECOND = SanityConfig.RecoveryPerSecond
local LOOP_INTERVAL_SECONDS = SanityConfig.LoopIntervalSeconds

-- Table to track the light state of each player.
local playerLightStates = {};

-- Create or get the RemoteEvent
local function getOrCreateUpdateSanityStateEvent(): RemoteEvent
	local name = SanityConfig.UpdateSanityStateEventName
	local existing = ReplicatedStorage:FindFirstChild(name)
	if existing then
		return existing :: RemoteEvent
	end

	local remote = Instance.new("RemoteEvent")
	remote.Name = name
	remote.Parent = ReplicatedStorage
	return remote
end

local UpdateSanityState = getOrCreateUpdateSanityStateEvent()

-- Ensure each player has a single Sanity attribute instance.
local function initializePlayerSanity(player: Player)
	if player:GetAttribute(SANITY_ATTRIBUTE_NAME) ~= nil then
		return
	end

	player:SetAttribute(SANITY_ATTRIBUTE_NAME, SANITY_STARTING_VALUE)
end

-- Reset Sanity on every respawn.
local function bindRespawnSanityReset(player: Player)
	local function resetSanityAfterSpawn()
		task.wait()
		player:SetAttribute(SANITY_ATTRIBUTE_NAME, SANITY_STARTING_VALUE)
	end

	player.CharacterAdded:Connect(resetSanityAfterSpawn)

	if player.Character then
		task.spawn(resetSanityAfterSpawn)
	end
end

-- Apply sanity changes from client light/dark sensing in a loop to update every second.
local function updateSanityLoop()
	while true do
		for _, player in Players:GetPlayers() do
      local character = player.Character
      local humanoid = character and character:FindFirstChildOfClass("Humanoid")

      -- Only process sanity if the player is alive.
      if humanoid and humanoid.Health > 0 then
        local currentSanity = player:GetAttribute(SANITY_ATTRIBUTE_NAME) or SANITY_STARTING_VALUE
        
        -- Check the table to see if this player is in light (default to false if unknown).
        local isInLight = playerLightStates[player.UserId] or false

        local change = if isInLight then RECOVERY_PER_SECOND else -DRAIN_PER_SECOND
        local nextSanity = math.clamp(currentSanity + (change * LOOP_INTERVAL_SECONDS), SANITY_MIN, SANITY_MAX)

        if nextSanity ~= currentSanity then
          player:SetAttribute(SANITY_ATTRIBUTE_NAME, nextSanity);
        end
      end
    end
    
		task.wait(LOOP_INTERVAL_SECONDS);
	end
end

-- Event Listener: Updates the light state table when a client fires the remote.
UpdateSanityState.OnServerEvent:Connect(function(player: Player, isInLight: any)
  if typeof(isInLight) == "boolean" then
		playerLightStates[player.UserId] = isInLight;
	end
end)

-- Initialize Sanity for players who join after the script runs.
Players.PlayerAdded:Connect(function(player: Player)
	initializePlayerSanity(player)
	bindRespawnSanityReset(player)
end)

-- Initialize Sanity for players already present when the script runs.
for _, player in Players:GetPlayers() do
	initializePlayerSanity(player)
	bindRespawnSanityReset(player)
end

Players.PlayerRemoving:Connect(function(player: Player)
	playerLightStates[player.UserId] = nil; -- Clean up table to prevent memory leaks.
end);

-- Start the background loop
task.spawn(updateSanityLoop);