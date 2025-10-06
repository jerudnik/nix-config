{ config, lib }:

{
  # Global starship settings
  add_newline = true;
  
  # Command timeout settings
  command_timeout = 500;
  
  # Enable right format for right-side modules
  right_format = "";
  
  # Base directory configuration
  directory = {
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
  
  # Base git configuration
  git_branch = {
    symbol = " ";
    truncation_length = 20;
  };
  
  git_status = {
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
  
  # Base character configuration
  character = {
    success_symbol = "[❯](bold green)";
    error_symbol = "[❯](bold red)";
    vicmd_symbol = "[❮](bold yellow)";
  };
}