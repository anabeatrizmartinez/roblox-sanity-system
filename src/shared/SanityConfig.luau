return {
	-- Attribute keys
	SanityAttributeName = "Sanity",
	UpdateSanityStateEventName = "UpdateSanityState",

	-- Sanity bounds + spawn behavior
	SanityMin = 0,
	SanityMax = 100,
	SanityStartingValue = 100,

	-- Sanity logic (light-based)
	LightSourcesFolderName = "LightSources",
	LightDetectionRange = 15,
	DrainPerSecond = 5,
	RecoveryPerSecond = 10,
	LoopIntervalSeconds = 1,

	-- Sanity visuals (post-processing + camera)
	BlurEffectName = "SanityBlur",
	BaseFov = 70,
	FovSmoothTimeSeconds = 0.25,

	-- Camera shake when sanity is low
	ShakeSanityThreshold = 30,
	ShakeStepSeconds = 0.1,
	ShakeMaxTranslationStuds = 0.15,
	ShakeMaxRotationDegrees = 1,
	ShakeRenderStepName = "SanityCameraShake",
}