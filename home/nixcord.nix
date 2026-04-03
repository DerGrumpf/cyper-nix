{ lib, inputs, ... }:
{
  imports = [
    inputs.nixcord.homeModules.nixcord
  ];

  programs.nixcord = {
    enable = true;
    discord = lib.mkForce { enable = false; };
    vesktop.enable = true;

    config = {
      useQuickCss = true;
      themeLinks = [
        "https://raw.githubusercontent.com/catppuccin/discord/refs/heads/main/themes/mocha.theme.css"
      ];
      frameless = true;
      plugins = {
        betterFolders.enable = true;
        betterRoleContext.enable = true;
        mentionAvatars.enable = true;
        #        copyUserURLs.enable = true;
        fakeNitro.enable = true;
        decor.enable = true;
        accountPanelServerProfile.enable = true;
        copyFileContents.enable = true;
        fakeProfileThemes.enable = true;
        friendsSince.enable = true;
        implicitRelationships.enable = true;
        #        noTrack.enable = true;
        permissionsViewer.enable = true;
        serverInfo.enable = true;
        translate.enable = true;
      };
    };
  };
}
