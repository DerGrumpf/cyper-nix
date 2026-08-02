{ config, primaryUser, ... }:
let
  allBuildMachines = [
    {
      hostName = "10.10.0.2"; # cyper-controller
      sshUser = primaryUser;
      sshKey = "/home/${primaryUser}/.ssh/ssh";
      systems = [ "x86_64-linux" ];
      maxJobs = 4;
      speedFactor = 1;
      supportedFeatures = [ "big-parallel" ];
      mandatoryFeatures = [ ];
    }
    {
      hostName = "10.10.0.40"; # cyper-desktop
      sshUser = primaryUser;
      sshKey = "/home/${primaryUser}/.ssh/ssh";
      systems = [ "x86_64-linux" ];
      maxJobs = 8;
      speedFactor = 1;
      supportedFeatures = [ "big-parallel" ];
      mandatoryFeatures = [ ];
    }
    {
      hostName = "10.10.0.30"; # cyper-node-1
      sshUser = primaryUser;
      sshKey = "/home/${primaryUser}/.ssh/ssh";
      systems = [ "x86_64-linux" ];
      maxJobs = 4;
      speedFactor = 1;
      supportedFeatures = [ "big-parallel" ];
      mandatoryFeatures = [ ];
    }
    {
      hostName = "10.10.0.31"; # cyper-node-2
      sshUser = primaryUser;
      sshKey = "/home/${primaryUser}/.ssh/ssh";
      systems = [ "x86_64-linux" ];
      maxJobs = 4;
      speedFactor = 1;
      supportedFeatures = [ "big-parallel" ];
      mandatoryFeatures = [ ];
    }
    {
      hostName = "10.10.0.35"; # cyper-pi-1
      sshUser = primaryUser;
      sshKey = "/home/${primaryUser}/.ssh/ssh";
      systems = [ "aarch64-linux" ];
      maxJobs = 4;
      speedFactor = 1;
      supportedFeatures = [ "big-parallel" ];
      mandatoryFeatures = [ ];
    }
    {
      hostName = "10.10.0.1"; # cyper-proxy
      sshUser = primaryUser;
      sshKey = "/home/${primaryUser}/.ssh/ssh";
      systems = [ "x86_64-linux" ];
      maxJobs = 2;
      speedFactor = 1;
      supportedFeatures = [ "big-parallel" ];
      mandatoryFeatures = [ ];
    }
  ];
in
{
  nix = {
    buildMachines = builtins.filter (m: m.hostName != config.wgIP or null) allBuildMachines;
    distributedBuilds = true;
  };
}
