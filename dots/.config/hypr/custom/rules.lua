hl.window_rule({
	match = { class = "^[Ee]mulator$" },
	float = true,
})

hl.window_rule({
	match = { class = "^scrcpy$" },
	float = true,
	size = { 432, 936 },
})

-- hl.window_rule({
-- 	name = "steam-osk-focus",
-- 	match = {
-- 		class = "^(steam)$",
-- 		title = "^(Steam Big Picture Mode|notificationtoasts.*|)$",
-- 	},
-- 	stay_focused = true,
-- 	no_anim = true,
-- 	fullscreen = true,
-- })

-- hl.window_rule({
-- 	name = "sky-focus",
-- 	match = { class = "^(steam_app_2325290)$" },
-- 	stay_focused = true,
-- 	no_anim = true,
-- 	fullscreen = true,
-- })

hl.window_rule({
	name = "steam-games-fullscreen",
	match = { class = "^steam_app_.*$" },
	no_anim = true,
	fullscreen = true,
})
