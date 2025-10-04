{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.home.cli-tools;
  # Access Stylix colors for consistent theming
  inherit (config.lib.stylix) colors;
in {
  config = mkIf (cfg.enable && cfg.prompt.starship) {
    programs.starship = {
      enable = true;
      enableZshIntegration = cfg.enableShellIntegration;
      settings = {
        # Gruvbox Rainbow Preset with Stylix colors
        add_newline = false;
        
        # Rainbow format - each section has a different background color
        format = concatStrings [
          "[](bg:#${colors.base09})"
          "$os"
          "$username"
          "[](bg:#${colors.base0A} fg:#${colors.base09})"
          "$directory"
          "[](fg:#${colors.base0A} bg:#${colors.base0B})"
          "$git_branch"
          "$git_status"
          "[](fg:#${colors.base0B} bg:#${colors.base0D})"
          "$nodejs"
          "$rust"
          "$golang"
          "$python"
          "$nix_shell"
          "[](fg:#${colors.base0D} bg:#${colors.base0C})"
          "$docker_context"
          "$package"
          "[](fg:#${colors.base0C} bg:#${colors.base08})"
          "$time"
          "[](fg:#${colors.base08})"
          " "
          "$cmd_duration"
          "$jobs"
          "$battery"
          "$status"
          "$character"
        ];
        
        # OS and username section (orange background)
        os = {
          disabled = false;
          style = "bg:#${colors.base09} fg:#${colors.base00}";
          symbols = {
            Macos = "󰀵";
            Linux = "󰌽";
            Windows = "󰍲";
            Ubuntu = "󰕈";
            Debian = "󰣚";
            Arch = "󰣇";
            NixOS = "󱄅";
          };
        };
        
        username = {
          show_always = true;
          style_user = "bg:#${colors.base09} fg:#${colors.base00}";
          style_root = "bg:#${colors.base09} fg:#${colors.base00}";
          format = "[ $user ]($style)";
          disabled = false;
        };
        
        # Directory section (yellow background)
        directory = {
          style = "bg:#${colors.base0A} fg:#${colors.base00}";
          format = "[ $path ]($style)";
          truncation_length = 3;
          truncation_symbol = "…/";
          
          substitutions = {
            "Documents" = "󰈙 ";
            "Downloads" = " ";
            "Music" = " ";
            "Pictures" = " ";
            "Developer" = "󰲋 ";
            "Projects" = "󰲋 ";
            "Desktop" = "󰇄 ";
            "~" = " ";
          };
        };
        
        # Git section (green background)
        git_branch = {
          symbol = " ";
          style = "bg:#${colors.base0B} fg:#${colors.base00}";
          format = "[ $symbol $branch ]($style)";
        };
        
        git_status = {
          style = "bg:#${colors.base0B} fg:#${colors.base00}";
          format = "[$all_status$ahead_behind ]($style)";
          # Use simple symbols for clean look
          conflicted = "=";
          ahead = "⇡";
          behind = "⇣";
          diverged = "⇕";
          up_to_date = "";
          untracked = "?";
          stashed = "$";
          modified = "!";
          staged = "+";
          renamed = "»";
          deleted = "✘";
        };
        
        # Language/Runtime section (blue background)
        nodejs = {
          symbol = "";
          style = "bg:#${colors.base0D} fg:#${colors.base00}";
          format = "[ $symbol ($version) ]($style)";
          detect_files = ["package.json" ".nvmrc"];
        };
        
        rust = {
          symbol = "";
          style = "bg:#${colors.base0D} fg:#${colors.base00}";
          format = "[ $symbol ($version) ]($style)";
        };
        
        golang = {
          symbol = "";
          style = "bg:#${colors.base0D} fg:#${colors.base00}";
          format = "[ $symbol ($version) ]($style)";
        };
        
        python = {
          symbol = "";
          style = "bg:#${colors.base0D} fg:#${colors.base00}";
          format = "[ $symbol ($version) ]($style)";
        };
        
        # Nix shell (show when in nix environment)
        nix_shell = {
          disabled = false;
          symbol = "❄️ ";
          style = "bg:#${colors.base0D} fg:#${colors.base00}";
          format = "[ $symbol ]($style)";
        };
        
        # Docker and package section (cyan background)
        docker_context = {
          symbol = " ";
          style = "bg:#${colors.base0C} fg:#${colors.base00}";
          format = "[ $symbol $context ]($style)";
          only_with_files = true;
        };
        
        package = {
          symbol = "󰏗 ";
          style = "bg:#${colors.base0C} fg:#${colors.base00}";
          format = "[ $symbol $version ]($style)";
        };
        
        # Time section (red background)
        time = {
          disabled = false;
          time_format = "%R";
          style = "bg:#${colors.base08} fg:#${colors.base00}";
          format = "[ 󰅐 $time ]($style)";
        };
        
        # Right-side indicators (no background)
        cmd_duration = {
          min_time = 4000;
          style = "fg:#${colors.base04}";
          format = "took [$duration]($style) ";
        };
        
        jobs = {
          threshold = 1;
          symbol = "⚡";
          style = "fg:#${colors.base08}";
          format = "[$symbol$number]($style) ";
        };
        
        battery = {
          full_symbol = "󰂄";
          charging_symbol = "󰂄";
          discharging_symbol = "󰂃";
          unknown_symbol = "󰁽";
          empty_symbol = "󰂎";
          
          display = [
            {
              threshold = 15;
              style = "fg:#${colors.base08}";
            }
            {
              threshold = 50;
              style = "fg:#${colors.base0A}";
            }
            {
              threshold = 80;
              style = "fg:#${colors.base0B}";
            }
          ];
        };
        
        # Status (shows exit code on failure)
        status = {
          disabled = false;
          style = "fg:#${colors.base08}";
          symbol = "✘";
          format = "[$symbol$status]($style) ";
        };
        
        # Prompt character
        character = {
          success_symbol = "[❯](bold fg:#${colors.base0B})";
          error_symbol = "[❯](bold fg:#${colors.base08})";
          vicmd_symbol = "[❮](bold fg:#${colors.base0A})";
        };
        
        # Additional language support (hidden by default, shows when detected)
        c = {
          symbol = " ";
          style = "bg:#${colors.base0D} fg:#${colors.base00}";
          format = "[ $symbol ($version(-$name)) ]($style)";
        };
        
        java = {
          symbol = " ";
          style = "bg:#${colors.base0D} fg:#${colors.base00}";
          format = "[ $symbol ($version) ]($style)";
        };
        
        kotlin = {
          symbol = "";
          style = "bg:#${colors.base0D} fg:#${colors.base00}";
          format = "[ $symbol ($version) ]($style)";
        };
        
        haskell = {
          symbol = "";
          style = "bg:#${colors.base0D} fg:#${colors.base00}";
          format = "[ $symbol ($version) ]($style)";
        };
        
        lua = {
          symbol = "";
          style = "bg:#${colors.base0D} fg:#${colors.base00}";
          format = "[ $symbol ($version) ]($style)";
        };
        
        ruby = {
          symbol = "";
          style = "bg:#${colors.base0D} fg:#${colors.base00}";
          format = "[ $symbol ($version) ]($style)";
        };
        
        # SSH hostname indicator
        hostname = {
          ssh_only = true;
          ssh_symbol = "🌐";
          format = "[$ssh_symbol$hostname]($style) ";
          style = "fg:#${colors.base0E}";
        };
        
        # Memory usage (shows when high)
        memory_usage = {
          disabled = false;
          threshold = 75;
          symbol = "󰍛";
          style = "fg:#${colors.base08}";
          format = "$symbol [$ram( | $swap)]($style) ";
        };
      };
    };
  };
}
