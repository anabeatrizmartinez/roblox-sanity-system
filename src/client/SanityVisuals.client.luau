local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LOCAL_PLAYER = Players.LocalPlayer

local SanityConfig = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("SanityConfig"))

local SANITY_ATTRIBUTE_NAME = SanityConfig.SanityAttributeName
local SANITY_MIN = SanityConfig.SanityMin
local SANITY_MAX = SanityConfig.SanityMax

local BLUR_EFFECT_NAME = SanityConfig.BlurEffectName

local BASE_FOV = SanityConfig.BaseFov
local FOV_SMOOTH_TIME_SECONDS = SanityConfig.FovSmoothTimeSeconds

local SHAKE_SANITY_THRESHOLD = SanityConfig.ShakeSanityThreshold
local SHAKE_STEP_SECONDS = SanityConfig.ShakeStepSeconds
local SHAKE_MAX_TRANSLATION_STUDS = SanityConfig.ShakeMaxTranslationStuds
local SHAKE_MAX_ROTATION_DEGREES = SanityConfig.ShakeMaxRotationDegrees
local SHAKE_RENDER_STEP_NAME = SanityConfig.ShakeRenderStepName

local rng = Random.new()

local currentFovTween: Tween? = nil
local shakeTimerSeconds = 0
local currentShakeOffset = CFrame.identity

-- Read current Sanity attribute and normalize missing/invalid values.
local function getSanity(): number
	local value = LOCAL_PLAYER:GetAttribute(SANITY_ATTRIBUTE_NAME)
	if typeof(value) ~= "number" then
		return SANITY_MAX
	end
	return math.clamp(value, SANITY_MIN, SANITY_MAX)
end

-- Apply blur size derived from the current Sanity value.
local function updateBlurFromSanity(sanity: number)
	local blur = Lighting:FindFirstChild(BLUR_EFFECT_NAME)
	if not blur or not blur:IsA("BlurEffect") then
		return
	end

	local targetSize = (SANITY_MAX - sanity) / 5
	blur.Size = math.clamp(targetSize, 0, 100)
end

-- Smoothly tween the camera field of view derived from the current Sanity value.
local function updateFovFromSanity(sanity: number)
	local camera = workspace.CurrentCamera
	if not camera then
		return
	end

	local targetFov = BASE_FOV + (SANITY_MAX - sanity) / 4
	targetFov = math.clamp(targetFov, 1, 120)

	if currentFovTween then
		currentFovTween:Cancel()
		currentFovTween = nil
	end

	currentFovTween = TweenService:Create(
		camera,
		TweenInfo.new(FOV_SMOOTH_TIME_SECONDS, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{ FieldOfView = targetFov }
	)
	currentFovTween:Play()
end

-- Compute a small randomized camera offset when Sanity is critically low.
local function recomputeShakeOffset(sanity: number)
	if sanity >= SHAKE_SANITY_THRESHOLD then
		currentShakeOffset = CFrame.identity
		return
	end

	local intensity = math.clamp((SHAKE_SANITY_THRESHOLD - sanity) / SHAKE_SANITY_THRESHOLD, 0, 1)

	local translationScale = SHAKE_MAX_TRANSLATION_STUDS * intensity
	local rotationScaleRadians = math.rad(SHAKE_MAX_ROTATION_DEGREES) * intensity

	local dx = (rng:NextNumber(-1, 1)) * translationScale
	local dy = (rng:NextNumber(-1, 1)) * translationScale

	local rx = (rng:NextNumber(-1, 1)) * rotationScaleRadians
	local ry = (rng:NextNumber(-1, 1)) * rotationScaleRadians
	local rz = (rng:NextNumber(-1, 1)) * rotationScaleRadians

	currentShakeOffset = CFrame.new(dx, dy, 0) * CFrame.Angles(rx, ry, rz)
end

-- Track Sanity changes and update all visual feedback channels.
local function updateAllVisuals()
	local sanity = getSanity()
	updateBlurFromSanity(sanity)
	updateFovFromSanity(sanity)
	recomputeShakeOffset(sanity)
end

-- Inject camera shake after the default camera scripts update the camera.
RunService:BindToRenderStep(
	SHAKE_RENDER_STEP_NAME,
	Enum.RenderPriority.Camera.Value + 1,
	function(dt: number)
		local sanity = getSanity()
		if sanity >= SHAKE_SANITY_THRESHOLD then
			return
		end

		shakeTimerSeconds += dt
		if shakeTimerSeconds >= SHAKE_STEP_SECONDS then
			shakeTimerSeconds = 0
			recomputeShakeOffset(sanity)
		end

		local camera = workspace.CurrentCamera
		if not camera then
			return
		end

		camera.CFrame = camera.CFrame * currentShakeOffset
	end
)

-- Re-apply current effects whenever Sanity changes or the camera swaps.
LOCAL_PLAYER:GetAttributeChangedSignal(SANITY_ATTRIBUTE_NAME):Connect(updateAllVisuals)
workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(updateAllVisuals)

updateAllVisuals()