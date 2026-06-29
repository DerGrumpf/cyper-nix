{
  config,
  pkgs,
  lib,
  primaryUser,
  ...
}:
let
  vaultRepo = "ssh://gitea@git.cyperpunk.de:12222/DerGrumpf/Notes.git";
  vaultPath = "${config.home.homeDirectory}/Notes";
  sshBinary = "${pkgs.openssh}/bin/ssh";
  gitBin = "${pkgs.git}/bin";
  gitLfsBin = "${pkgs.git-lfs}/bin";
in
{
  programs.obsidian = {
    enable = true;
    vaults.notes = {
      target = "Notes";
      settings = { };
    };
  };

  home = {
    packages = with pkgs; [
      git
      git-lfs
      openssh
    ];

    persistence."/persist/home/${primaryUser}".directories = [
      "Notes"
    ];

    activation.obsidianVault = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      export PATH="${gitBin}:${gitLfsBin}:$PATH"
      export GIT_SSH_COMMAND="${sshBinary} -o StrictHostKeyChecking=accept-new"
      export GIT_LFS_SKIP_SMUDGE=1

      if [ ! -d "${vaultPath}/.git" ]; then
      		echo "Cloning Obsidian vault (LFS objects will be pulled separately)..."
      		${gitBin}/git clone "${vaultRepo}" "${vaultPath}"
      		${gitLfsBin}/git-lfs install --local "${vaultPath}"
      		${gitBin}/git -C "${vaultPath}" lfs pull
      else
      		echo "Pulling latest changes for Obsidian vault..."
      		${gitBin}/git -C "${vaultPath}" pull
      		${gitBin}/git -C "${vaultPath}" lfs pull
      fi
    '';
  };
}
