# This is your system's configuration file.
# Use this to configure your system environment (it replaces /etc/nixos/configuration.nix)

{ inputs, outputs, lib, config, pkgs, ... }: {
  # You can import other NixOS modules here
  imports = [
    # If you want to use modules your own flake exports (from modules/nixos):
    # outputs.nixosModules.example

    # Or modules from other flakes (such as nixos-hardware):
    # inputs.hardware.nixosModules.common-cpu-amd
    # inputs.hardware.nixosModules.common-ssd

    # You can also split up your configuration and import pieces of it here:
    # ./users.nix

    # Import your generated (nixos-generate-config) hardware configuration
    ./hardware-configuration.nix
    
  ];

  nixpkgs = {
    # You can add overlays here
    overlays = [
      # If you want to use overlays your own flake exports (from overlays dir):
      # outputs.overlays.modifications
      # outputs.overlays.additions

      # Or overlays exported from other flakes:
      # neovim-nightly-overlay.overlays.default

      # Or define it inline, for example:
      # (final: prev: {
      #   hi = final.hello.overrideAttrs (oldAttrs: {
      #     patches = [ ./change-hello-to-hi.patch ];
      #   });
      # })
    ];
    # Configure your nixpkgs instance
    config = {
      # Disable if you don't want unfree packages
      allowUnfree = true;
    };
  };

  nix = {
    # This will add each flake input as a registry
    # To make nix3 commands consistent with your flake
    registry = lib.mapAttrs (_: value: { flake = value; }) inputs;

    # This will additionally add your inputs to the system's legacy channels
    # Making legacy nix commands consistent as well, awesome!
    nixPath = lib.mapAttrsToList (key: value: "${key}=${value.to.path}") config.nix.registry;

    settings = {
      # Enable flakes and new 'nix' command
      experimental-features = "nix-command flakes";
      # Deduplicate and optimize nix store
      auto-optimise-store = true;
    };
  };

  time.timeZone = "Australia/Melbourne";
  
  i18n.defaultLocale = "en_AU.UTF-8"; console = {
    font = "Lat2-Terminus16"; keyMap = "us";
  };
  
  sound.enable = true; hardware.pulseaudio.enable = true;
  
  # Increase size of tmp
  services.logind.extraConfig = ''
    RuntimeDirectorySize=8G
    RuntimeDirectoryInodesMax=1048576
  '';
  
  environment.systemPackages = with pkgs; [
    nano
    wget
    git
    mesa
    libusb
    xxd
  ];
    
  environment.sessionVariables = rec {
      PAN_MESA_DEBUG="gl3";
  };

  # Set your hostname
  networking.hostName = "supertoad";

  # Set bootloader
  boot.loader.systemd-boot.enable = true;

  # Configure your system-wide user settings (groups, etc), add more users as needed.
  users.users = {
    andy = {
      initialPassword = "password";
      isNormalUser = true;
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJlEFeVw4aOhY+UUPQqkWQ509M36lQMaI4Qjyvr7Qcao andrew.dobrich@protonmail.com"
      ];
      # Add user to groups
      extraGroups = [
        "wheel"
        "video"
        "audio"
        "docker"
      ];
    };
  };

  # This setups a SSH server. Very important if you're setting up a headless system.
  # Feel free to remove if you don't need it.
  services.openssh = {
    enable = true;
    # Forbid root login through SSH.
    permitRootLogin = "no";
    # Use keys only. Remove if you want to SSH using password (not recommended)
    passwordAuthentication = false;
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "22.05";
}
