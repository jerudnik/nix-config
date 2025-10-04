# SketchyBar theme integration with Stylix
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.darwin.sketchybar;
  theme = config.lib.stylix.colors.withHashtag;
  # Colors without hash for SketchyBar formatting
  colors = config.lib.stylix.colors;
in {
  config = mkIf (cfg.enable && config.stylix.enable) {
    # Override SketchyBar configuration with Stylix colors
    environment.etc."sketchybar/colors.sh".text = ''
      #!/bin/bash
      
      # Stylix generated colors for SketchyBar
      # Base16 color scheme: ${config.lib.stylix.colors.scheme-name}
      
      # Colors from your current theme
      export BLACK=${theme.base00}
      export WHITE=${theme.base05}
      export RED=${theme.base08}
      export GREEN=${theme.base0B}
      export BLUE=${theme.base0D}
      export YELLOW=${theme.base0A}
      export ORANGE=${theme.base09}
      export MAGENTA=${theme.base0E}
      export GREY=${theme.base03}
      export TRANSPARENT=0x00000000
      
        # Bar colors (with alpha channel for SketchyBar)
        export BAR_COLOR=0xaa${colors.base00}
        export ITEM_BG_COLOR=0xff${colors.base01}
        export ACCENT_COLOR=0xff${colors.base0D}
        export TEXT_COLOR=0xff${colors.base05}
        export ICON_COLOR=0xff${colors.base0C}
        export POPUP_BACKGROUND_COLOR=0xff${colors.base00}
        export POPUP_BORDER_COLOR=0xff${colors.base03}
      
      # Note: Colors will be applied by sketchybarrc script
    '';

    # Enhanced sketchybarrc with theming
    environment.etc."sketchybar/sketchybarrc" = mkForce {
      text = ''
        #!/bin/bash
        
        # Load Stylix colors
        source /etc/sketchybar/colors.sh
        
        # This is a Stylix-themed SketchyBar configuration
        # Colors are automatically generated from your current theme
        
        # Remove all existing items
        ${cfg.package}/bin/sketchybar --remove '/.*/'
        
        # Global bar settings with theme colors
        ${cfg.package}/bin/sketchybar --bar \
          height=${toString cfg.height} \
          position=${cfg.position} \
          margin=${toString cfg.margin} \
          corner_radius=${toString cfg.cornerRadius} \
          y_offset=0 \
          color="$BAR_COLOR" \
          drawing=on \
          ${optionalString cfg.topmost "topmost=on"} \
          ${optionalString cfg.shadow "shadow=on"} \
          ${optionalString cfg.blur "blur_radius=20"}
        
        # Default item settings with theme colors and Nerd Font
        ${cfg.package}/bin/sketchybar --default \
          icon.font="FiraCode Nerd Font Mono:Regular:16.0" \
          icon.color="$ICON_COLOR" \
          label.font="SF Pro:Semibold:13.0" \
          label.color="$TEXT_COLOR" \
          background.color="$ITEM_BG_COLOR" \
          background.corner_radius=4 \
          background.height=24 \
          padding_left=5 \
          padding_right=5
        
        ${optionalString cfg.components.workspaces ''
        # AeroSpace workspace indicators with theme colors
        for i in {1..10}; do
          ${cfg.package}/bin/sketchybar --add item space.$i left \
                    --set space.$i \
                      associated_display=1 \
                      icon="$i" \
                      icon.color="$ICON_COLOR" \
                      label.color="$TEXT_COLOR" \
                      background.color="$ITEM_BG_COLOR" \
                      click_script="${pkgs.aerospace}/bin/aerospace workspace $i" \
                      script="/bin/bash /etc/sketchybar/plugins/aerospace.sh $i"
        done
        
        # Subscribe all workspace items to aerospace events
        ${cfg.package}/bin/sketchybar --add event aerospace_workspace_change
        for i in {1..10}; do
          ${cfg.package}/bin/sketchybar --subscribe space.$i aerospace_workspace_change
        done
        ''}
        
        ${optionalString cfg.components.clock ''
        # Clock with theme colors
        ${cfg.package}/bin/sketchybar --add item clock right \
                  --set clock \
                    icon=" " \
                    icon.color="$ICON_COLOR" \
                    label.color="$TEXT_COLOR" \
                    background.color="$ITEM_BG_COLOR" \
                    script="date '+%a %b %d  %I:%M %p'" \
                    update_freq=30
        ''}
        
        ${optionalString cfg.components.battery ''
        # Battery with theme colors
        ${cfg.package}/bin/sketchybar --add item battery right \
                  --set battery \
                    icon.color="$ICON_COLOR" \
                    label.color="$TEXT_COLOR" \
                    background.color="$ITEM_BG_COLOR" \
                    script="/bin/bash /etc/sketchybar/plugins/battery.sh" \
                    update_freq=120
        
        ${cfg.package}/bin/sketchybar --subscribe battery system_woke power_source_change
        ''}
        
        ${optionalString cfg.components.volume ''
        # Volume with theme colors
        ${cfg.package}/bin/sketchybar --add item volume right \
                  --set volume \
                    icon.color="$ICON_COLOR" \
                    label.color="$TEXT_COLOR" \
                    background.color="$ITEM_BG_COLOR" \
                    script="/bin/bash /etc/sketchybar/plugins/volume.sh"
        
        ${cfg.package}/bin/sketchybar --subscribe volume volume_change
        ''}
        
        ${optionalString cfg.components.wifi ''
        # WiFi with theme colors
        ${cfg.package}/bin/sketchybar --add item wifi right \
                  --set wifi \
                    icon.color="$ICON_COLOR" \
                    label.color="$TEXT_COLOR" \
                    background.color="$ITEM_BG_COLOR" \
                    script="/bin/bash /etc/sketchybar/plugins/wifi.sh" \
                    update_freq=10
        ''}
        
        ${optionalString cfg.components.systemStats ''
        # System stats with theme colors
        ${cfg.package}/bin/sketchybar --add item cpu right \
                  --set cpu \
                    icon=" " \
                    icon.color="$ICON_COLOR" \
                    label.color="$TEXT_COLOR" \
                    background.color="$ITEM_BG_COLOR" \
                    script="/bin/bash /etc/sketchybar/plugins/cpu.sh" \
                    update_freq=5
        ''}
        
        # Custom configuration
        ${cfg.extraConfig}
        
        # Force all scripts to run the first time (optional)
        ${cfg.package}/bin/sketchybar --update
      '';
    };

    # Enhanced AeroSpace plugin with theme colors
    environment.etc."sketchybar/plugins/aerospace.sh" = mkForce {
      text = ''
        #!/bin/bash
        
        # Load theme colors
        source /etc/sketchybar/colors.sh
        
        # AeroSpace workspace indicator script with theming
        WORKSPACE="$1"
        FOCUSED=$(${pkgs.aerospace}/bin/aerospace list-workspaces --focused)
        
        if [ "$WORKSPACE" = "$FOCUSED" ]; then
          # Focused workspace - use accent color
          ${cfg.package}/bin/sketchybar --set space.$WORKSPACE \
            background.drawing=on \
            background.color="$ACCENT_COLOR" \
            icon.color="$BLACK" \
            label.color="$BLACK"
        else
          # Unfocused workspace - use default colors
          ${cfg.package}/bin/sketchybar --set space.$WORKSPACE \
            background.drawing=on \
            background.color="$ITEM_BG_COLOR" \
            icon.color="$ICON_COLOR" \
            label.color="$TEXT_COLOR"
        fi
      '';
    };
    
    # Make SketchyBar scripts executable
    system.activationScripts.sketchybarScripts.text = ''
      chmod +x /etc/sketchybar/sketchybarrc
      chmod +x /etc/sketchybar/colors.sh
      chmod +x /etc/sketchybar/plugins/aerospace.sh
    '';
  };
}