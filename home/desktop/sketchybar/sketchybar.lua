-- Main configuration file: sketchybar.lua
-- Save this in ~/.config/sketchybar/

-- SketchyBar Lua API
sbar = require("sketchybar")

-- Colors (Catppuccin Mocha theme)
local colors = {
	text = 0xffcdd6f4,
	bg = 0xff1e1e2e,
	accent = 0xff74c7ec,
	green = 0xffa6e3a1,
	rosewater = 0xfff5e0dc,
	flamingo = 0xfff2cdcd,
	pink = 0xfff5c2e7,
	mauve = 0xffcba6f7,
	red = 0xfff38ba8,
	maroon = 0xffeba0ac,
	peach = 0xfffab387,
	yellow = 0xfff9e2af,
	teal = 0xff94e2d5,
	sky = 0xff89dceb,
	sapphire = 0xff74c7ec,
	blue = 0xff89b4fa,
	lavender = 0xffb4befe,
	subtext1 = 0xffbac2de,
	subtext0 = 0xffa6adc8,
	overlay2 = 0xff9399b2,
	overlay1 = 0xff7f849c,
	overlay0 = 0xff6c7086,
	surface2 = 0xff585b70,
	surface1 = 0xff45475a,
	surface0 = 0xff313244,
	base = 0xff1e1e2e,
	mantle = 0xff181825,
	crust = 0xff11111b,
}

-- Default styles
sbar.default({
	icon = {
		color = colors.text,
		font = "Hack Nerd Font:Bold:14.0",
		padding_right = 4,
	},
	label = {
		color = colors.text,
		font = "Hack Nerd Font:Bold:14.0",
	},
	padding_right = 20,
	popup = {
		background = {
			border_width = 2,
			corner_radius = 9,
			border_color = colors.accent,
			color = colors.bg,
			padding_right = 12,
		},
	},
})

-- Bar configuration
sbar.bar({
	height = 32,
	position = "top",
	y_offset = 6,
	padding_left = 12,
	padding_right = 12,
	margin = 12,
	color = colors.bg,
	border_color = colors.accent,
	border_width = 2,
	corner_radius = 60,
})

-- Apple logo menu
local apple_logo = sbar.add("item", "apple.logo", {
	icon = {
		string = " ",
		padding_left = 6,
		font = "Hack Nerd Font:Bold:20.0",
	},
	label = { drawing = false },
	padding_left = 0,
	click_script = "sketchybar -m --set $NAME popup.drawing=toggle",
	popup = {
		y_offset = 8,
	},
})

sbar.add("item", "apple.about", {
	position = "popup.apple.logo",
	icon = " ",
	label = "About",
	click_script = 'osascript -e \'tell application "System Events" to tell process "Finder" to click menu item "About This Mac" of menu 1 of menu bar item "Apple" of menu bar 1\'; sketchybar -m --set apple.logo popup.drawing=off',
	padding_left = 8,
	padding_right = 8,
})

sbar.add("item", "apple.preferences", {
	position = "popup.apple.logo",
	icon = " ",
	label = "Preferences",
	click_script = "open -a 'System Preferences'; sketchybar -m --set apple.logo popup.drawing=off",
	padding_left = 8,
	padding_right = 8,
})

sbar.add("item", "apple.activity", {
	position = "popup.apple.logo",
	icon = " ",
	label = "Activity",
	click_script = "open -a 'Activity Monitor'; sketchybar -m --set apple.logo popup.drawing=off",
	padding_left = 8,
	padding_right = 8,
})

sbar.add("item", "apple.lock", {
	position = "popup.apple.logo",
	icon = " ",
	label = "Lock Screen",
	click_script = "pmset displaysleepnow; sketchybar -m --set apple.logo popup.drawing=off",
	padding_left = 8,
	padding_right = 8,
})

-- Spaces
local space_icons = { "󰖟 ", " ", " ", " ", " ", " ", "7", "8", "9", "10" }
for i = 1, #space_icons do
	local space = sbar.add("space", "space." .. i, {
		space = i,
		icon = {
			string = space_icons[i],
			padding_left = 2,
			padding_right = 2,
			highlight_color = colors.green,
		},
		label = { drawing = false },
		padding_right = 4,
		script = "$CONFIG_DIR/plugins/space.lua",
		click_script = "yabai -m space --focus " .. i,
	})

	space:subscribe("space_change", function(env)
		local selected = env.SELECTED == "true"
		sbar.set(env.NAME, { icon = { highlight = selected } })
	end)
end

-- Front app
local front_app = sbar.add("item", "front_app", {
	position = "center",
	icon = "󰶮 ",
	script = "$CONFIG_DIR/plugins/front_app.lua",
})

front_app:subscribe("front_app_switched", function(env)
	sbar.set(env.NAME, { label = env.INFO })
end)

-- Clock
local clock = sbar.add("item", "clock", {
	position = "right",
	icon = " ",
	padding_right = 0,
	update_freq = 1,
	script = "$CONFIG_DIR/plugins/clock.lua",
})

clock:subscribe("routine", function()
	sbar.exec("date '+%a %d %b %H:%M:%S'", function(date)
		sbar.set("clock", { label = date })
	end)
end)

-- Battery
local battery = sbar.add("item", "battery", {
	position = "right",
	update_freq = 1,
	script = "$CONFIG_DIR/plugins/battery.lua",
})

battery:subscribe({ "routine", "system_woke", "power_source_change" }, function()
	sbar.exec("pmset -g batt", function(batt_info)
		local percentage = batt_info:match("(%d+)%%")
		local charging = batt_info:match("AC Power") ~= nil

		if not percentage then
			return
		end

		local icon = " "
		local pct = tonumber(percentage)

		if pct >= 90 then
			icon = " "
		elseif pct >= 60 then
			icon = " "
		elseif pct >= 30 then
			icon = " "
		elseif pct >= 10 then
			icon = " "
		else
			icon = " "
		end

		if charging then
			icon = ""
		end

		sbar.set("battery", {
			icon = icon,
			label = percentage .. "%",
		})
	end)
end)

-- Volume
local volume = sbar.add("item", "volume", {
	position = "right",
	script = "$CONFIG_DIR/plugins/volume.lua",
})

volume:subscribe("volume_change", function(env)
	local vol = tonumber(env.INFO)
	local icon = "󰖁"

	if vol >= 60 then
		icon = "󰕾"
	elseif vol >= 30 then
		icon = "󰖀"
	elseif vol >= 1 then
		icon = "󰕿"
	end

	sbar.set(env.NAME, {
		icon = icon,
		label = vol .. "%",
	})
end)

-- WiFi
local wifi = sbar.add("item", "wifi", {
	position = "right",
	update_freq = 10,
})

wifi:subscribe("routine", function()
	-- Check if WiFi is active
	sbar.exec("ifconfig en0 | grep 'status: active'", function(status)
		local icon = "󰖪 " -- Off

		if status and status ~= "" then
			-- WiFi is active, check if connected to network
			sbar.exec("ifconfig en0 | grep 'inet '", function(inet)
				if inet and inet ~= "" then
					icon = "󰖩 " -- Connected
				else
					icon = "󱚼 " -- Disconnected
				end
				sbar.set("wifi", {
					icon = icon,
					label = "",
				})
			end)
		else
			-- WiFi is off
			sbar.set("wifi", {
				icon = icon,
				label = "",
			})
		end
	end)
end)

-- Run the bar
sbar.hotload(true)
sbar.update()
