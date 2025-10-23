# Home Manager modules
{
  shell = import ./shell;
  development = import ./development;
  cli-tools = import ./cli-tools;
  editors = import ./editors;
  raycast = import ./raycast;
  window-manager = import ./window-manager;
  security = import ./security;
  ai = import ./ai;
  syncthing = import ./syncthing;
  thunderbird = import ./thunderbird;
  sketchybar = import ./desktop/sketchybar;
  
  version-control = import ./version-control;
  shell-prompt = import ./shell-prompt;
}
