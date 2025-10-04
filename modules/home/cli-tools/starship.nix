{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.home.cli-tools;
in {
  config = mkIf (cfg.enable && cfg.prompt.starship) {
    programs.starship = {
      enable = true;
      enableZshIntegration = cfg.enableShellIntegration;
      settings = {
        # Enhanced configuration with developer-focused features
        add_newline = false;
        
        # Custom format with more information
        format = concatStrings [
          "$os"
          "$username"
          "$hostname"
          "$directory"
          "$git_branch"
          "$git_commit"
          "$git_state"
          "$git_metrics"
          "$git_status"
          "$hg_branch"
          "$docker_context"
          "$package"
          "$c"
          "$cmake"
          "$dart"
          "$deno"
          "$dotnet"
          "$elixir"
          "$elm"
          "$erlang"
          "$golang"
          "$haskell"
          "$helm"
          "$java"
          "$julia"
          "$kotlin"
          "$lua"
          "$nim"
          "$nodejs"
          "$ocaml"
          "$perl"
          "$php"
          "$pulumi"
          "$purescript"
          "$python"
          "$rlang"
          "$red"
          "$ruby"
          "$rust"
          "$scala"
          "$swift"
          "$terraform"
          "$vlang"
          "$vagrant"
          "$zig"
          "$buf"
          "$nix_shell"
          "$conda"
          "$memory_usage"
          "$aws"
          "$gcloud"
          "$openstack"
          "$azure"
          "$env_var"
          "$crystal"
          "$custom"
          "$sudo"
          "$cmd_duration"
          "$line_break"
          "$jobs"
          "$battery"
          "$time"
          "$status"
          "$character"
        ];
        
        # OS symbol (shows macOS icon)
        os = {
          disabled = false;
          style = "bold white";
          symbols = {
            Macos = " ";
            Linux = "🐧 ";
            Windows = "🪟 ";
          };
        };
        
        # Show hostname only in SSH sessions
        hostname = {
          ssh_only = true;
          format = "[@$hostname]($style) ";
          style = "bold green";
        };
        
        # Directory with better icons and colors
        directory = {
          style = "bold cyan";
          truncation_length = 4;
          truncate_to_repo = true;
          format = "[$path]($style)[$read_only]($read_only_style) ";
          read_only = "🔒";
          read_only_style = "red";
          truncation_symbol = "…/";
          
          substitutions = {
            "Documents" = "󰈙 ";
            "Downloads" = " ";
            "Music" = " ";
            "Pictures" = " ";
            "Developer" = "󰲋 ";
            "Projects" = "󰲋 ";
            "Desktop" = "󰇄 ";
          };
        };
        
        # Git branch with better styling
        git_branch = {
          style = "bold purple";
          format = "[\\($symbol$branch\\)]($style) ";
          symbol = " ";
        };
        
        # Git status with detailed info
        git_status = {
          style = "bright-red";
          format = "([\\[$all_status$ahead_behind\\]]($style) )";
          conflicted = "⚔️ ";
          ahead = "🏎️ 💨×$count ";
          behind = "🐢×$count ";
          diverged = "🔱 🏎️ 💨×$ahead_count 🐢×$behind_count ";
          untracked = "🛤️ ×$count ";
          stashed = "📦 ";
          modified = "📝×$count ";
          staged = "🗃️ ×$count ";
          renamed = "📛×$count ";
          deleted = "🗑️ ×$count ";
        };
        
        # Show git commit when in detached HEAD
        git_commit = {
          commit_hash_length = 7;
          style = "bold yellow";
          format = "[\\($hash$tag\\)]($style) ";
        };
        
        # Git metrics (lines added/removed)
        git_metrics = {
          disabled = false;
          added_style = "bold green";
          deleted_style = "bold red";
          format = "([+$added]($added_style) )([-$deleted]($deleted_style) )";
        };
        
        # Nix shell indicator
        nix_shell = {
          disabled = false;
          impure_msg = "[impure shell](bold red)";
          pure_msg = "[pure shell](bold green)";
          format = "via [$symbol$state( \\($name\\))]($style) ";
          symbol = "❄️ ";
        };
        
        # Programming language indicators
        nodejs = {
          format = "via [⬢ $version](bold green) ";
          detect_files = ["package.json" ".nvmrc"];
        };
        
        python = {
          format = "via [🐍 $version( \\($virtualenv\\))]($style) ";
          style = "yellow bold";
        };
        
        rust = {
          format = "via [🦀 $version](red bold) ";
        };
        
        golang = {
          format = "via [🐹 $version](cyan bold) ";
        };
        
        java = {
          format = "via [☕ $version](red dimmed) ";
        };
        
        # Docker context
        docker_context = {
          format = "via [🐳 $context](blue bold) ";
          only_with_files = true;
        };
        
        # Package version (shows version from package.json, Cargo.toml, etc.)
        package = {
          disabled = false;
          format = "is [📦 $version]($style) ";
          style = "208 bold";
        };
        
        # Command duration with better formatting
        cmd_duration = {
          style = "bold yellow";
          format = "took [$duration]($style) ";
          disabled = false;
          min_time = 2000;
          show_milliseconds = false;
        };
        
        # Battery indicator (useful for laptops)
        battery = {
          full_symbol = "🔋";
          charging_symbol = "🔌";
          discharging_symbol = "⚡";
          unknown_symbol = "🔋";
          empty_symbol = "💀";
          
          display = [
            {
              threshold = 15;
              style = "bold red";
            }
            {
              threshold = 50;
              style = "bold yellow";
            }
            {
              threshold = 80;
              style = "bold green";
            }
          ];
        };
        
        # Memory usage
        memory_usage = {
          disabled = false;
          threshold = 70;
          style = "bold dimmed red";
          symbol = "🐏 ";
        };
        
        # Jobs indicator
        jobs = {
          symbol = "⚡";
          style = "bold red";
          number_threshold = 1;
          format = "[$symbol$number]($style) ";
        };
        
        # Character (prompt symbol)
        character = {
          success_symbol = "[❯](bold green)";
          error_symbol = "[❯](bold red)";
          vicmd_symbol = "[❮](bold yellow)";
        };
        
        # Time (optional, disabled by default)
        time = {
          disabled = true;
          format = "🕙[\\[ $time \\]]($style) ";
          style = "bright-white";
          utc_time_offset = "local";
        };
        
        # Status (shows exit code on failure)
        status = {
          disabled = false;
          style = "bold red";
          symbol = "💥";
          format = "[$symbol$status]($style) ";
        };
      };
    };
  };
}