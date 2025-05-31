{
  config,
  pkgs,
  lib,
  callPackage,
  scannedinavianblog,
  ...
}: {
  imports = [ ];

  virtualisation.vmVariant = {
    virtualisation = {
      memorySize = 2048;
      cores = 3;
      graphics = false;
    };
  };
  environment.systemPackages = with pkgs; [ htop ];
  documentation.nixos.enable = false;
  time.timeZone = "Europe/London";
  i18n.defaultLocale = "en_US.UTF-8";
  console.keyMap = "us";

  ### drive layout
  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/nixos";
      fsType = "ext4";
    };
    "/boot" = {
      device = "/dev/disk/by-label/boot";
      fsType = "ext4";
    };
  };
  swapDevices = [ { device = "/dev/disk/by-label/swap"; } ];

  ### boot setup
  boot = {
    loader.grub = {
      enable = true;
      device = "/dev/sda";
    };
    initrd.availableKernelModules = [ "ahci" "xhci_pci" "virtio_pci" "virtio_scsi" "sd_mod" "sr_mod" "ext4" ];
  };

  ### nix settings
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;
    trusted-users = [ "@wheel" ];
    substituters = [
      "https://cache.garnix.io"
      "https://cache.iog.io"
      "https://cache.nixos.org"
      "https://nix-community.cachix.org"
      "https://numtide.cachix.org"
    ];
    trusted-public-keys = [
      "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "numtide.cachix.org-1:2ps1kLBUWjxIneOy1Ik6cQjb41X0iXVXeHigGmycPPE="
    ];
  };

  ### networking
  networking.hostName = "whiro";
  networking.domain = "scannedinavian.com";
  networking.firewall.allowedTCPPorts = [
    22 # SSH
    25 # SMTP do I need this?
    80 # HTTP
    143 # IMAP with starttls
    443 # HTTPS
    465 # submission TLS
    587 # submission starttls
    993 # IMAP with TLS
    # 5000 # ZNC IRC bouncer
  ];
  ### static config for networking from https://wiki.nixos.org/wiki/Install_NixOS_on_Hetzner_Cloud#Network_configuration
  #systemd.network.enable = true;
  #systemd.network.networks

  # letsencrypt plz
  security.acme = {
    acceptTerms = true;
    defaults.email = "shae.erisson+acme@gmail.com";
    certs = {
      # "scannedinavian.org" = {
      #   # webroot = "/var/www"; # THIS WILL MAKE YOU SAD, DON'T SET THIS
      #   extraDomainNames = [ "www.scannedinavian.org"];
      # };
      "scannedinavian.com" = {
        # webroot = "/var/www"; # THIS WILL MAKE YOU SAD, DON'T SET THIS
        extraDomainNames = [ "www.scannedinavian.com"];
      };

      # once I get everything else fixed up, uncomment these
      # "scannedinavian.org" = {
      #   extraDomainNames = [ "www.scannedinavian.com"  "tattletail.scannedinavian.com"];
      # };
      # "scannedinavian.net" = {
      #   extraDomainNames = [ "www.scannedinavian.net" ];
      # };
      # "erisson.org" = {
      #   extraDomainNames = [ "www.erisson.org" ];
      # };
    };
  };
  # for testing
  # security.acme.defaults.server = "https://acme-staging-v02.api.letsencrypt.org/directory";

  services.nginx = {
    enable = true;
    logError = "stderr info";
    # adminAddr = "webmaster@scannedinavian.com"; # only in apache?
    # addSSL = true;
    recommendedTlsSettings = true;
    recommendedOptimisation = true;
    recommendedGzipSettings = true;

    virtualHosts = {
      # "scannedinavian.org" = {
      #   enableACME = true;
      #   forceSSL = true;
      #   root = "${scannedinavianblog.packages.x86_64-linux.website}/dist";
      # };
      "scannedinavian.com" = {
        enableACME = true;
        forceSSL = true;
        root = "${scannedinavianblog.packages.x86_64-linux.website}/dist";
      };
    };
  };

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "yes";
      PasswordAuthentication = false;
    };
  };

  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_17;
    extensions = [
      pkgs.postgresql17Packages.postgis
      pkgs.postgresql17Packages.pg_repack
    ];
  };

  services.fail2ban.enable = true;

  users.users.nginx.extraGroups = [ "acme" ];

  programs.zsh.enable = true;

  users.users.root.openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJYlatXccSMal4uwSogKUEfJgrJ3YsH2uSbLFfgz6Vam" ];
  users.users.shae = {
    home = "/home/shae";
    isNormalUser = true;
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJYlatXccSMal4uwSogKUEfJgrJ3YsH2uSbLFfgz6Vam" ];
  };
  users.users.mclare = {
    home = "/home/mclare";
    isNormalUser = true;
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMoT0LahveaIbPbQiaPap9pFrnxhGsvSTQjF0MNTk2WH" ];
  };
  users.users.kragen = {
    home = "/home/kragen";
    isNormalUser = true;
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKSUvv3VYruilKEUFyAYSwRBR9lCFWdkr/8oMAIH3A1u user@debian" ];
  };
  users.users.magicwormhole = {
    home = "/home/magicwormhole";
    isNormalUser = true;
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJYlatXccSMal4uwSogKUEfJgrJ3YsH2uSbLFfgz6Vam" "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP7dtwuLvsWGzoLJ3Q+Y+kbx65ca9IlIuIHQGiK76MQg meejah@mantle" ];
  };

  users.users.angel = {
    home = "/home/angel";
    isNormalUser = true;
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPXi7Qt2IyqffxZGY7JYc3kviKC8WlI6nF2JSn7zqeLD angel@brymlys
" ];

  };

  mailserver = {
    stateVersion = 1;
    enable = true;
    fqdn = "whiro.scannedinavian.com";
    domains = [ "scannedinavian.com" ]; # "scannedinavian.net" "scannedinavian.com" "erisson.org" ];

    enableSubmission = true;
    enableSubmissionSsl = true;
    enableImapSsl = true;
    enableImap = true;
    sendingFqdn = "scannedinavian.com";

    # A list of all login accounts. To create the password hashes, use
    # nix-shell -p mkpasswd --run 'mkpasswd -sm bcrypt'
    # nix run nixpkgs.apacheHttpd -c htpasswd -nbB "" "super secret password" | cut -d: -f2
    loginAccounts = {
      "shae@scannedinavian.com" = {
        hashedPassword = "$2b$05$ul8zWo9ZMid28wnK4Ma1Hego1K7SEu2ZP2ATBugtmSshhAamwma8.";
        aliases = ["postmaster@scannedinavian.com" ];
      };

      "magicwormhole@scannedinavian.com" = {
        hashedPassword = "$2b$05$FCQcLBnvLKiH.eJU.vaFKeGxgdAaLpSpts/1Eo7aR.MX92l5CoGC6";
        aliases = ["postmaster@scannedinavian.com" ];
      };

      "angel@scannedinavian.com" = {
        hashedPassword = "$2y$05$op1lhYSQcgiqvlDv6eCN7ug4AdmkwtZXwEeQTyEPeqQHnqGShA4w.";
      };

    };

    # specify locations and copy certificates there
    certificateScheme = "manual";
    certificateFile = "/var/lib/acme/scannedinavian.com/fullchain.pem";
    keyFile = "/var/lib/acme/scannedinavian.com/key.pem";
  };

  system.stateVersion = "24.05";
}
