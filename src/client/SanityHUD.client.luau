local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LOCAL_PLAYER = Players.LocalPlayer

local SanityConfig = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("SanityConfig"))

local SANITY_ATTRIBUTE_NAME = SanityConfig.SanityAttributeName
local SANITY_MIN = SanityConfig.SanityMin
local SANITY_MAX = SanityConfig.SanityMax

local TWEEN_TIME = 0.25
local TWEEN_EASING_STYLE = Enum.EasingStyle.Quad
local TWEEN_EASING_DIRECTION = Enum.EasingDirection.Out

local currentTween: Tween? = nil
local cachedProgressBar: Frame? = nil

-- Resolve and cache the Sanity progress bar inside PlayerGui.
local function resolveProgressBar(): Frame?
	local playerGui = LOCAL_PLAYER:WaitForChild("PlayerGui") :: PlayerGui

	local sanityGui = playerGui:FindFirstChild("SanityGui")
	if not sanityGui or not sanityGui:IsA("ScreenGui") then
		return nil
	end

	local background = sanityGui:FindFirstChild("Background")
	if not background or not background:IsA("Frame") then
		return nil
	end

	local progressBar = background:FindFirstChild("ProgressBar")
	if not progressBar or not progressBar:IsA("Frame") then
		return nil
	end

	cachedProgressBar = progressBar
	return cachedProgressBar
end

-- Read and clamp the current sanity value from the player.
local function getSanity(): number
	local value = LOCAL_PLAYER:GetAttribute(SANITY_ATTRIBUTE_NAME)
	if typeof(value) ~= "number" then
		return SANITY_MAX
	end

	return math.clamp(value, SANITY_MIN, SANITY_MAX)
end

-- Tween the Sanity progress bar size based on the current normalized sanity.
local function updateHud()
	local progressBar = cachedProgressBar or resolveProgressBar()
	if not progressBar then
		return
	end

	local sanity = getSanity()
	local normalized = 0
	if SANITY_MAX > 0 then
		normalized = sanity / SANITY_MAX
	end
	normalized = math.clamp(normalized, 0, 1)

	local currentSize = progressBar.Size
	local targetSize = UDim2.new(normalized, 0, currentSize.Y.Scale, currentSize.Y.Offset)

	if currentTween then
		currentTween:Cancel()
		currentTween = nil
	end

	currentTween = TweenService:Create(
		progressBar,
		TweenInfo.new(TWEEN_TIME, TWEEN_EASING_STYLE, TWEEN_EASING_DIRECTION),
		{ Size = targetSize }
	)
	currentTween:Play()
end

-- Re-resolve HUD and apply an update when PlayerGui resets or changes.
local function hookGuiLifecycle()
	local playerGui = LOCAL_PLAYER:WaitForChild("PlayerGui") :: PlayerGui

	playerGui.ChildAdded:Connect(function(child)
		if child.Name == "SanityGui" then
			cachedProgressBar = nil
			resolveProgressBar()
			updateHud()
		end
	end)

	playerGui.ChildRemoved:Connect(function(child)
		if child.Name == "SanityGui" then
			cachedProgressBar = nil
		end
	end)
end

hookGuiLifecycle()

LOCAL_PLAYER:GetAttributeChangedSignal(SANITY_ATTRIBUTE_NAME):Connect(updateHud)

updateHud()