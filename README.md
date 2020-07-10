My NixOS configuration.

Prerequisite for creating a NixOS instance in VirtualBox using this config:

* Create a VM with your desired settings.
* Add the virtual disk image file contained in the Apricorn key to the VM as a virtual hard drive. Reference it by label in configuration.nix. It does not work to add the Apricon key as a USB device. NixOS is not able to see it when it is added that way.

Steps for creating a NixOS instance on a VirtualBox VM or bare metal with BIOS support:

* Download a NixOS installer ISO image. Boot the machine into it.
* Use `fdisk` or `parted` to create a single partition in the virtual hard drive. Format it as ext4 using `mkfs.ext4`.
* Mount it on `/mnt`.
* Generate configuration, install, and reboot: 
```bash
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
 # nixos-enter
 # useradd morgan
 # passwd morgan
 (set morgan password)
 # usermod -G wheel morgan
 # mkdir /home/morgan
 # chown morgan:users /home/morgan
 # dd if=/dev/zero of=/swapfile bs=1G count=8
 # mkswap /swapfile
 # shutdown now
 ```
 
 After booting and logging in as Morgan, take the following steps:
 
 ```bash
 $ mkdir -p media/SECURE_KEY
 $ sudo mount media/SECURE_KEY
 $ mkdir .ssh
 $ ln -s ~/media/SECURE_KEY/platonic ~/.ssh/platonic
 $ ln -s ~/media/SECURE_KEY/platonic.pub ~/.ssh/platonic.pub
 $ ssh-add ~/.ssh/platonic
 $ git clone git@github.com:morganthomas/dotfiles.git
 ```

 It's possible to use an Apricorn key as NixOS installation medium using a command like this to write the image:
 
 ```bash
 # dd if=image.iso of=/dev/sdb bs=1024
 ```
 
 In order for a computer to boot from the Apricorn key, the key must be placed in lock override mode so that it will not lock up during the boot process.
