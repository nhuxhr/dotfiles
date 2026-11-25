hl.bind("CTRL+SUPER+ALT+Slash", hl.dsp.exec_cmd("xdg-open ~/.config/hypr/custom/keybinds.lua"), { description = "Edit user keybinds" })

-- Vim-style workspace focus (mirrors CTRL+SUPER[+ALT] + Left/Right)
for _, k in ipairs({ { "K", "-", "left" }, { "J", "+", "right" }, { "H", "-", "left" }, { "L", "+", "right" } }) do
    local key, dir, desc = k[1], k[2], k[3]
    hl.bind("CTRL + SUPER + " .. key, hl.dsp.focus({ workspace = "r" .. dir .. "1" }), { description = "Workspace: Focus " .. desc })
    hl.bind("CTRL + SUPER + ALT + " .. key, hl.dsp.focus({ workspace = "m" .. dir .. "1" }))
end

-- Extra VM submap toggle: SUPER+ALT+V (alongside upstream SUPER+ALT+F1)
hl.bind("SUPER + ALT + V", function()
    local currentsubmap = hl.get_current_submap()
    if currentsubmap == "virtual-machine" then
        hl.dispatch(hl.dsp.exec_cmd("notify-send 'Exited Virtual Machine submap' 'Keybinds re-enabled' -a 'Hyprland'"))
        hl.dispatch(hl.dsp.submap("reset"))
    elseif currentsubmap == "" then
        hl.dispatch(hl.dsp.exec_cmd("notify-send 'Entered Virtual Machine submap' 'Keybinds disabled. hit SUPER+ALT+V to escape' -a 'Hyprland'"))
        hl.dispatch(hl.dsp.submap("virtual-machine"))
    end
end, { submap_universal = true })
