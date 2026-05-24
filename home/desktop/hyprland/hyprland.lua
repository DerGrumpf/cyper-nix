-- hyprland.lua — migrated from hyprlang for Hyprland 0.55+
-- https://wiki.hypr.land/Configuring/Start/

--------------------
---- VARIABLES -----
--------------------

local super = "SUPER"
local terminal = "kitty"
local fileManager = "yazi"
local theme = "-theme $HOME/.config/rofi/custom.rasi"
local menu = "rofi -show drun " .. theme
local filebrowser = "rofi -show filebrowser " .. theme
local power = "rofi -show p -modi p:rofi-power-menu -theme $HOME/.config/rofi/power.rasi"
local apps = "rofi -show window " .. theme

--------------------
---- MONITORS ------
--------------------

hl.monitor({ output = "DP-1", mode = "1920x1080@60", position = "1920x0", scale = 1 })
hl.monitor({ output = "HDMI-A-2", mode = "1920x1080@60", position = "0x0", scale = 1 })

-----------------------------
---- ENVIRONMENT VARIABLES --
-----------------------------

hl.env("NIXOS_OZONE_WL", "1")
hl.env("MOZ_ENABLE_WAYLAND", "1")
hl.env("MOZ_WEBRENDER", "1")
hl.env("_JAVA_AWT_WM_NONREPARENTING", "1")
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")
hl.env("QT_QPA_PLATFORM", "wayland")
hl.env("SDL_VIDEODRIVER", "wayland")
hl.env("GDK_BACKEND", "wayland,x11")
hl.env("XCURSOR_SIZE", "24")
hl.env("XCURSOR_THEME", "catppuccin-mocha-dark")
hl.env("EDITOR", "nvim")
hl.env("GSK_RENDERER", "gl")
hl.env("HYPRCURSOR_THEME", "catppuccin-mocha-dark")
hl.env("HYPRCURSOR_SIZE", "24")

--------------------
---- AUTOSTART -----
--------------------

hl.on("hyprland.start", function()
	hl.exec_cmd("awww-daemon --no-cache & disown")
	hl.exec_cmd("awww img ~/Pictures/Wallpapers/Ghost_in_the_Shell.png")
	hl.exec_cmd("waybar &")
end)

--------------------
---- CONFIG --------
--------------------

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
			tap_to_click = true, -- note: underscore, not hyphen
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
		layout = "dwindle",
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

	dwindle = {
		preserve_split = true,
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

-- Animations (bezier curves + animation tree)
hl.curve("myBezier", { type = "bezier", points = { { 0.05, 0.9 }, { 0.1, 1.05 } } })

hl.animation({ leaf = "windows", enabled = true, speed = 7, bezier = "myBezier" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 7, bezier = "default", style = "popin 80%" })
hl.animation({ leaf = "border", enabled = true, speed = 10, bezier = "default" })
hl.animation({ leaf = "borderangle", enabled = true, speed = 8, bezier = "default" })
hl.animation({ leaf = "fade", enabled = true, speed = 7, bezier = "default" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 6, bezier = "default" })

-- Per-device config
hl.device({
	name = "usb-optical-mouse-",
	sensitivity = 0,
})

--------------------
---- KEYBINDINGS ---
--------------------

-- Application bindings
hl.bind(super .. " + Q", hl.dsp.exec_cmd(terminal))
hl.bind(super .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(super .. " + O", hl.dsp.exec_cmd("obsidian"))
hl.bind(super .. " + I", hl.dsp.exec_cmd("floorp"))
hl.bind(super .. " + G", hl.dsp.exec_cmd("thunderbird"))
hl.bind("XF86Mail", hl.dsp.exec_cmd("thunderbird"))
hl.bind(super .. " + N", hl.dsp.exec_cmd("nautilus"))
hl.bind("XF86Search", hl.dsp.exec_cmd("nautilus"))

-- Exit
hl.bind(super .. " + M", hl.dsp.exit())

-- Rofi bindings
hl.bind(super .. " + F", hl.dsp.exec_cmd(filebrowser))
hl.bind(super .. " + A", hl.dsp.exec_cmd(apps))
hl.bind("Menu", hl.dsp.exec_cmd(apps))
hl.bind(super .. " + R", hl.dsp.exec_cmd(menu))
hl.bind("XF86LaunchA", hl.dsp.exec_cmd(menu))
hl.bind(super .. " + S", hl.dsp.exec_cmd(power))
hl.bind("XF86LaunchB", hl.dsp.exec_cmd(power))

-- Move focus
hl.bind(super .. " + left", hl.dsp.focus({ direction = "left" }))
hl.bind(super .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(super .. " + up", hl.dsp.focus({ direction = "up" }))
hl.bind(super .. " + down", hl.dsp.focus({ direction = "down" }))

-- Window modifiers
hl.bind(super .. " + P", hl.dsp.window.pseudo())
hl.bind(super .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(super .. " + C", hl.dsp.window.close())

-- Workspaces (1-10, 0 maps to 10)
for i = 1, 10 do
	local key = tostring(i % 10)
	hl.bind(super .. " + " .. key, hl.dsp.focus({ workspace = i }))
	hl.bind(super .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Special workspace (scratchpad)
hl.bind(super .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

-- Scroll through workspaces with mouse wheel
hl.bind(super .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(super .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

-- Screenshot
hl.bind(super .. " + Z", hl.dsp.exec_cmd("grim -g \"$(slurp)\" $HOME/Pictures/Screenshots/$(date +'%s_grim.png')"))
hl.bind(super .. " + U", hl.dsp.exec_cmd("grim $HOME/Pictures/Screenshots/$(date +'%s_grim.png')"))

-- Media controls (locked = works on lockscreen, repeating = held key)
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("pamixer -t"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("pamixer -i 5"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("pamixer -d 5"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl set +5%"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl set 5%-"), { locked = true, repeating = true })

-- Mouse bindings for move/resize
hl.bind(super .. " + mouse:272", hl.dsp.window.drag())
hl.bind(super .. " + mouse:273", hl.dsp.window.drag({ resize = true }))
