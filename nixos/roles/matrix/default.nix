{
  ...
}:
{
  imports = [
    ./synapse.nix
    #./lk-jwt.nix
    ./livekit.nix
    ./clients.nix
    ./mjolnir.nix
    ./coturn.nix
    #./maubot.nix # known security risk
  ];
}
