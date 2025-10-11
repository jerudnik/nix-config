{ inputs }:
final: prev: {
  zen-browser = inputs.zen-browser.packages.${prev.system}.twilight;
}
