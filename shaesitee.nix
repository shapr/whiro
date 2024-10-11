{ fetchFromGitHub}:
let
  src = fetchFromGitHub {
    owner = "shapr";
    repo = "hakyll-nix-something";
    rev = "3a427c26e10528e71bb810e2e41a56a9b33cfcfb";
    sha256 = "0x5aw0d0wj9chlxxnjwn0jj2n4fv025ikfvpwjvx9b9fwch35jlc";
    # date = "2024-04-30T15:48:28-04:00";
 };
  wrappedFlake = import "${src}";
in
wrappedFlake.outputs.packages.x86_64-linux.website
