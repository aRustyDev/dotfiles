# User configuration for analyst (CFS)
# Volta npm package management module
{
  lib,
  pkgs,
  config,
  userConfig,     # Passed from flake.nix
  dot,           # Structured paths configuration
  ...
}: {
  home = {
    # User-specific PATH configuration
    sessionVariables = {
      VOLTA_HOME = dot.paths.volta.home;
      # PATH is managed by .zshrc
    };

    # Ensure jq is available for the script
    packages = [ pkgs.jq ];

    # Volta setup activation
    activation.setupVolta = lib.hm.dag.entryAfter ["writeBoundary"] ''
      # Run the external setup script
      ${pkgs.bash}/bin/bash ${dot.paths.scripts.activation}/setup-volta.sh \
        "${pkgs.volta}/bin/volta" \
        "${userConfig}" \
        "${dot.paths.volta.config}/default.json" \
        "${dot.paths.volta.config}/${userConfig}.json"
    '';
    
    # Helper scripts
    file = {
      # Reinstall script
      ".local/bin/volta-reinstall" = {
        executable = true;
        text = ''
          #!/usr/bin/env bash
          # Helper script to reinstall all Volta packages
          
          echo "Reinstalling all Volta-managed packages..."
          
          # Get the list of currently installed packages
          current_packages=$(volta list --format plain | grep "^package" | awk '{print $2}' | cut -d'@' -f1)
          
          # Uninstall all current packages
          for pkg in $current_packages; do
            echo "Removing $pkg..."
            volta uninstall "$pkg" 2>/dev/null || true
          done
          
          # Force home-manager to reinstall
          echo "Running home-manager switch to reinstall packages..."
          home-manager switch
        '';
      };
      
      # Show installed packages
      ".local/bin/volta-status" = {
        executable = true;
        text = ''
          #!/usr/bin/env bash
          # Show Volta installation status
          
          echo "=== Volta Status ==="
          echo "Machine: ${dot.machine.name}"
          echo "User: ${dot.machine.username}"
          echo "Volta Home: ${dot.paths.volta.home}"
          echo ""
          
          if command -v volta &> /dev/null; then
            echo "Volta version: $(volta --version)"
            echo ""
            echo "Installed tools:"
            volta list || echo "No tools installed"
          else
            echo "Volta is not installed or not in PATH"
          fi
        '';
      };
    };
  };
}