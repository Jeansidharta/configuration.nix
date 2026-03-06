{
  jq,
  coreutils,
  curl,
  iproute2,
  gawk,
  writeShellApplication,
}:

writeShellApplication {
  name = "netlify-ddns";
  runtimeInputs = [
    iproute2
    jq
    curl
    gawk
    coreutils
  ];
  text = (builtins.readFile ./netlify-ddns.sh);
}
