# This is just an example, you should generate yours with nixos-generate-config and put it in here.
{ config, lib, pkgs, modulesPath, ... }:

{ 
  boot.initrd.availableKernelModules = [ ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/disk/by-label/nixos";
      fsType = "ext4";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-label/boot";
      fsType = "vfat";
    };
  
  # TODO: repurpose nvme drive for nix store
  # filesystems."/nix/store" =
  #   { device = "/dev/disk/by-label/store";
  #     fsType = "ext4";
  #   }

  swapDevices =
    [ { device = "/dev/disk/by-label/swap"; }
    ];

  # Set your system kind (needed for flakes)
  nixpkgs.hostPlatform = "aarch64-linux";
  
  # Enable DHCP on all interfaces
  networking.useDHCP = lib.mkDefault true;

  powerManagement.cpuFreqGovernor = lib.mkDefault "ondemand";
}
