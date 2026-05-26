-- hyprland.lua — migrated from hyprlang for Hyprland 0.55+
-- https://wiki.hypr.land/Configuring/Start/

-- ── Variables ────────────────────────────────────────────────────────────────

local super = "SUPER"
local terminal = "kitty"
local fileManager = "yazi"
local theme = "-theme $HOME/.config/rofi/custom.rasi"
local menu = "rofi -show drun " .. theme
local filebrowser = "rofi -show filebrowser " .. theme
local power = "rofi -show p -modi p:rofi-power-menu -theme $HOME/.config/rofi/power.rasi"
local apps = "rofi -show window " .. theme
local screenshot = "$HOME/Pictures/Screenshots/$(date +'%s_grim.png')"

-- ── Helpers ───────────────────────────────────────────────────────────────────

-- Bind a list of { key, action [, opts] } entries
local function bind_all(list)
	for _, b in ipairs(list) do
		hl.bind(b[1], b[2], b[3])
	end
end

-- Bind a list of { key, cmd [, opts] } entries as exec_cmd actions
local function bind_exec(list)
	for _, b in ipairs(list) do
		hl.bind(b[1], hl.dsp.exec_cmd(b[2]), b[3])
	end
end

-- Bind a list of { key, layout_msg } entries as layout actions
local function bind_layout(list)
	for _, b in ipairs(list) do
		hl.bind(b[1], hl.dsp.layout(b[2]))
	end
end

-- ── Monitors ─────────────────────────────────────────────────────────────────

local monitors = {
	{ output = "DP-1", mode = "1920x1080@60", position = "1920x0", scale = 1 },
	{ output = "HDMI-A-2", mode = "1920x1080@60", position = "0x0", scale = 1 },
}

for _, m in ipairs(monitors) do
	hl.monitor(m)
end

-- ── Environment ──────────────────────────────────────────────────────────────

local env_vars = {
	NIXOS_OZONE_WL = "1",
	MOZ_ENABLE_WAYLAND = "1",
	MOZ_WEBRENDER = "1",
	_JAVA_AWT_WM_NONREPARENTING = "1",
	QT_WAYLAND_DISABLE_WINDOWDECORATION = "1",
	QT_QPA_PLATFORM = "wayland",
	SDL_VIDEODRIVER = "wayland",
	GDK_BACKEND = "wayland,x11",
	XCURSOR_SIZE = "24",
	XCURSOR_THEME = "catppuccin-mocha-dark",
	EDITOR = "nvim",
	GSK_RENDERER = "gl",
	HYPRCURSOR_THEME = "catppuccin-mocha-dark",
	HYPRCURSOR_SIZE = "24",
}

for k, v in pairs(env_vars) do
	hl.env(k, v)
end

-- ── Autostart ────────────────────────────────────────────────────────────────

local wallpaper = "$HOME/Pictures/Wallpapers/Ghost_in_the_Shell.png"

local autostart = {
	"sleep 2 && waybar & disown",
}

hl.on("hyprland.start", function()
	for _, cmd in ipairs(autostart) do
		hl.exec_cmd(cmd)
	end
end)

-- ── Config ───────────────────────────────────────────────────────────────────

hl.config({
	debug = {
		disable_logs = false,
		enable_stdout_logs = false,
	},

	input = {
		kb_layout = "de",
		kb_variant = "mac",
		kb_options = "apple:fn_lock",
		repeat_rate = 50,
		repeat_delay = 300,
		accel_profile = "flat",
		follow_mouse = 1,
		mouse_refocus = false,
		sensitivity = 0,
		numlock_by_default = true,
		touchpad = {
			natural_scroll = true,
			tap_to_click = true,
		},
	},

	general = {
		gaps_in = 2,
		gaps_out = 0,
		border_size = 4,
		col = {
			active_border = "rgba(a6e3a1ff)",
			inactive_border = "rgba(f38ba8ff)",
		},
		layout = "scrolling",
		allow_tearing = false,
	},

	decoration = {
		rounding = 1,
		shadow = {
			enabled = false,
			range = 16,
			render_power = 4,
			color = "rgba(a6e3a1ff)",
			color_inactive = "rgba(f38ba8ff)",
		},
		blur = {
			enabled = false,
			size = 1,
			passes = 3,
			new_optimizations = true,
			noise = 0.04,
		},
	},

	animations = {
		enabled = true,
	},

	scrolling = {
		column_width = 0.5,
		fullscreen_on_one_column = true,
		focus_fit_method = 1,
		follow_focus = true,
		follow_min_visible = 0.4,
		explicit_column_widths = "0.333, 0.5, 0.667, 1.0",
		wrap_focus = true,
		wrap_swapcol = true,
		direction = "right",
	},

	misc = {
		force_default_wallpaper = 0,
		disable_hyprland_logo = true,
		disable_splash_rendering = true,
		mouse_move_enables_dpms = true,
		key_press_enables_dpms = true,
		vrr = 0,
	},
})

-- ── Animations ───────────────────────────────────────────────────────────────

hl.curve("myBezier", { type = "bezier", points = { { 0.05, 0.9 }, { 0.1, 1.05 } } })
hl.curve("mySpring", { type = "spring", mass = 0.6, stiffness = 70.00, dampening = 10.00 })

local animations = {
	{ leaf = "windows", enabled = true, speed = 10, spring = "mySpring" },
	{ leaf = "windowsOut", enabled = true, speed = 10, spring = "mySpring", style = "popin 80%" },
	{ leaf = "border", enabled = true, speed = 10, spring = "mySpring" },
	{ leaf = "borderangle", enabled = true, speed = 10, spring = "mySpring" },
	{ leaf = "fade", enabled = true, speed = 10, spring = "mySpring" },
	{ leaf = "workspaces", enabled = true, speed = 10, spring = "mySpring" },
}

for _, anim in ipairs(animations) do
	hl.animation(anim)
end

-- ── Devices ──────────────────────────────────────────────────────────────────

local devices = {
	{ name = "usb-optical-mouse-", sensitivity = 0 },
}

for _, d in ipairs(devices) do
	hl.device(d)
end

-- ── Window Rules ─────────────────────────────────────────────────────────────

local window_rules = {
	{ name = "kitty_width", match = { class = "kitty" }, scrolling_width = 0.5 },
	{ name = "browser_width", match = { class = "floorp" }, scrolling_width = 0.667 },
	{ name = "obsidian_width", match = { class = "obsidian" }, scrolling_width = 0.5 },
	{ name = "nautilus_width", match = { class = "nautilus" }, scrolling_width = 0.333 },
	{ name = "thunderbird_width", match = { class = "thunderbird" }, scrolling_width = 0.667 },
}

for _, rule in ipairs(window_rules) do
	hl.window_rule(rule)
end

-- ── Binds ────────────────────────────────────────────────────────────────────

-- Applications & launchers
bind_exec({
	{ super .. " + Q", terminal },
	{ super .. " + E", fileManager },
	{ super .. " + O", "obsidian" },
	{ super .. " + I", "floorp" },
	{ super .. " + G", "thunderbird" },
	{ "XF86Mail", "thunderbird" },
	{ super .. " + N", "nautilus" },
	{ "XF86Search", "nautilus" },
	-- Rofi
	{ super .. " + F", filebrowser },
	{ super .. " + A", apps },
	{ "Menu", apps },
	{ super .. " + R", menu },
	{ "XF86LaunchA", menu },
	{ super .. " + S", power },
	{ "XF86LaunchB", power },
	-- Screenshots
	{ super .. " + Z", 'grim -g "$(slurp)" ' .. screenshot },
	{ super .. " + U", "grim " .. screenshot },
	-- Media & brightness (locked = works on lockscreen, repeating = held key)
	{ "XF86AudioMute", "pamixer -t", { locked = true } },
	{ "XF86AudioPlay", "playerctl play-pause", { locked = true } },
	{ "XF86AudioNext", "playerctl next", { locked = true } },
	{ "XF86AudioPrev", "playerctl previous", { locked = true } },
	{ "XF86AudioRaiseVolume", "pamixer -i 5", { locked = true, repeating = true } },
	{ "XF86AudioLowerVolume", "pamixer -d 5", { locked = true, repeating = true } },
	{ "XF86MonBrightnessUp", "brightnessctl set +5%", { locked = true, repeating = true } },
	{ "XF86MonBrightnessDown", "brightnessctl set 5%-", { locked = true, repeating = true } },
})

-- Window actions
bind_all({
	{ super .. " + M", hl.dsp.exit() },
	{ super .. " + V", hl.dsp.window.float({ action = "toggle" }) },
	{ super .. " + C", hl.dsp.window.close() },
	-- Mouse move/resize
	{ super .. " + mouse:272", hl.dsp.window.drag() },
	{ super .. " + mouse:273", hl.dsp.window.drag({ resize = true }) },
	-- Switch workspaces with mouse wheel
	{ super .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }) },
	{ super .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }) },
})

-- Directional focus (up/down move within a column; left/right scroll between columns)
for _, dir in ipairs({ "left", "right", "up", "down" }) do
	hl.bind(super .. " + " .. dir, hl.dsp.layout("focus " .. dir))
end

-- Scrolling layout commands
bind_layout({
	-- Column navigation
	{ super .. " + period", "move +col" },
	{ super .. " + comma", "move -col" },
	-- Column swap
	{ super .. " + SHIFT + period", "swapcol r" },
	{ super .. " + SHIFT + comma", "swapcol l" },
	-- Column resize (cycle through explicit_column_widths)
	{ super .. " + equal", "colresize +conf" },
	{ super .. " + minus", "colresize -conf" },
	-- Fine-grained resize
	{ super .. " + SHIFT + equal", "colresize +0.05" },
	{ super .. " + SHIFT + minus", "colresize -0.05" },
	-- Fit operations
	{ super .. " + F1", "fit active" },
	{ super .. " + F2", "fit visible" },
	{ super .. " + F3", "fit all" },
	-- Promote window to its own column / consume into previous
	{ super .. " + RETURN", "promote" },
	{ super .. " + SHIFT + RETURN", "consume_or_expel prev" },
	-- Expel/consume explicitly
	{ super .. " + bracketright", "expel" },
	{ super .. " + bracketleft", "consume" },
	-- Toggle scroll lock for active workspace
	{ super .. " + SHIFT + S", "inhibit_scroll" },
})

-- Workspaces 1–10 (key 0 maps to workspace 10)
for i = 1, 10 do
	local key = tostring(i % 10)
	hl.bind(super .. " + " .. key, hl.dsp.focus({ workspace = i }))
	hl.bind(super .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Special workspace (scratchpad)
hl.bind(super .. " + grave", hl.dsp.window.move({ workspace = "special:magic" }))

-- ── Workspace Rules ───────────────────────────────────────────────────────────

local workspace_rules = {
	{ workspace = "1", layout_opts = { direction = "right" } },
	{ workspace = "2", layout_opts = { direction = "right" } },
	{ workspace = "3", layout_opts = { direction = "right" } },
}

for _, rule in ipairs(workspace_rules) do
	hl.workspace_rule(rule)
end
