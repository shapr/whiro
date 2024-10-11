{
  config,
  pkgs,
  lib,
  callPackage,
  ...
}: {
  imports = [
    (builtins.fetchTarball {
      # Pick a commit from the branch you are interested in
      # url = "https://gitlab.com/simple-nixos-mailserver/nixos-mailserver/-/archive/nixos-22.05/nixos-mailserver-nixos-22.05.tar.gz";
      url = "https://gitlab.com/simple-nixos-mailserver/nixos-mailserver/-/archive/nixos-24.05/nixos-mailserver-nixos-24.05.tar.gz";
      # And set its hash
      sha256 = "0clvw4622mqzk1aqw1qn6shl9pai097q62mq1ibzscnjayhp278b";
    })

  ];

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
  # this might completely kill my server, yay?
  boot = {
    loader.grub = {
      enable = true;
      device = "/dev/sda";
    };
    initrd.availableKernelModules = [ "ahci" "xhci_pci" "virtio_pci" "virtio_scsi" "sd_mod" "sr_mod" "ext4" ];
  };

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
  networking.hostName = "whiro";
  networking.domain = "scannedinavian.org";
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

  # letsencrypt plz
  security.acme = {
    acceptTerms = true;
    defaults.email = "shae.erisson+acme@gmail.com";
    certs = {
      "scannedinavian.org" = {
        # webroot = "/var/www"; # THIS WILL MAKE YOU SAD, DON'T SET THIS
        extraDomainNames = [ "www.scannedinavian.org"];
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
      "scannedinavian.org" = {

        enableACME = true;
        forceSSL = true;
        # root = "${pkgs.callPackage ./shaesitee.nix {} }/dist";

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

  mailserver = {
    enable = true;
    fqdn = "whiro.scannedinavian.org";
    domains = [ "scannedinavian.org" ]; # "scannedinavian.net" "scannedinavian.com" "erisson.org" ];

    enableSubmission = true;
    enableSubmissionSsl = true;
    enableImapSsl = true;
    enableImap = true;
    sendingFqdn = "scannedinavian.org";

    # A list of all login accounts. To create the password hashes, use
    # nix-shell -p mkpasswd --run 'mkpasswd -sm bcrypt'
    # nix run nixpkgs.apacheHttpd -c htpasswd -nbB "" "super secret password" | cut -d: -f2
    loginAccounts = {
      "shae@scannedinavian.org" = {
        hashedPasswordFile = "/etc/nixos/shae-email-hash";
        aliases = ["postmaster@scannedinavian.org"];
      };
    };

    # specify locations and copy certificates there
    certificateScheme = "manual";
    certificateFile = "/var/lib/acme/scannedinavian.com/fullchain.pem";
    keyFile = "/var/lib/acme/scannedinavian.com/key.pem";
  };
  system.stateVersion = "24.05";
}
