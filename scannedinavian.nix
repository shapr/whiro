{ fetchFromGitHub}:
let
  src = fetchFromGitHub {
    owner = "shapr";
    repo = "scannedinavian";
    rev = "16f8fe4334ed2ca6f7e6256702af7c4b7d9ddd9b";
    sha256 = "16i499b3imnxp28q6jc6zwsrligirbnc3xm02z6lql1309ajwc49";
    # date = "2024-10-14T18:39:16-04:00";
 };
  wrappedFlake = import "${src}";
in
wrappedFlake.outputs.packages.x86_64-linux.website
