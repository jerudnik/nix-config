{ config, lib, showLanguages }:

let
  # Access Stylix colors for consistent theming
  inherit (config.lib.stylix) colors;
  
  # Helper function to check if a language should be shown
  shouldShow = lang: builtins.elem lang showLanguages;
  
  # Base language style for theme consistency
  baseLanguageStyle = "bg:#${colors.base0D} fg:#${colors.base00}";
in {
  # Primary languages (blue background)
  nodejs = lib.mkIf (shouldShow "nodejs") {
    symbol = "";
    style = baseLanguageStyle;
    format = "[ $symbol ($version) ]($style)";
    detect_files = ["package.json" ".nvmrc"];
  };
  
  rust = lib.mkIf (shouldShow "rust") {
    symbol = "";
    style = baseLanguageStyle;
    format = "[ $symbol ($version) ]($style)";
  };
  
  golang = lib.mkIf (shouldShow "golang") {
    symbol = "";
    style = baseLanguageStyle;
    format = "[ $symbol ($version) ]($style)";
  };
  
  python = lib.mkIf (shouldShow "python") {
    symbol = "";
    style = baseLanguageStyle;
    format = "[ $symbol ($version) ]($style)";
  };
  
  # Nix shell (show when in nix environment)
  nix_shell = lib.mkIf (shouldShow "nix_shell") {
    disabled = false;
    symbol = "❄️ ";
    style = baseLanguageStyle;
    format = "[ $symbol ]($style)";
  };
  
  # Additional languages (shown when detected and enabled)
  c = lib.mkIf (shouldShow "c") {
    symbol = " ";
    style = baseLanguageStyle;
    format = "[ $symbol ($version(-$name)) ]($style)";
  };
  
  java = lib.mkIf (shouldShow "java") {
    symbol = " ";
    style = baseLanguageStyle;
    format = "[ $symbol ($version) ]($style)";
  };
  
  kotlin = lib.mkIf (shouldShow "kotlin") {
    symbol = "";
    style = baseLanguageStyle;
    format = "[ $symbol ($version) ]($style)";
  };
  
  haskell = lib.mkIf (shouldShow "haskell") {
    symbol = "";
    style = baseLanguageStyle;
    format = "[ $symbol ($version) ]($style)";
  };
  
  lua = lib.mkIf (shouldShow "lua") {
    symbol = "";
    style = baseLanguageStyle;
    format = "[ $symbol ($version) ]($style)";
  };
  
  ruby = lib.mkIf (shouldShow "ruby") {
    symbol = "";
    style = baseLanguageStyle;
    format = "[ $symbol ($version) ]($style)";
  };
  
  # Web technologies
  php = lib.mkIf (shouldShow "php") {
    symbol = "";
    style = baseLanguageStyle;
    format = "[ $symbol ($version) ]($style)";
  };
  
  # System languages
  zig = lib.mkIf (shouldShow "zig") {
    symbol = "";
    style = baseLanguageStyle;
    format = "[ $symbol ($version) ]($style)";
  };
}