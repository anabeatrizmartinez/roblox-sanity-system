local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LOCAL_PLAYER = Players.LocalPlayer

local SanityConfig = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("SanityConfig"))
local UpdateSanityState = ReplicatedStorage:WaitForChild(SanityConfig.UpdateSanityStateEventName) :: RemoteEvent

local LIGHT_SOURCES_FOLDER_NAME = SanityConfig.LightSourcesFolderName
local DETECTION_RANGE = SanityConfig.LightDetectionRange

local LOOP_INTERVAL_SECONDS = SanityConfig.LoopIntervalSeconds

-- Locate the character root so distance to light can be measured.
local function getCharacterRootPosition(character: Model): Vector3?
	local root = character:FindFirstChild("HumanoidRootPart")
	if root and root:IsA("BasePart") then
		return root.Position
	end
	return nil
end

-- Normalize world positions for both parts and models.
local function getInstanceWorldPosition(instance: Instance): Vector3?
	if instance:IsA("BasePart") then
		return instance.Position
	end

	if instance:IsA("Model") then
		return instance:GetPivot().Position
	end

	return nil
end

-- Find the nearest configured light source to the given position.
local function getNearestLightDistance(fromPosition: Vector3): number?
	local folder = workspace:FindFirstChild(LIGHT_SOURCES_FOLDER_NAME)
	if not folder or not folder:IsA("Folder") then
		return nil
	end

	local nearest: number? = nil
	for _, child in folder:GetChildren() do
		local pos = getInstanceWorldPosition(child)
		if pos then
			local distance = (pos - fromPosition).Magnitude
			if nearest == nil or distance < nearest then
				nearest = distance
			end
		end
	end

	return nearest
end

-- Periodically adjust Sanity based on distance to the nearest light source.
local lastSentIsInLight: boolean? = nil
while true do
	-- Get the character.
	local character = LOCAL_PLAYER.Character
	if not character then
		task.wait(LOOP_INTERVAL_SECONDS)
		continue
	end

	-- Get the humanoid.
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		task.wait(LOOP_INTERVAL_SECONDS)
		continue
	end

	-- Stop all server updates on death by not sending events.
	if humanoid.Health <= 0 then
		task.wait(LOOP_INTERVAL_SECONDS)
		continue
	end

	-- Get the root position of the character.
	local rootPosition = getCharacterRootPosition(character)
	if not rootPosition then
		task.wait(LOOP_INTERVAL_SECONDS)
		continue
	end

	local nearestDistance = getNearestLightDistance(rootPosition)
	local isInLight = nearestDistance ~= nil and nearestDistance <= DETECTION_RANGE

	-- Send the sanity state to the server.
	if lastSentIsInLight == nil or lastSentIsInLight ~= isInLight then
		lastSentIsInLight = isInLight
		UpdateSanityState:FireServer(isInLight)
	end

	task.wait(LOOP_INTERVAL_SECONDS)
end