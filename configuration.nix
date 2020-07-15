# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, options, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./bootloader.nix
      ./hostname.nix
    ];

  nixpkgs.config.allowUnfree = true;

  networking.networkmanager.enable = true;

  # Select internationalisation properties.
  # i18n = {
  #   consoleFont = "Lat2-Terminus16";
  #   consoleKeyMap = "us";
  #   defaultLocale = "en_US.UTF-8";
  # };

  # Set your time zone.
  time.timeZone = "America/Denver";

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    wget chromium git tmate python wdiff psmisc zip nix-prefetch-git vim
    (import ./emacs.nix { inherit pkgs; }) texlive.combined.scheme-basic
    gnumake gcc binutils-unwrapped
    gnupg dos2unix nix-serve usbutils xmobar htop fd tilix dmenu networkmanager
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.bash.enableCompletion = true;
  # programs.mtr.enable = true;
  # programs.gnupg.agent = { enable = true; enableSSHSupport = true; };

  programs.ssh.startAgent = true;
  programs.dconf.enable = true;

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  sound.enable = true;
  # hardware.pulseaudio.enable = true;

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.layout = "us,us";
  services.xserver.xkbVariant = ",dvorak";
  services.xserver.windowManager.xmonad = {
    enable = true;
    enableContribAndExtras = true;
  };
  services.xserver.xkbOptions = "ctrl:swapcaps,grp:ctrl_shift_toggle";
  services.xserver.videoDrivers = [ "intel" ];
  # services.xserver.xkbOptions = "eurosign:e";

  # Enable touchpad support.
  # services.xserver.libinput.enable = true;

  services.locate.enable = true;

  # Enable the KDE Desktop Environment.
  # services.xserver.displayManager.sddm.enable = true;
  # services.xserver.desktopManager.plasma5.enable = true;
  # Define a user account. Don't forget to set a password with ‘passwd’.
  # users.extraUsers.guest = {
  #   isNormalUser = true;
  #   uid = 1000;
  # };

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "20.03"; # Did you read the comment?
  system.autoUpgrade.enable = true;

  fileSystems = {
    "/home/morgan/media/SECURE_KEY_VIRT" = {
      device = "/dev/disk/by-label/kassir";
      fsType = "ext4";
      options = [ "noauto" ];
    };
    "/home/morgan/media/SECURE_KEY" = {
      device = "/dev/disk/by-uuid/C470-4BC9";
      fsType = "vfat";
      options = [ "noauto" ];
    };
  };
  
  systemd.automounts = [
    { where = "/home/morgan/media/SECURE_KEY";
     wantedBy = [ "default.target" ]; }
    { where = "/home/morgan/media/SECURE_KEY_VIRT";
      wantedBy = [ "default.target" ]; }
  ];
  
  swapDevices = [{ device = "/swapfile"; }];

  networking.timeServers = options.networking.timeServers.default;
  
  nix.binaryCaches = [ "https://nixcache.reflex-frp.org" "https://cache.nixos.org" "https://shpadoinkle.cachix.org" ];
  nix.binaryCachePublicKeys = [ "ryantrinkle.com-1:JJiAKaRv9mWgpVAz8dwewnZe0AzzEAzPkagE9SP5NWI=" "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=" "shpadoinkle.cachix.org-1:aRltE7Yto3ArhZyVjsyqWh1hmcCf27pYSmO1dPaadZ8=" ];

  services.postgresql = {
    enable = true;
    package = pkgs.postgresql96;
    authentication = pkgs.lib.mkForce ''
    local all all trust
    host  all all 127.0.0.1/32 trust
    host  all all ::1/128      trust
    host  all all 0.0.0.0/0    trust
    '';
  };
}
