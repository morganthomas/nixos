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
      # ./kernel.nix
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
  time.timeZone = "America/New_York";

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    wget chromium git tmate wdiff psmisc zip nix-prefetch-git vim
    gnumake gcc binutils-unwrapped ncurses5 zlib.dev scrot
    gnupg dos2unix nix-serve usbutils xmobar bpytop fd tilix dmenu networkmanager
    mkpasswd zip unzip openfortivpn i7z nginx iftop ardour ffmpeg jq
    youtube-dl vlc awscli ghc patchelf stack vscode pavucontrol htop
    haskell.compiler.ghc865 gimp nodejs signal-desktop haskellPackages.haskell-language-server
    wavemon cdparanoia cdrdao bind google-chrome phantomjs2 libreoffice adoptopenjdk-bin
  ];

  services.ntp.enable = true;
  virtualisation.virtualbox.host.enable = true;
  users.extraGroups.vboxusers.members = [ "morgan" ];

  hardware.pulseaudio = {
    enable = true;
    package = pkgs.pulseaudioFull;
    zeroconf.discovery.enable = true;
  };
  services.printing.enable = true;
  services.printing.drivers = [ pkgs.gutenprint pkgs.brlaser ];
  services.mongodb.enable = true;
  virtualisation.docker.enable = true;

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
  services.xserver.wacom.enable = true;
  services.xserver.windowManager.xmonad = {
    enable = true;
    enableContribAndExtras = true;
  };
  services.xserver.xkbOptions = "ctrl:swapcaps,grp:ctrl_shift_toggle";
  services.xserver.videoDrivers = [ "intel" ];
  # services.xserver.xkbOptions = "eurosign:e";

  systemd.services.mute = with pkgs; {
    serviceConfig.type = "oneshot";
    script = ''
      ${alsaUtils}/bin/amixer sset Master mute
    '';
  };

  systemd.services.unmute = with pkgs; {
    serviceConfig.type = "oneshot";
    script = ''
      ${alsaUtils}/bin/amixer sset Master unmute
    '';
  };

  systemd.timers.mute = {
    wantedBy = [ "timers.target" ];
    partOf = [ "mute.service" ];
    timerConfig.OnCalendar = "*-*-* 00:00:00";
    timerConfig.Persistent = true;
  };

  systemd.timers.unmute = {
    wantedBy = [ "timers.target" ];
    partOf = [ "unmute.service" ];
    timerConfig.OnCalendar = "*-*-* 09:00:00";
    timerConfig.Persistent = true;
  };

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
  system.stateVersion = "20.09"; # Did you read the comment?
  system.autoUpgrade.enable = true;

  fileSystems = {
    "/home/morgan/media/SECURE_KEY" = {
      device = "/dev/disk/by-uuid/C470-4BC9";
      fsType = "vfat";
      options = [ "noauto" ];
    };
  };
  
  systemd.automounts = [
    { where = "/home/morgan/media/SECURE_KEY";
     wantedBy = [ "default.target" ]; }
  ];
  
  swapDevices = [{ device = "/swapfile"; }];

  networking.timeServers = options.networking.timeServers.default;
  
  nix.binaryCaches = [ "https://nixcache.reflex-frp.org" "https://cache.nixos.org" "https://shpadoinkle.cachix.org" ];
  nix.binaryCachePublicKeys = [ "ryantrinkle.com-1:JJiAKaRv9mWgpVAz8dwewnZe0AzzEAzPkagE9SP5NWI=" "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=" "shpadoinkle.cachix.org-1:aRltE7Yto3ArhZyVjsyqWh1hmcCf27pYSmO1dPaadZ8=" ];

  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_12;
    authentication = pkgs.lib.mkForce ''
    local all all trust
    host  all all 127.0.0.1/32 trust
    host  all all ::1/128      trust
    host  all all 0.0.0.0/0    trust
    '';
  };
}
