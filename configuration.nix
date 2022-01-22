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
      ./kernel.nix
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
    gnupg dos2unix xmobar fd tilix dmenu networkmanager
    mkpasswd zip unzip i7z jq htop discord xscreensaver
    inkscape nodejs-12_x python39 vlc doctl kubectl lsof stack
  ];

  #services.ntp.enable = true;
  programs.dconf.enable = true;
  users.extraGroups.vboxusers.members = [ "morgan" ];

  networking.extraHosts =
    ''
      193.16.42.17 morgan-compute
      139.59.185.31 dana-circulating-supply
    '';

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.bash.enableCompletion = true;
  # programs.mtr.enable = true;
  # programs.gnupg.agent = { enable = true; enableSSHSupport = true; };

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
  # sound.enable = true;
  hardware.pulseaudio.enable = true;

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.windowManager.xmonad = {
    enable = true;
    enableContribAndExtras = true;
  };
  services.xserver.xkbOptions = "ctrl:swapcaps";
  # services.xserver.xkbOptions = "eurosign:e";
  # Enable touchpad support.
  # services.xserver.libinput.enable = true;

  services.locate.enable = true;
  services.tailscale.enable = true;

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
 
  swapDevices = [{ device = "/swapfile"; }];

  networking.timeServers = options.networking.timeServers.default;
  
  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_13;
    authentication = pkgs.lib.mkForce ''
    local all all trust
    host  all all 127.0.0.1/32 trust
    host  all all ::1/128      trust
    host  all all 0.0.0.0/0    trust
    '';
  };

  virtualisation.docker.enable = true;

  nix = {
    package = pkgs.nixUnstable;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
    binaryCachePublicKeys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "ryantrinkle.com-1:JJiAKaRv9mWgpVAz8dwewnZe0AzzEAzPkagE9SP5NWI="
      "shpadoinkle.cachix.org-1:aRltE7Yto3ArhZyVjsyqWh1hmcCf27pYSmO1dPaadZ8="
      "hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ="
      "ci.ardana.platonic.systems:yByqhxfJ9KIUOyiCe3FYhV7GMysJSA3i5JRvgPuySsI="
      "iohk.cachix.org-1:DpRUyj7h7V830dp/i6Nti+NEO2/nhblbov/8MW7Rqoo="
    ];
    binaryCaches = [
      "https://cache.nixos.org"
      "https://nixcache.reflex-frp.org"
      "https://shpadoinkle.cachix.org"
      "https://hydra.iohk.io" 
      "ssh://nix-ssh@ci.ardana.platonic.systems?ssh-key=/home/morgan/.ssh/id_ed25519"
    ];
  };
}
