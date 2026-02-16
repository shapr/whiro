{
    LoadModule = [ "adminlog" ];
    User.shapr = {
      Admin = true;
      Pass.password = {
        Method = "sha256";
        Hash = "17e334d9d80ad48bb99f27ebb959031ef5899fdde7997bc24b135ea25d3c8039";
        Salt = "J7PJn2XvLaboxGf;2Is!";
      };
      Network.libera = {
        Server = "chat.freenode.net +6697";
        Chan = { "#nixos" = {}; "#nixos-wiki" = {}; };
        Nick = "shapr";                             # Supply your password as an argument
        LoadModule = [ "nickserv 4dd1ctSA!!" ]; # <- to the nickserv module here.
        JoinDelay = 2; # Avoid joining channels before authenticating.
      };
    };
}
