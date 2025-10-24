#waybar
waybar -c ~/.config/mango/config.jsonc -s ~/.config/mango/style.css >/dev/null 2>&1 &
#wallpaper
#swaybg -o "*" -i "/home/franek/Pictures/Wallpapers/wallpaper-theme-converter.png" &
swaybg -o "*" -i "/home/franek/Pictures/Wallpapers/1314645.jpg" &
#notifications
#mako
#auth
#systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP &
#dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=magno &
#/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 &
#
#exec autotiling -l 2
