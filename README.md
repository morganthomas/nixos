My NixOS configuration.

Steps for creating a NixOS instance in VirtualBox using this config:

* Create a VM with your desired settings.
* Add the virtual disk image file contained in the Apricorn key to the VM as a virtual hard drive. Reference it by label in configuration.nix. It does not work to add the Apricon key as a USB device. NixOS is not able to see it when it is added that way.
* Download a NixOS installer ISO image. Boot the VM into it.
* Use `fdisk` or `parted` to create a single partition in the virtual hard drive. Format it as ext4.
* Mount it on `/mnt`.
* Generate configuration, install, and reboot: 
```
# nixos-generate-config --root /mnt
# cd /mnt/etc
# mv nixos nixos-generated
# nix-shell -p git --command "git clone https://github.com/morganthomas/nixos.git"
# cp nixos-generated/hardware-configuration.nix nixos
# nano nixos/bootloader.nix
{
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "/dev/sda";
 }
 # nixos-install
 (set root password)
 # useradd morgan
 # passwd morgan
 (set morgan password)
 # usermod -G wheel morgan
 # shutdown now
 ```
