{ fetchFromGitHub}:
let
  src = fetchFromGitHub {
    owner = "shapr";
    repo = "scannedinavian";
    rev = "41fca3a5ae1a1872436672ac755133e24018336e";
    sha256 = "1nnpm0vc4ymns8fcqnjc50by8lscmlzk5akv8pr1zgkfa0l4byz6";
    # date = "2024-10-14T18:16:50-04:00";
 };
  wrappedFlake = import "${src}";
in
wrappedFlake.outputs.packages.x86_64-linux.website
