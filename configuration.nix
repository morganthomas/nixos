# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, options, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./bootloader.nix
    ];

  nixpkgs.config.allowUnfree = true;

  # networking.hostName = "nixos"; # Define your hostname.
  networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.extraHosts = let
    c = import /home/morgan/kassir/infrastructure/src/common.nix;
    u = import /home/morgan/kassir/infrastructure/src/users.nix;
  in pkgs.lib.lists.foldl' (a: b: a + b) "" (
    pkgs.lib.attrsets.mapAttrsToList (n: v: "${v} ${n}\n") (
      pkgs.lib.attrsets.mapAttrs (_: v: "${c.internalNetwork}.${builtins.toString v.networkId}") u
    )
  );

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
    wget google-chrome git keepassxc tmate python wdiff psmisc zip nix-prefetch-git vim
    (import /etc/nixos/emacs.nix { inherit pkgs; }) postgresql texlive.combined.scheme-basic
    haskellPackages.ghc haskellPackages.cabal-install haskellPackages.stack gnumake gcc binutils-unwrapped
    nodejs-9_x gnupg dos2unix nix-serve easyrsa openvpn
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.bash.enableCompletion = true;
  # programs.mtr.enable = true;
  # programs.gnupg.agent = { enable = true; enableSSHSupport = true; };

  programs.ssh.startAgent = true;

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
  services.xserver.windowManager.xmonad.enable = true;
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
  system.stateVersion = "18.03"; # Did you read the comment?
  system.autoUpgrade.enable = true;


  # Postgres
  services.postgresql.enable = true;
  services.postgresql.package = pkgs.postgresql;
  services.postgresql.authentication = pkgs.lib.mkForce ''
    # Generated file; do not edit!
    # TYPE  DATABASE        USER            ADDRESS                 METHOD
    local   all             all                                     trust
    host    all             all             127.0.0.1/32            trust
    host    all             all             ::1/128                 trust
    '';

  services.openvpn.servers.kassir = {
    autoStart = false;
    config = ''
      client
      dev tun
      proto tcp
      remote vpn.kassir.io 1194
      resolv-retry infinite
      nobind
      persist-key
      persist-tun
      ca /home/morgan/mnt/kassir-outer/vpn/ca.crt
      cert /home/morgan/mnt/kassir-outer/vpn/morgan.crt
      key /home/morgan/mnt/kassir-outer/vpn/morgan.key
      remote-cert-tls server
      tls-auth /home/morgan/mnt/kassir-outer/vpn/ta.key 1
      cipher AES-256-CBC
      verb 6
      pull
    '';
  };

  fileSystems = {
    "/home/morgan/mnt/kassir" = {
      device = "/dev/disk/by-label/kassir-2";
      fsType = "ext4";
      options = [ "noauto" ];
    };
    "/home/morgan/mnt/kassir-outer" = {
      device = "/dev/disk/by-label/SECURE_KEY_";
      fsType = "vfat";
      options = [ "noauto" "x-systemd.automount" ];
    };
  };

  networking.timeServers = options.networking.timeServers.default;

  nix.trustedBinaryCaches = [ "https://cache.kassir.io/" ];
}
