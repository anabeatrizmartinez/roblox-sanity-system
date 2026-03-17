local Players = game:GetService("Players")

local LOCAL_PLAYER = Players.LocalPlayer

local SANITY_ATTRIBUTE_NAME = "Sanity"
local SANITY_MIN = 0
local SANITY_MAX = 100

local LIGHT_SOURCES_FOLDER_NAME = "LightSources"
local DETECTION_RANGE = 15

local DRAIN_PER_SECOND = 5
local RECOVERY_PER_SECOND = 10
local LOOP_INTERVAL_SECONDS = 1

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

-- Read the current Sanity value and fall back to the maximum when missing.
local function getSanity(): number
	local current = LOCAL_PLAYER:GetAttribute(SANITY_ATTRIBUTE_NAME)
	if typeof(current) ~= "number" then
		return SANITY_MAX
	end
	return current
end

-- Write a clamped Sanity value back onto the player attribute.
local function setSanity(value: number)
	LOCAL_PLAYER:SetAttribute(SANITY_ATTRIBUTE_NAME, math.clamp(value, SANITY_MIN, SANITY_MAX))
end

-- Ensure the player always starts with a valid Sanity value.
if LOCAL_PLAYER:GetAttribute(SANITY_ATTRIBUTE_NAME) == nil then
	setSanity(SANITY_MAX)
end

-- Periodically adjust Sanity based on distance to the nearest light source.
while true do
	local character = LOCAL_PLAYER.Character
	if character then
		local rootPosition = getCharacterRootPosition(character)
		if rootPosition then
			local nearestDistance = getNearestLightDistance(rootPosition)
			local currentSanity = getSanity()

			local nextSanity = currentSanity

			if nearestDistance == nil then
				nextSanity = currentSanity - DRAIN_PER_SECOND * LOOP_INTERVAL_SECONDS
			elseif nearestDistance > DETECTION_RANGE then
				nextSanity = currentSanity - DRAIN_PER_SECOND * LOOP_INTERVAL_SECONDS
			else
				nextSanity = currentSanity + RECOVERY_PER_SECOND * LOOP_INTERVAL_SECONDS
			end

			setSanity(nextSanity)
		end
	end

	task.wait(LOOP_INTERVAL_SECONDS)
end
