{ config, pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "fr3akazo1d";
  home.homeDirectory = "/home/fr3akazo1d";

  # This value determines the Home Manager release that your
  # configuration is compatible with.
  home.stateVersion = "23.11";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Allow unfree packages (needed for vscode, discord, etc.)
  nixpkgs.config.allowUnfree = true;

  # Packages to install
  home.packages = with pkgs; [
    # Development tools
    git
    neovim
    vscode
    
    # Terminal tools
    fish
    starship
    bat
    eza
    ripgrep
    fd
    fzf
    
    # Cybersecurity tools
    nmap
    wireshark
    burpsuite
    
    # System tools
    htop
    btop
    neofetch
    tree
    
    # Media
    mpv
    
    # Network tools
    curl
    wget
    
    # Archive tools
    unzip
    p7zip
  ];

  # Fish shell configuration
  programs.fish = {
    enable = true;
    shellInit = ''
      # Fish shell initialization
      set -g fish_greeting ""
    '';
  };

  # Starship prompt
  programs.starship = {
    enable = true;
    enableFishIntegration = true;
  };

  # Git configuration
  programs.git = {
    enable = true;
    userName = "fr3akazo1d";
    userEmail = "your-email@example.com";
    extraConfig = {
      init.defaultBranch = "main";
      push.autoSetupRemote = true;
    };
  };

  # Direnv for environment management
  programs.direnv = {
    enable = true;
    enableFishIntegration = true;
  };
}