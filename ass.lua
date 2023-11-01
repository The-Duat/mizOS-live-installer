#!/bin/lua

-- Timezone selection
os.execute("clear")
print("[ Timezone selection ]")

local REGION = ""
while true do
  print("\n\nPlease select your timezone region:\n")
  os.execute("ls /usr/share/zoneinfo")
  local handle = io.popen("ls /usr/share/zoneinfo")
  REGION = io.read()
  handle:close()
  print("Selected region: " .. REGION)
  local mode, _, _, _ = io.popen("stat -c %F /usr/share/zoneinfo/" .. REGION):read("*a")
  if mode and mode:match("directory") then
    break
  end
end


local CITY = ""
while true do
  print("\n\nPlease select your corresponding city:\n")
  os.execute("ls /usr/share/zoneinfo/" .. REGION)
  local handle = io.popen("ls /usr/share/zoneinfo/" .. REGION)
  CITY = io.read()
  handle:close()
  print("Selected city: " .. CITY)
  if io.open("/usr/share/zoneinfo/" .. REGION .. "/" .. CITY) then
    break
  end
end

print("\nSetting timezone to " .. REGION .. "/" .. CITY)
os.execute("ln -sf /usr/share/zoneinfo/" .. REGION .. "/" .. CITY .. " /etc/localtime")
print("Generating /etc/adjtime")
os.execute("hwclock --systohc")

-- Locales
os.execute("clear")
print("[ Locales ]")
print("\nCompiling software.")
os.execute("gcc localeset.c")
print("\nSetting en_US.UTF-8 UTF")
os.execute("chmod +x a.out")
os.execute("./a.out locale")
print("\nGenerating locales.")
os.execute("locale-gen")
print("\nSetting /etc/locale.conf")
local locale_conf_file = io.open("/etc/locale.conf", "w")
locale_conf_file:write("LANG=en_US.UTF-8\n")
locale_conf_file:close()

-- System info
os.execute("clear")
print("[ System info ]")
io.write("\n\nPlease enter a hostname: ")
local HOSTNAME
while true do
  HOSTNAME = io.read()
  io.write("\n Is \"" .. HOSTNAME .. "\" your desired hostname? (y/n)\n\n> ")
  local ans = io.read()
  if ans == "y" then
    break
  end
end

print("\n\nPlease enter the password to use for the Root account.")
os.execute("passwd")
print("\n\nPlease enter a username for the normal non-root user.")
print("This user will be a sudoer. You can create more users after installation.")
local USERNAME
while true do
  io.write("\n\n> ")
  USERNAME = io.read()
  io.write("\nSelect \"" .. USERNAME .. "\" as your username? (y/n)\n\n> ")
  local ans = io.read()
  if ans == "y" then
    break
  end
end
os.execute("useradd " .. USERNAME)
print("\n\nCreate a password for the newly added user.\n\n")
os.execute("passwd " .. USERNAME)
print("\nAdding user to group \"wheel\".")
os.execute("usermod -aG " .. USERNAME .. " wheel")
print("\nGranting sudo permission to group \"wheel\".")

-- Bootloader
os.execute("clear")
print("[ Bootloader ]")
print("\nInstalling GRUB bootloader.\n")
os.execute("grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB")

-- Graphics Drivers
os.execute("clear")
print("[ Graphics Drivers ]")
while true do
  print("\nPlease select which graphics drivers to install:")
  print("   1. (AMD)     Radeon")
  print("   2. (AMD)     AMDVLK")
  print("   3. (Intel)   Intel")
  print("   4. (Nvidia)  Nvidia Proprietary")
  print("   5. (Nvidia)  Nvidia Nouveau")
  print("   6. (VM)      QXL")
  io.write("\n> ")
  local driver = io.read()

  if driver == "1" then
    os.execute("pacman -S mesa lib32-mesa xf86-video-amdgpu vulkan-radeon lib32-vulkan-radeon libva-mesa-driver lib32-libva-mesa-driver mesa-vdpau lib32-mesa-vdpau")
    break
  elseif driver == "2" then
    os.execute("pacman -S mesa lib32-mesa xf86-video-amdgpu amdvlk lib32-amdvlk libva-mesa-driver lib32-libva-mesa-driver mesa-vdpau lib32-mesa-vdpau")
    break
  elseif driver == "3" then
    os.execute("pacman -S mesa lib32-mesa xf86-video-intel vulkan-intel lib32-vulkan-intel")
    break
  elseif driver == "4" then
    os.execute("pacman -S nvidia lib32-nvidia-utils")
    break
  elseif driver == "5" then
    os.execute("pacman -S mesa lib32-mesa xf86-video-nouveau")
    break
  elseif driver == "6" then
    os.execute("pacman -S mesa xf86-video-qxl")
    break
  end
end

-- mizOS system overwrite
os.execute("clear")
print("[ mizOS System Overwrite ]")
print("\nA base Arch Linux system has been installed.")
print("\nIn order to overwrite Arch Linux with mizOS, you need to sign into the non-root user you have created (" .. USERNAME .. ").")
print("\nPlease enter the password for " .. USERNAME)
os.execute("su " .. USERNAME .. " -c \"cd ~ && mkdir installer && cd installer && git clone https://github.com/the-duat/mizos && cd mizos && sudo chmod +x install && ./install\"")

