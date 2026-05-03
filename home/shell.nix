{
  pkgs,
  isDarwin,
  lib,
  ...
}:
{
  home.packages = with pkgs; [
    eza # ls replacement
    tdf # terminal pdf viewer
    jq # json parser
    fastfetch # system stats
    tabiew # Table viewer
    glow # MD Viewer
    fd # find alternative
    bat # cat alternative
    ripgrep # grep alternative
    doas # sudo alternative
    dnsutils

    # LLM in the Terminal
    (pkgs.llm.withPlugins { llm-groq = true; })

    # Fun stuff
    zoxide
    lolcat
    cmatrix
  ];

  programs.kitty = {
    enable = true;

    font = {
      name = "Fira Code Nerd Font";
      size = 10;
    };

    settings = {
      confirm_os_window_close = 0;
      dynamic_background_opacity = true; # ctrl+shift+a>m/l
      enable_audio_bell = false;
      mouse_hide_wait = 3.0;
      window_padding_width = 10;

      background_opacity = 0.8;
      background_blur = 5;

      tab_bar_min_tabs = 1;
      tab_bar_edge = "bottom";
      tab_bar_style = "custom"; # Should be changed to custom
      tab_title_template = "{fmt.fg.red}{bell_symbol}{activity_symbol}{fmt.fg.tab}{title}";

      symbol_map =
        let
          mappings = [
            "U+23FB-U+23FE"
            "U+2B58"
            "U+E200-U+E2A9"
            "U+E0A0-U+E0A3"
            "U+E0B0-U+E0BF"
            "U+E0C0-U+E0C8"
            "U+E0CC-U+E0CF"
            "U+E0D0-U+E0D2"
            "U+E0D4"
            "U+E700-U+E7C5"
            "U+F000-U+F2E0"
            "U+2665"
            "U+26A1"
            "U+F400-U+F4A8"
            "U+F67C"
            "U+E000-U+E00A"
            "U+F300-U+F313"
            "U+E5FA-U+E62B"
          ];
        in
        (builtins.concatStringsSep "," mappings) + " Symbols Nerd Font Mono";
    };
  };

  # Doenst work
  programs.iamb = {
    enable = false;
    settings = {
      default_profile = "personal";
      settings = {
        notifications.enabled = true;
        image_preview.protocol = {
          type = "kitty";
          size = {
            height = 10;
            width = 66;
          };
        };
      };
    };
  };

  programs.newsboat = {
    enable = true;
    autoReload = true;
    browser = if isDarwin then "open" else "xdg-open";
    urls = [
      {
        url = "https://www.tagesschau.de/xml/rss2";
        tags = [
          "news"
          "de"
        ];
      }
      {
        url = "https://www.spiegel.de/schlagzeilen/index.rss";
        tags = [
          "news"
          "de"
        ];
      }
      {
        url = "https://www.focus.de/rss";
        tags = [
          "news"
          "de"
        ];
      }
      {
        url = "https://feeds.feedburner.com/blogspot/rkEL";
        tags = [ "blog" ];
      }
    ];
  };

  programs.cava = lib.mkIf (!isDarwin) { enable = true; };

  programs.yazi = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    enableFishIntegration = true;

    settings = {
      ration = [
        1
        3
        4
      ];
    };
  };

  programs.fzf = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    enableFishIntegration = true;
    defaultCommand = "fd --type f --strip-cwd-prefix --hidden --exclude .git";
    fileWidgetCommand = "fd --type f --strip-cwd-prefix --hidden --exclude .git";
    defaultOptions = [
      "--height 100%"
      "--border sharp"
      "--layout=reverse"
      "--inline-info"
      "--preview 'bat --color=always --style=numbers {}'"
    ];
  };

  # TODO: Install OpenCode
  programs.nushell = {
    enable = true;

    shellAliases = {
      #      ls = "eza --icons=always";
      la = "ls -la";
      #tree = "eza --icons=always -T";
      i = "kitty +kitten icat";
      #      cat = "bat --color=always --style=numbers";
      grep = "rg";
    };

    extraConfig = ''
      $env.config = {
      show_banner: false
      }

      # Starship
      $env.STARSHIP_SHELL = "nu"
      mkdir ~/.cache/starship
      starship init nu | save -f ~/.cache/starship/init.nu

      # fzf picker for nvim
      def f [] { nvim (fzf) }

      # llm | glow
      def l [...args] { llm prompt -m groq/llama-3.3-70b-versatile -t std ...$args | glow }

      # Fastfetch on shell start
      fastfetch
    '';

    extraEnv = ''
      starship init nu | save -f ~/.cache/starship/init.nu
      use ~/.cache/starship/init.nu
    '';
  };

  programs.fish = {
    enable = true;

    shellAliases = {
      ls = "eza --icons=always";
      la = "eza -la --icons=always";
      f = "nvim $(fzf)";
      tree = "eza --icons=always -T";
      i = "kitty +kitten icat";
      bat = "bat --color=always --style=numbers";
      grep = "rg";
      cp = "rsync -ah --progress";
      nix-switch =
        if isDarwin then
          "sudo darwin-rebuild switch --flake ~/.config/nix#(hostname -s)"
        else
          "sudo nixos-rebuild switch --flake ~/.config/nix#(hostname -s)";

      nix-check =
        if isDarwin then
          "nix eval ~/.config/nix#darwinConfigurations.(hostname -s).config.system.build.toplevel.outPath"
        else
          "nix flake check --no-build ~/.config/nix";
    };

    interactiveShellInit = ''
            starship init fish | source
            fzf --fish | source
      	  zoxide init fish --cmd cd | source
            function fish_greeting
            		fastfetch
            end
    '';

    functions.l = {
      body = ''
        if test -f "$GROQ_API_KEY"
          set -x GROQ_API_KEY (cat $GROQ_API_KEY)
        end
        llm prompt -m groq/llama-3.3-70b-versatile -t std $argv | glow
      '';
    };
  };

  # Link LLM std template
  home.file.".config/io.datasette.llm/templates/std.yaml".text = ''
    system: |
      You are a concise technical assistant running on an Intel Mac (x86_64-darwin) 
      with nix-darwin and home-manager.
      
      Rules:
      - Always respond in valid markdown
      - Be concise and direct, no unnecessary explanation
      - Prefer code blocks for commands and code
      - You have access to these tools in the shell: nvim, fish, git, 
        eza, bat, ripgrep, fzf, yazi, glow, llm, zoxide, fastfetch,
        nix, darwin-rebuild, brew
      - When suggesting nix config changes, use the nix language
      - nix-switch rebuilds the system config
      - nix-check validates the flake without building
  '';

  programs.starship = {
    enable = true;
    settings = {
      add_newline = true;
      command_timeout = 500;

      format = ''
        $username$hostname $directory $git_branch$git_status
        $character '';
      right_format = "$cmd_duration";

      username = {
        style_user = "bold #cba6f7";
        style_root = "bold #f38ba8";
        format = "[┌](bold #a6e3a1)[$user]($style)";
        show_always = true;
      };

      hostname = {
        style = "bold #74c7ec";
        format = "[@](bold #fab387)[$hostname]($style)";
        ssh_only = false;
      };

      directory = {
        style = "bold #a6e3a1";
        truncation_length = 0;
        truncation_symbol = "";
        format = "[⤇ ](bold #f38ba8)[《$path 》]($style)";
      };

      git_branch = {
        format = "[⟦$branch⟧]($style)";
        style = "bold #f9e2af";
      };

      # Git status module settings
      git_status = {
        format = "[[(*$conflicted$untracked$modified$staged$renamed$deleted)](red) ($ahead_behind$stashed)]($style)";
        style = "bold #a6e3a1";
        conflicted = "";
        untracked = "";
        modified = "";
        staged = "";
        renamed = "";
        deleted = "";
      };

      # Command duration module
      cmd_duration = {
        format = "[$duration]($style)";
        style = "bold #cdd6f4";
        min_time = 5000; # Only show if command takes longer than 5 seconds
      };

      # Character module (prompt symbol)
      character = {
        success_symbol = "[└──────⇴ ](bold #a6e3a1)";
        error_symbol = "[└──────⇴ ](bold #f38ba8)";
      };

      nix_shell = {
        format = "[$symbol$state( ($name))]($style)";
        symbol = "U+02744";
        style = "bold #89dceb";
      };
    };
  };

  home.file = {
    ".config/fastfetch/config.jsonc".source = ./fastfetch.jsonc;
    ".config/tabiew/theme.toml".source = ./tabiew.toml;
    ".config/kitty/tab_bar.py".source = ./tab_bar.py;
    ".hushlogin" = lib.mkIf isDarwin { text = ""; }; # Suppress Login
  };
}
