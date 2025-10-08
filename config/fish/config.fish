status is-interactive; and begin

    # Aliases
    alias free 'free -h'
    alias ll 'ls -l'

    # Interactive shell initialisation
    # --- HACKER FISH CONFIG ---

    function addhost
        # Backup original hosts file if backup doesn't exist
        if not test -f /etc/hosts.backup
            sudo cp /etc/hosts /etc/hosts.backup
            echo "Created backup of original hosts file"
        end

        # Add new entry to hosts file
        echo "$argv[1] $argv[2]" | sudo tee -a /etc/hosts >/dev/null
        echo "Added: $argv[1] $argv[2] to /etc/hosts"
    end

    function rmhost
        if test (count $argv) -ne 1
            echo "Usage: rmhost <hostname_or_ip>"
            return 1
        end

        # Remove entries containing the specified host/ip
        sudo sed -i "/$argv[1]/d" /etc/hosts
        echo "Removed entries containing: $argv[1]"
    end

    function resethost
        if test -f /etc/hosts.backup
            sudo cp /etc/hosts.backup /etc/hosts
            echo "Reset hosts file from backup"
        else
            echo "No backup file found at /etc/hosts.backup"
            echo "Consider manually restoring from a known good hosts file"
        end
    end

    function listhosts
        echo "Current /etc/hosts entries:"
        cat /etc/hosts | grep -v '^#' | grep -v '^$'
    end

    function extract
        if test (count $argv) -ne 1
            echo "Usage: extract <file>"
            return 1
        end

        set file $argv[1]

        if not test -f $file
            echo "Error: '$file' is not a valid file"
            return 1
        end

        switch $file
            case "*.tar.bz2"
                tar xvjf $file
            case "*.tar.gz"
                tar xvzf $file
            case "*.tar.xz"
                tar xvJf $file
            case "*.bz2"
                bunzip2 $file
            case "*.rar"
                unrar x $file
            case "*.gz"
                gunzip $file
            case "*.tar"
                tar xvf $file
            case "*.tbz2"
                tar xvjf $file
            case "*.tgz"
                tar xvzf $file
            case "*.zip"
                unzip $file
            case "*.Z"
                uncompress $file
            case "*.7z"
                7z x $file
            case "*.xz"
                unxz $file
            case "*.exe"
                cabextract $file
            case "*"
                echo "Error: '$file' cannot be extracted via extract function"
                echo "Supported formats: tar.bz2, tar.gz, tar.xz, bz2, rar, gz, tar, tbz2, tgz, zip, Z, 7z, xz, exe"
        end
    end

    function fish_greeting
        # Enhanced Cybersecurity Greeting with System Info & Red Team Infrastructure Check
        
        # Colors
        set RED (set_color red --bold)
        set GREEN (set_color green --bold)
        set YELLOW (set_color yellow --bold)
        set BLUE (set_color blue --bold)
        set CYAN (set_color cyan --bold)
        set MAGENTA (set_color magenta --bold)
        set WHITE (set_color white --bold)
        set GRAY (set_color brblack)
        set NORMAL (set_color normal)
        
        # Main Greeting Banner
        echo ""
        echo "$RED╔═════════════════════════════════════════════════════════════════════╗$NORMAL"
        echo "$RED║  $CYAN🔴 $WHITE H4CK3R T3RM1N4L $CYAN🔴 $WHITE- $GREEN Fr3akazo1d-sec $WHITE Workstation    $RED          ║$NORMAL"  
        echo "$RED╚═════════════════════════════════════════════════════════════════════╝$NORMAL"
        
        # System Information
        set host_name (hostname)
        set kernel (uname -r)
        set uptime_raw (uptime | sed 's/.*up \([^,]*\).*/\1/' 2>/dev/null || echo "Unknown")
        set distro (cat /etc/os-release 2>/dev/null | grep PRETTY_NAME | cut -d'"' -f2 || echo "Unknown Linux")
        
        # CPU & Memory
        set cpu_cores (nproc 2>/dev/null || echo "Unknown")
        set memory_info (free -h 2>/dev/null | awk '/^Mem:/ {print $3 "/" $2 " (" int($3/$2*100) "%)"}' || echo "N/A")
        set load_avg (cat /proc/loadavg 2>/dev/null | cut -d' ' -f1-3 || echo "N/A")
        
        # Network & Security Info  
        set primary_interface (ip route 2>/dev/null | grep default | awk '{print $5}' | head -1 || echo "N/A")
        set local_ip (ip addr show $primary_interface 2>/dev/null | grep "inet " | awk '{print $2}' | cut -d/ -f1 || echo "N/A")
        set public_ip (curl -s --connect-timeout 3 ifconfig.me 2>/dev/null || echo "Offline")
        
        # Red Team Infrastructure Checks
        # System Status Box
        echo ""
        echo "$YELLOW┌─ 🖥️  SYSTEM STATUS ─────────────────────────────────────────────────┐$NORMAL"
        echo "$YELLOW│$NORMAL   $CYAN Host:$NORMAL $WHITE$host_name$NORMAL $GRAY│$NORMAL   $CYAN Kernel:$NORMAL $WHITE$kernel$NORMAL"
        echo "$YELLOW│$NORMAL   $CYAN OS:$NORMAL $WHITE$distro$NORMAL"
        echo "$YELLOW│$NORMAL   $CYAN Uptime:$NORMAL $WHITE$uptime_raw$NORMAL $GRAY│$NORMAL   $CYAN Load:$NORMAL $WHITE$load_avg$NORMAL"
        echo "$YELLOW│$NORMAL   $CYAN CPU Cores:$NORMAL $WHITE$cpu_cores$NORMAL $GRAY│$NORMAL   $CYAN Memory:$NORMAL $WHITE$memory_info$NORMAL"
        echo "$YELLOW└─────────────────────────────────────────────────────────────────────┘$NORMAL"
        
        # Network & VPN Status Box
        echo ""
        echo "$BLUE┌─ 🌐 NETWORK & CONNECTIVITY ─────────────────────────────────────────┐$NORMAL"
        echo "$BLUE│$NORMAL   $CYAN Interface:$NORMAL $WHITE$primary_interface$NORMAL $GRAY│$NORMAL   $CYAN Local IP:$NORMAL $WHITE$local_ip$NORMAL"
        
        # Public IP with status indicator
        if test "$public_ip" != "Offline"
            echo "$BLUE│$NORMAL   $CYAN Public IP:$NORMAL $GREEN$public_ip$NORMAL ✅"
        else
            echo "$BLUE│$NORMAL   $CYAN Public IP:$NORMAL $RED$public_ip$NORMAL ❌"
        end
        
        echo "$BLUE│$NORMAL"
        echo "$BLUE│$NORMAL $MAGENTA🔴 RED TEAM INFRASTRUCTURE STATUS:$NORMAL"
        
        # Enhanced VPN/WireGuard Detection
        set vpn_found false
        set vpn_interfaces
        
        # Check OpenVPN interfaces
        if ip addr show tun0 >/dev/null 2>&1
            set vpn_ip (ip addr show tun0 2>/dev/null | grep "inet " | awk '{print $2}' | cut -d/ -f1)
            echo "$BLUE│$NORMAL     $CYAN OpenVPN:$NORMAL $GREEN✅ Connected$NORMAL $GRAY($WHITE$vpn_ip$NORMAL$GRAY)$NORMAL"
            set vpn_found true
        end
        
        # Check WireGuard interfaces
        if type -q wg
            set wg_interfaces (wg show interfaces 2>/dev/null)
            if test -n "$wg_interfaces"
                for wg_if in $wg_interfaces
                    set wg_ip (ip addr show $wg_if 2>/dev/null | grep "inet " | awk '{print $2}' | cut -d/ -f1)
                    if test -n "$wg_ip"
                        echo "$BLUE│$NORMAL     $CYAN WireGuard ($wg_if):$NORMAL $GREEN✅ Connected$NORMAL $GRAY($WHITE$wg_ip$NORMAL$GRAY)$NORMAL"
                        set vpn_found true
                    else
                        echo "$BLUE│$NORMAL     $CYAN WireGuard ($wg_if):$NORMAL $GREEN✅ Active$NORMAL $GRAY(no local IP)$NORMAL"
                        set vpn_found true
                    end
                end
            end
        end
        
        # If no VPN found, show disconnected
        if test "$vpn_found" = "false"
            echo "$BLUE│$NORMAL     $CYAN VPN/WireGuard:$NORMAL $RED❌ Disconnected$NORMAL"
        end
        
        # Check Tor Service  
        if systemctl is-active tor >/dev/null 2>&1
            echo "$BLUE│$NORMAL     $CYAN Tor Service:$NORMAL $GREEN✅ Running$NORMAL"
        else
            echo "$BLUE│$NORMAL     $CYAN Tor Service:$NORMAL $RED❌ Stopped$NORMAL"
        end
        
        # Check SSH Agent
        if test -n "$SSH_AUTH_SOCK"; and ssh-add -l >/dev/null 2>&1
            set key_count (ssh-add -l 2>/dev/null | wc -l)
            echo "$BLUE│$NORMAL   $CYAN SSH Agent:$NORMAL $GREEN✅ Active$NORMAL ($WHITE$key_count keys$NORMAL)"
        else
            echo "$BLUE│$NORMAL   $CYAN SSH Agent:$NORMAL $RED❌ No keys loaded$NORMAL"
        end
        
        # Check if connected to known Red Team networks (customize these)
        set red_team_networks "10.10.10.0/24" "192.168.1.0/24" "172.16.0.0/16"
        set in_red_team_net $RED"❌ External Network"$NORMAL
        
        for network in $red_team_networks
            if ip route get (echo $network | cut -d/ -f1) 2>/dev/null | grep -q "via"
                set in_red_team_net $GREEN"✅ Red Team Network Detected"$NORMAL  
                break
            end
        end
        echo "$BLUE│$NORMAL   $CYAN Network Zone:$NORMAL $in_red_team_net"
        
        echo "$BLUE└─────────────────────────────────────────────────────────────────────┘$NORMAL"
        
        # Cyber-Sec Tools Status
        echo ""
        echo "$MAGENTA┌─ ⚔️  CYBERSEC ARSENAL ─────────────────────────────────────────────────┐$NORMAL"
        
        # Check for important tools
        set tools nmap nikto burpsuite metasploit-framework john hashcat aircrack-ng wireshark
        set tools_status ""
        
        for tool in $tools
            if command -v $tool >/dev/null 2>&1
                set tools_status "$tools_status$GREEN$tool$NORMAL "
            else
                set tools_status "$tools_status$RED$tool$NORMAL "
            end
        end
        
        echo "$MAGENTA│$NORMAL $CYAN Tools:$NORMAL $tools_status"
        
        # Check Cyber-Sec directories
        if test -d /opt/Cyber-Sec
            set cybersec_dirs (ls /opt/Cyber-Sec 2>/dev/null | wc -l)
            echo "$MAGENTA│$NORMAL $CYAN Cyber-Sec Dirs:$NORMAL $GREEN✅ Active$NORMAL ($WHITE$cybersec_dirs directories$NORMAL)"
        else
            echo "$MAGENTA│$NORMAL $CYAN Cyber-Sec Dirs:$NORMAL $RED❌ Not Found$NORMAL"
        end
        
        echo "$MAGENTA└─────────────────────────────────────────────────────────────────────┘$NORMAL"
        
        # Final Status & Time
        set current_time (date "+%H:%M:%S")
        set current_date (date "+%A, %B %d, %Y")
        
        echo ""
        echo "$WHITE┌─────────────────────────────────────────────────────────────────────┐$NORMAL"
        echo "$WHITE│$NORMAL $YELLOW⚡$NORMAL $CYAN$current_date$NORMAL | $CYAN$current_time$NORMAL"
        echo "$WHITE│$NORMAL $GREEN🚀 Ready for Red Team Operations$NORMAL | $MAGENTA👾 h3ll0 Fr13nd!$NORMAL"
        echo "$WHITE└─────────────────────────────────────────────────────────────────────┘$NORMAL"
        echo ""
    end

    # Quick Red Team Infrastructure Status Check
    function redteam-status
        set RED (set_color red --bold)
        set GREEN (set_color green --bold)
        set CYAN (set_color cyan --bold)
        set WHITE (set_color white --bold)
        set NORMAL (set_color normal)
        
        echo ""
        echo "$RED🔴 RED TEAM INFRASTRUCTURE STATUS$NORMAL"
        echo "$RED─────────────────────────────────────$NORMAL"
        
        # VPN Check
        if ip addr show tun0 >/dev/null 2>&1; or ip addr show wg0 >/dev/null 2>&1
            set vpn_ip (ip addr show tun0 2>/dev/null | grep "inet " | awk '{print $2}' | cut -d/ -f1; or ip addr show wg0 2>/dev/null | grep "inet " | awk '{print $2}' | cut -d/ -f1)
            echo "$CYAN VPN:$NORMAL $GREEN✅ Connected$NORMAL ($WHITE$vpn_ip$NORMAL)"
        else
            echo "$CYAN VPN:$NORMAL $RED❌ Disconnected$NORMAL"
        end
        
        # Tor Check
        if systemctl is-active tor >/dev/null 2>&1
            echo "$CYAN Tor:$NORMAL $GREEN✅ Running$NORMAL"
        else
            echo "$CYAN Tor:$NORMAL $RED❌ Stopped$NORMAL"
        end
        
        # SSH Agent Check
        if test -n "$SSH_AUTH_SOCK"; and ssh-add -l >/dev/null 2>&1
            set key_count (ssh-add -l 2>/dev/null | wc -l)
            echo "$CYAN SSH:$NORMAL $GREEN✅ $key_count keys loaded$NORMAL"
        else
            echo "$CYAN SSH:$NORMAL $RED❌ No keys$NORMAL"
        end
        
        # Public IP
        set public_ip (curl -s --connect-timeout 2 ifconfig.me 2>/dev/null || echo "Offline")
        if test "$public_ip" != "Offline"
            echo "$CYAN IP:$NORMAL $GREEN$public_ip$NORMAL"
        else
            echo "$CYAN IP:$NORMAL $RED$public_ip$NORMAL"
        end
        echo ""
    end

    # Quick System Status
    function sys-status
        set BLUE (set_color blue --bold)
        set CYAN (set_color cyan --bold)
        set WHITE (set_color white --bold)
        set NORMAL (set_color normal)
        
        echo ""
        echo "$BLUE💻 SYSTEM STATUS$NORMAL"
        echo "$BLUE─────────────────$NORMAL"
        
        set host_name (hostname)
        set uptime_raw (uptime | sed 's/.*up \([^,]*\).*/\1/' 2>/dev/null || echo "Unknown")
        set memory_info (free -h 2>/dev/null | awk '/^Mem:/ {print $3 "/" $2 " (" int($3/$2*100) "%)"}' || echo "N/A")
        set disk_usage (df -h / | awk 'NR==2 {print $3 "/" $2 " (" $5 ")"}')
        set load_avg (cat /proc/loadavg | cut -d' ' -f1-3)
        
        echo "$CYAN Host:$NORMAL $WHITE$host_name$NORMAL"
        echo "$CYAN Uptime:$NORMAL $WHITE$uptime_raw$NORMAL"
        echo "$CYAN Memory:$NORMAL $WHITE$memory_info$NORMAL"
        echo "$CYAN Disk:$NORMAL $WHITE$disk_usage$NORMAL"
        echo "$CYAN Load:$NORMAL $WHITE$load_avg$NORMAL"
        echo ""
    end

    # Network Reconnaissance Quick Check
    function net-recon
        set GREEN (set_color green --bold)
        set YELLOW (set_color yellow --bold)
        set CYAN (set_color cyan --bold)
        set WHITE (set_color white --bold)
        set NORMAL (set_color normal)
        
        echo ""
        echo "$GREEN🌐 NETWORK RECONNAISSANCE$NORMAL"
        echo "$GREEN─────────────────────────$NORMAL"
        
        set interface (ip route | grep default | awk '{print $5}' | head -1)
        set local_ip (ip addr show $interface 2>/dev/null | grep "inet " | awk '{print $2}' | cut -d/ -f1)
        set gateway (ip route | grep default | awk '{print $3}' | head -1)
        set network (echo $local_ip | cut -d. -f1-3).0
        
        echo "$CYAN Interface:$NORMAL $WHITE$interface$NORMAL"
        echo "$CYAN Local IP:$NORMAL $WHITE$local_ip$NORMAL"
        echo "$CYAN Gateway:$NORMAL $WHITE$gateway$NORMAL"
        echo "$CYAN Network:$NORMAL $WHITE$network/24$NORMAL"
        
        # Quick ping test to gateway
        if ping -c 1 -W 1 $gateway >/dev/null 2>&1
            echo "$CYAN Gateway:$NORMAL $GREEN✅ Reachable$NORMAL"
        else
            echo "$CYAN Gateway:$NORMAL $YELLOW⚠️  Unreachable$NORMAL"
        end
        
        # DNS Test
        if nslookup google.com >/dev/null 2>&1
            echo "$CYAN DNS:$NORMAL $GREEN✅ Working$NORMAL"
        else
            echo "$CYAN DNS:$NORMAL $YELLOW⚠️  Issues$NORMAL"
        end
        echo ""
    end

    # Cybersec Tools Check
    function tools-check
        set MAGENTA (set_color magenta --bold)
        set GREEN (set_color green --bold)
        set RED (set_color red --bold)
        set CYAN (set_color cyan --bold)
        set NORMAL (set_color normal)
        
        echo ""
        echo "$MAGENTA⚔️  CYBERSEC ARSENAL STATUS$NORMAL"
        echo "$MAGENTA─────────────────────────────$NORMAL"
        
        set essential_tools nmap nikto burpsuite metasploit john hashcat aircrack-ng wireshark sqlmap gobuster ffuf
        
        for tool in $essential_tools
            if command -v $tool >/dev/null 2>&1
                echo "$CYAN$tool:$NORMAL $GREEN✅ Installed$NORMAL"
            else
                echo "$CYAN$tool:$NORMAL $RED❌ Missing$NORMAL"
            end
        end
        
        # Check Cyber-Sec directories
        if test -d /opt/Cyber-Sec
            echo ""
            echo "$CYAN Cyber-Sec Dirs:$NORMAL $GREEN✅ Available$NORMAL"
            ls -la /opt/Cyber-Sec/ 2>/dev/null | grep "^d" | awk '{print "  - " $9}'
        else
            echo ""
            echo "$CYAN Cyber-Sec Dirs:$NORMAL $RED❌ Not Found$NORMAL"
        end
        echo ""
    end

    # System aliases
    alias ll='ls -lh --color=auto'
    alias la='ls -lAh --color=auto'
    alias ..='cd ..'
    alias ...='cd ../..'
    alias clr='clear'
    alias myip='curl -s ifconfig.me'
    alias pubip='dig +short myip.opendns.com @resolver1.opendns.com'
    alias ports='netstat -tulanp tcp'
    alias scan='nmap -A -T4'
    alias sniff='sudo tcpdump -i any'
    
    # Red Team Infrastructure aliases
    alias rt='redteam-status'
    alias sys='sys-status'
    alias net='net-recon'
    alias tools='tools-check'
    alias fullstatus='redteam-status && sys-status'
    alias hx='hexdump -C'
    alias conns='lsof -i -n -P'
    alias serve='python3 -m http.server 8080'

    # Better file operations
    alias cp='cp -i'
    alias mv='mv -i'
    alias rm='rm -i'
    alias mkdir='mkdir -p'

    # Quick config edits
    function fishconfig
        if test -n "$EDITOR"
            $EDITOR ~/.config/fish/config.fish
        else if type -q nvim
            nvim ~/.config/fish/config.fish
        else if type -q vim
            vim ~/.config/fish/config.fish
        else
            nano ~/.config/fish/config.fish
        end
    end
    alias reload='source ~/.config/fish/config.fish'

    # Network utilities
    alias ping='ping -c 5'
    alias wget='wget -c'

    # System shortcuts
    alias h='history'
    alias j='jobs'
    alias path='echo $PATH | tr ":" "\n"'
    alias now='date "+%Y-%m-%d %H:%M:%S"'

    # Arch Linux specific aliases
    alias pacup='sudo pacman -Syu'
    alias pacin='sudo pacman -S'
    alias pacse='pacman -Ss'
    alias pacre='sudo pacman -Rs'
    alias pacor='sudo pacman -Rns (pacman -Qtdq)'  # Remove orphans
    alias pacls='pacman -Qe'  # List explicitly installed packages

    # AUR helper aliases (if you use yay)
    if type -q yay
        alias yayin='yay -S'
        alias yayse='yay -Ss'
        alias yayup='yay -Syu'
    end

    # Fix pacman tab completion only if using German locale
    if string match -q "*de_*" "$LANG"
        # German locale causes tr command errors in Fish pacman completions
        complete -c pacman -e
        complete -c sudo -e
        
        # Simple direct pacman completion (avoid complex Fish completion system)
        complete -c pacman -x -s S -a '(env LC_ALL=C pacman -Slq 2>/dev/null)'
        complete -c sudo -x -a 'pacman' -d 'Package manager'
        
        echo "Applied German locale fix for pacman completions"
    end
    
    # wireguard aliases
    alias wg-rt-admin-prod-up='sudo wg-quick up wg0'
    alias wg-rt-admin-prod-down='sudo wg-quick down wg0'
    alias wg-rt-admin-pg-up='sudo wg-quick up wg1'
    alias wg-rt-admin-pg-down='sudo wg-quick down wg1'

    # Git functions
    function acp
        git add .
        git commit -m "$argv"
        git push
    end

    # Better git status
    function gs
        git status --short --branch
    end

    # Git log with pretty format
    function gl_pretty
        git log --oneline --graph --decorate --all -10
    end

    # Quick git diff
    function gd
        git diff --color=always $argv | less -R
    end

    # Undo last commit (keep changes)
    function git_undo
        git reset --soft HEAD~1
    end

    # Cyber Security management functions with categories
    function cyberget
        if test (count $argv) -lt 2
            echo "Usage: cyberget <category> <git-url> [directory-name]"
            echo "Categories:"
            echo "  tools      - Security tools and scripts"
            echo "  configs    - Configuration files and templates"
            echo "  wordlists  - Password lists and dictionaries"
            echo "  payloads   - Exploit payloads and shells"
            echo "  research   - Research projects and PoCs"
            echo "  hackthebox - HackTheBox writeups and scripts"
            echo "  tryhackme  - TryHackMe challenges and notes"
            echo "  hacksmarter - HackSmarter courses and materials"
            echo ""
            echo "Examples:"
            echo "  cyberget tools https://github.com/user/nmap-scripts.git"
            echo "  cyberget hackthebox https://github.com/user/htb-writeups.git"
            echo "  cyberget tryhackme https://github.com/user/thm-notes.git"
            return 1
        end
        
        set category $argv[1]
        set git_url $argv[2]
        
        # Define category directories
        switch $category
            case tools
                set target_dir /opt/Cyber-Sec/tools
                set emoji "🛠️"
            case configs
                set target_dir /opt/Cyber-Sec/configs
                set emoji "⚙️"
            case wordlists
                set target_dir /opt/Cyber-Sec/wordlists
                set emoji "📝"
            case payloads
                set target_dir /opt/Cyber-Sec/payloads
                set emoji "💣"
            case research
                set target_dir /opt/Cyber-Sec/research
                set emoji "🔬"
            case hackthebox
                set target_dir /opt/Cyber-Sec/hackthebox
                set emoji "📦"
            case tryhackme
                set target_dir /opt/Cyber-Sec/tryhackme
                set emoji "🎯"
            case hacksmarter
                set target_dir /opt/Cyber-Sec/hacksmarter
                set emoji "🧠"
                case hackthebox
                    set emoji "📦"
                case tryhackme
                    set emoji "🎯"
                case hacksmarter
                    set emoji "🧠"
            case "*"
                echo "❌ Invalid category: $category"
                echo "Valid categories: tools, configs, wordlists, payloads, research, hackthebox, tryhackme, hacksmarter"
                return 1
        end
        
        # Create directory if it doesn't exist
        if not test -d $target_dir
            echo "📁 Creating $category directory: $target_dir"
            sudo mkdir -p $target_dir
            sudo chown (whoami):(whoami) $target_dir 2>/dev/null || true
        end
        
        # Extract repository name or use custom name
        if test (count $argv) -ge 3
            set repo_name $argv[3]
        else
            set repo_name (basename $git_url .git)
        end
        
        set target_path $target_dir/$repo_name
        
        # Check if directory already exists
        if test -d $target_path
            echo "⚠️  Directory '$target_path' already exists!"
            echo "Choose a different name or remove the existing directory."
            return 1
        end
        
        echo "🔄 Cloning $git_url to $target_path..."
        
        # Clone the repository
        if git clone $git_url $target_path
            echo "✅ Successfully cloned to $target_path"
            echo "📂 Changing directory to $target_path"
            cd $target_path
            
            # Show some info about the cloned repo
            echo ""
            echo "📊 Repository info:"
            echo "├─ Category: $emoji $category"
            echo "├─ Path: $target_path"
            echo "├─ Remote: "(git remote get-url origin 2>/dev/null || echo "No remote")
            echo "├─ Branch: "(git branch --show-current 2>/dev/null || echo "No branch")
            echo "└─ Files: "(ls -1 | wc -l)" items"
        else
            echo "❌ Failed to clone repository"
            return 1
        end
    end

    # Backward compatibility - cyberclone now defaults to tools
    function cyberclone
        if test (count $argv) -eq 0
            echo "Usage: cyberclone <git-url> [directory-name]"
            echo "Note: This clones to tools directory. Use 'cyberget' for other categories."
            return 1
        end
        
        # Redirect to cyberget with tools category
        cyberget tools $argv
    end

    # List cyber security resources by category or all
    function cyberlist
        if test (count $argv) -eq 0
            echo "🔐 Cyber Security Resources:"
            echo ""
            
            # List all categories
            for category_info in "tools:🛠️" "configs:⚙️" "wordlists:📝" "payloads:💣" "research:🔬" "hackthebox:📦" "tryhackme:🎯" "hacksmarter:🧠"
                set category (echo $category_info | cut -d: -f1)
                set emoji (echo $category_info | cut -d: -f2)
                set category_dir /opt/Cyber-Sec/$category
                
                if test -d $category_dir
                    set count (find $category_dir -mindepth 1 -maxdepth 1 -type d 2>/dev/null | wc -l)
                    echo "├─ $emoji $category ($count items)"
                end
            end
            
            echo ""
            echo "💡 Use 'cyberlist <category>' for details or 'cybercd <category>' to navigate"
        else
            set category $argv[1]
            set category_dir /opt/Cyber-Sec/$category
            
            if not test -d $category_dir
                echo "📁 Category '$category' doesn't exist: $category_dir"
                return 1
            end
            
            # Set emoji based on category
            switch $category
                case tools
                    set emoji "🛠️"
                case configs
                    set emoji "⚙️"
                case wordlists
                    set emoji "📝"
                case payloads
                    set emoji "💣"
                case research
                    set emoji "🔬"
                case hackthebox
                    set emoji "📦"
                case tryhackme
                    set emoji "🎯"
                case hacksmarter
                    set emoji "🧠"
                case "*"
                    set emoji "�"
            end
            
            echo "$emoji Cyber Security $category in $category_dir:"
            echo ""
            
            set count 0
            for item in $category_dir/*
                if test -d $item
                    set count (math $count + 1)
                    set item_name (basename $item)
                    echo -n "├─ $item_name"
                    
                    # Check if it's a git repository
                    if test -d $item/.git
                        set remote_url (git -C $item remote get-url origin 2>/dev/null)
                        if test -n "$remote_url"
                            echo " (git: $remote_url)"
                        else
                            echo " (git repo)"
                        end
                    else
                        echo ""
                    end
                end
            end
            
            if test $count -eq 0
                echo "└─ No items found"
            else
                echo ""
                echo "📊 Total items: $count"
            end
        end
    end

    # Navigate to cyber security directories
    function cybercd
        if test (count $argv) -eq 0
            echo "📂 Available cyber security categories:"
            cyberlist
            return 0
        end
        
        set category $argv[1]
        
        # Special case: if second argument provided, navigate to specific item
        if test (count $argv) -ge 2
            set item_name $argv[2]
            set item_path /opt/Cyber-Sec/$category/$item_name
            
            if test -d $item_path
                echo "📂 Navigating to: $item_path"
                cd $item_path
            else
                echo "❌ Item '$item_name' not found in category '$category'"
                echo "Available items:"
                cyberlist $category
            end
        else
            # Navigate to category directory
            set category_dir /opt/Cyber-Sec/$category
            
            if test -d $category_dir
                echo "📂 Navigating to category: $category_dir"
                cd $category_dir
                cyberlist $category
            else
                echo "❌ Category '$category' not found"
                echo "Available categories:"
                cyberlist
            end
        end
    end

    # Update all cyber security Git repositories
    function cyberupdate
        echo "🔄 Updating all cyber security Git repositories..."
        echo ""
        
        set base_dir /opt/Cyber-Sec
        set updated_count 0
        set failed_count 0
        set total_count 0
        
        # Check if base directory exists
        if not test -d $base_dir
            echo "❌ Cyber-Sec directory not found: $base_dir"
            return 1
        end
        
        # Update each category
        for category in tools configs wordlists payloads research hackthebox tryhackme hacksmarter
            set category_dir $base_dir/$category
            
            if not test -d $category_dir
                continue
            end
            
            # Set emoji based on category
            switch $category
                case tools
                    set emoji "🛠️"
                case configs
                    set emoji "⚙️"
                case wordlists
                    set emoji "📝"
                case payloads
                    set emoji "💣"
                case research
                    set emoji "🔬"
                case hackthebox
                    set emoji "📦"
                case tryhackme
                    set emoji "🎯"
                case hacksmarter
                    set emoji "🧠"
            end
            
            echo "$emoji Updating $category repositories:"
            
            # Update each repository in the category
            for repo_path in $category_dir/*
                if test -d $repo_path/.git
                    set repo_name (basename $repo_path)
                    set total_count (math $total_count + 1)
                    
                    echo -n "  ├─ $repo_name ... "
                    
                    # Change to repo directory and pull
                    if cd $repo_path 2>/dev/null
                        # Check if there's a remote
                        set remote_url (git remote get-url origin 2>/dev/null)
                        if test -n "$remote_url"
                            # Fetch and check for updates
                            if git fetch --quiet 2>/dev/null
                                set local_commit (git rev-parse HEAD 2>/dev/null)
                                set remote_commit (git rev-parse @{u} 2>/dev/null)
                                
                                if test "$local_commit" = "$remote_commit"
                                    echo "✅ already up-to-date"
                                else
                                    # Pull updates
                                    if git pull --quiet 2>/dev/null
                                        echo "🔄 updated successfully"
                                        set updated_count (math $updated_count + 1)
                                    else
                                        echo "❌ update failed"
                                        set failed_count (math $failed_count + 1)
                                    end
                                end
                            else
                                echo "❌ fetch failed"
                                set failed_count (math $failed_count + 1)
                            end
                        else
                            echo "⚠️  no remote configured"
                        end
                        
                        # Return to base directory
                        cd $base_dir
                    else
                        echo "❌ couldn't access directory"
                        set failed_count (math $failed_count + 1)
                    end
                end
            end
            
            echo ""
        end
        
        # Summary
        echo "📊 Update Summary:"
        echo "├─ Total repositories: $total_count"
        echo "├─ Updated: $updated_count"
        echo "├─ Failed: $failed_count"
        echo "└─ Already up-to-date: "(math $total_count - $updated_count - $failed_count)
        echo ""
        
        if test $failed_count -gt 0
            echo "⚠️  Some repositories failed to update. Check them manually."
        else
            echo "✅ All repositories processed successfully!"
        end
    end

    # Update specific category repositories
    function cyberupdate_cat
        if test (count $argv) -eq 0
            echo "Usage: cyberupdate_cat <category>"
            echo "Categories: tools, configs, wordlists, payloads, research, hackthebox, tryhackme, hacksmarter"
            return 1
        end
        
        set category $argv[1]
        set category_dir /opt/Cyber-Sec/$category
        
        if not test -d $category_dir
            echo "❌ Category directory not found: $category_dir"
            return 1
        end
        
        # Set emoji based on category
        switch $category
            case tools
                set emoji "🛠️"
            case configs
                set emoji "⚙️"
            case wordlists
                set emoji "📝"
            case payloads
                set emoji "💣"
            case research
                set emoji "🔬"
            case hackthebox
                set emoji "📦"
            case tryhackme
                set emoji "🎯"
            case hacksmarter
                set emoji "🧠"
                case hackthebox
                    set emoji "📦"
                case tryhackme
                    set emoji "🎯"
                case hacksmarter
                    set emoji "🧠"
            case "*"
                set emoji "📁"
        end
        
        echo "$emoji Updating $category repositories..."
        echo ""
        
        set updated_count 0
        set failed_count 0
        set total_count 0
        
        # Update each repository in the category
        for repo_path in $category_dir/*
            if test -d $repo_path/.git
                set repo_name (basename $repo_path)
                set total_count (math $total_count + 1)
                
                echo -n "├─ $repo_name ... "
                
                # Change to repo directory and pull
                if cd $repo_path 2>/dev/null
                    # Check if there's a remote
                    set remote_url (git remote get-url origin 2>/dev/null)
                    if test -n "$remote_url"
                        # Pull updates
                        if git pull --quiet 2>/dev/null
                            echo "✅ updated successfully"
                            set updated_count (math $updated_count + 1)
                        else
                            echo "❌ update failed"
                            set failed_count (math $failed_count + 1)
                        end
                    else
                        echo "⚠️  no remote configured"
                    end
                    
                    # Return to original directory
                    cd -
                else
                    echo "❌ couldn't access directory"
                    set failed_count (math $failed_count + 1)
                end
            end
        end
        
        echo ""
        echo "📊 Category Update Summary:"
        echo "├─ Total repositories: $total_count"
        echo "├─ Updated: $updated_count"
        echo "└─ Failed: $failed_count"
    end

    # File functions
    function ff
        set file (fzf)
        if test -n "$file"
            if test -n "$EDITOR"
                $EDITOR $file
            else if type -q nvim
                nvim $file
            else if type -q vim
                vim $file
            else
                nano $file
            end
        end
    end

    function fh
        history | fzf | read -l cmd
        if test -n "$cmd"
            eval $cmd
        end
    end

    function mkcd
        mkdir -p $argv[1]; and cd $argv[1]
    end

    # Quick directory jumps
    function ..2; cd ../..; end
    function ..3; cd ../../..; end
    function ..4; cd ../../../..; end
    function ..5; cd ../../../../..; end

    # Show directory tree
    function tree
        if type -q exa
            exa --tree $argv
        else if type -q tree
            command tree $argv
        else
            find . -type d | head -20
        end
    end

    # Quick ls after cd
    function cd
        builtin cd $argv
        and ls -la
    end

    # Network functions
    function fastscan
        nmap -T5 -F $argv
    end

    # Display all network interfaces with IP addresses
    function myips
        set_color cyan --bold
        echo "🌐 Network Interfaces & IP Addresses:"
        set_color normal
        echo ""
        
        # Get all interfaces using ip link (more comprehensive)
        for interface in (ip link show | grep '^[0-9]' | awk '{print $2}' | sed 's/://' | sed 's/@.*//')
            # Check if interface has an IP address (IPv4)
            set ips (ip -4 addr show $interface 2>/dev/null | grep 'inet ' | awk '{print $2}' | cut -d'/' -f1)
            
            # Also check WireGuard interfaces specifically
            if string match -q 'wg*' $interface
                # For WireGuard, also check wg show command
                if type -q wg
                    set wg_info (wg show $interface 2>/dev/null)
                    if test -n "$wg_info"
                        # Get WireGuard IP from config or interface
                        if test -z "$ips"
                            set ips (wg show $interface allowed-ips 2>/dev/null | head -1 | cut -d',' -f1 | awk '{print $1}' | cut -d'/' -f1)
                        end
                    end
                end
            end
            
            # Show interface if it has IP addresses
            if test -n "$ips"
                # Color code different interface types
                if string match -q 'tun*' $interface; or string match -q 'tap*' $interface
                    set_color red --bold
                    echo -n "├─ 🔒 $interface (OpenVPN): "
                else if string match -q 'wg*' $interface
                    set_color magenta --bold
                    echo -n "├─ 🛡️ $interface (WireGuard): "
                else if string match -q 'docker*' $interface; or string match -q 'br-*' $interface
                    set_color blue --bold
                    echo -n "├─ 🐳 $interface (Docker): "
                else if test "$interface" = "lo"
                    set_color white --bold
                    echo -n "├─ 🔄 $interface (Loopback): "
                else if string match -q 'wl*' $interface; or string match -q 'wifi*' $interface
                    set_color green --bold
                    echo -n "├─ 📶 $interface (WiFi): "
                else if string match -q 'eth*' $interface; or string match -q 'en*' $interface
                    set_color green --bold
                    echo -n "├─ 🔌 $interface (Ethernet): "
                else
                    set_color green --bold
                    echo -n "├─ 🌐 $interface: "
                end
                
                set_color yellow
                for ip in $ips
                    echo -n "$ip "
                end
                echo ""
                set_color normal
            end
        end
        
        # Also check for active WireGuard interfaces separately
        if type -q wg
            for wg_interface in (wg show interfaces 2>/dev/null)
                # Check if we already displayed this interface
                set already_shown (ip -4 addr show $wg_interface 2>/dev/null | grep 'inet ')
                if test -z "$already_shown"
                    set_color magenta --bold
                    echo -n "├─ 🛡️ $wg_interface (WireGuard): "
                    set_color yellow
                    echo "Active (no local IP)"
                    set_color normal
                end
            end
        end
        
        echo ""
        # External IP with consistent formatting
        set_color magenta --bold
        echo -n "├─ 🌍 External (Public): "
        set_color normal
        
        # Get external IP with fallback services
        set external_ip (curl -s --max-time 3 ifconfig.me 2>/dev/null)
        if test -z "$external_ip"
            set external_ip (curl -s --max-time 3 ipinfo.io/ip 2>/dev/null)
        end
        if test -z "$external_ip"
            set external_ip (curl -s --max-time 3 icanhazip.com 2>/dev/null)
        end
        
        if test -n "$external_ip"
            set_color yellow
            echo "$external_ip"
        else
            set_color red
            echo "Unable to fetch"
        end
        set_color normal
        echo ""
    end

    # Alternative simpler version
    function ips
        set_color cyan --bold
        echo "Network Interfaces:"
        set_color normal
        ip -4 -o addr show | awk '{print $2 ": " $4}' | sed 's/\/[0-9]*//g'
    end

    function lsofpid
        lsof -p $argv
    end

    # System info functions
    function sysinfo
        echo "=== System Information ==="
        uname -a
        echo ""
        echo "=== CPU Info ==="
        lscpu | head -n 15
        echo ""
        echo "=== Memory Usage ==="
        free -h
        echo ""
        echo "=== Disk Usage ==="
        df -h | head -n 10
    end

    # Quick system resource check
    function resources
        echo "🔥 CPU Usage:"
        top -bn1 | grep "Cpu(s)" | awk '{print $2 $3}' | sed 's/%us,/% user,/g' | sed 's/%sy/% system/g'
        echo ""
        echo "💾 Memory:"
        free -h | awk '/^Mem:/ {printf "Used: %s/%s (%.1f%%)\n", $3, $2, ($3/$2)*100}'
        echo ""
        echo "💿 Disk:"
        df -h / | awk '/\// {printf "Used: %s/%s (%s)\n", $3, $2, $5}'
    end

    # Show largest files/directories
    function largest
        du -ah $argv | sort -rh | head -20
    end

    # Process monitor
    function processes
        ps aux --sort=-%cpu | head -10
    end

    # Git abbreviations
    abbr gco 'git checkout'
    abbr gst 'git status'
    abbr gl 'git pull'
    abbr gp 'git push'
    abbr v nvim

    # Development environment functions
    # Quick Python virtual environment
    function venv
        if test -d venv
            source venv/bin/activate.fish
        else if test -d .venv
            source .venv/bin/activate.fish
        else
            echo "No virtual environment found"
        end
    end

    # Quick project setup
    function newproject
        mkdir -p $argv[1]
        cd $argv[1]
        git init
        touch README.md .gitignore
        echo "# $argv[1]" > README.md
        echo "Project $argv[1] initialized!"
    end

    # Port checker
    function portcheck
        if test (count $argv) -eq 0
            echo "Usage: portcheck <port>"
            return 1
        end
        netstat -tuln | grep ":$argv[1] "
    end

    # Home Manager / Nix functions
    # Add package to home.nix
    function nixadd
        if test (count $argv) -eq 0
            echo "Usage: nixadd <package-name>"
            echo "Example: nixadd evil-winrm"
            return 1
        end
        
        set home_nix_path ~/.config/nixpkgs/home.nix
        if not test -f $home_nix_path
            set home_nix_path ~/.config/home-manager/home.nix
        end
        
        if not test -f $home_nix_path
            echo "❌ Home Manager config not found at ~/.config/nixpkgs/home.nix or ~/.config/home-manager/home.nix"
            return 1
        end
        
        set package_name $argv[1]
        
        # Check if package already exists
        if grep -q "^\s*$package_name\s*\$" $home_nix_path
            echo "📦 Package '$package_name' already exists in home.nix"
            return 0
        end
        
        # Find the home.packages section and add the package
        if grep -q "home\.packages.*with pkgs;" $home_nix_path
            # Add to existing home.packages list
            sed -i "/home\.packages.*with pkgs; \[/a\\    $package_name" $home_nix_path
            echo "✅ Added '$package_name' to home.packages"
        else
            echo "❌ Could not find 'home.packages = with pkgs; [' in $home_nix_path"
            echo "Please add it manually or ensure proper format"
            return 1
        end
    end

    # Remove package from home.nix
    function nixrm
        if test (count $argv) -eq 0
            echo "Usage: nixrm <package-name>"
            echo "Example: nixrm evil-winrm"
            return 1
        end
        
        set home_nix_path ~/.config/nixpkgs/home.nix
        if not test -f $home_nix_path
            set home_nix_path ~/.config/home-manager/home.nix
        end
        
        if not test -f $home_nix_path
            echo "❌ Home Manager config not found"
            return 1
        end
        
        set package_name $argv[1]
        
        # Remove the package line
        sed -i "/^\s*$package_name\s*\$/d" $home_nix_path
        echo "🗑️  Removed '$package_name' from home.packages"
    end

    # Search for Nix packages
    function nixsearch
        if test (count $argv) -eq 0
            echo "Usage: nixsearch <package-name>"
            echo "Example: nixsearch evil-winrm"
            return 1
        end
        
        echo "🔍 Searching for Nix packages containing '$argv[1]'..."
        nix search nixpkgs $argv[1]
    end

    # List packages in home.nix
    function nixlist
        set home_nix_path ~/.config/nixpkgs/home.nix
        if not test -f $home_nix_path
            set home_nix_path ~/.config/home-manager/home.nix
        end
        
        if not test -f $home_nix_path
            echo "❌ Home Manager config not found"
            return 1
        end
        
        echo "📦 Packages in home.nix:"
        grep -A 50 "home\.packages.*with pkgs;" $home_nix_path | grep -E "^\s+[a-zA-Z]" | sed 's/^\s*/  /' | head -20
    end

    # Apply Home Manager configuration
    function nixapply
        echo "🏠 Applying Home Manager configuration..."
        home-manager switch
        if test $status -eq 0
            echo "✅ Home Manager configuration applied successfully!"
        else
            echo "❌ Failed to apply Home Manager configuration"
        end
    end

    # Edit home.nix
    function nixedit
        set home_nix_path ~/.config/nixpkgs/home.nix
        if not test -f $home_nix_path
            set home_nix_path ~/.config/home-manager/home.nix
        end
        
        if not test -f $home_nix_path
            echo "❌ Home Manager config not found"
            return 1
        end
        
        # Use editor with fallback
        if test -n "$EDITOR"
            $EDITOR $home_nix_path
        else if type -q nvim
            nvim $home_nix_path
        else if type -q vim
            vim $home_nix_path
        else if type -q nano
            nano $home_nix_path
        else
            vi $home_nix_path
        end
    end

    # Home Manager cleanup functions
    function nixcleanup
        echo "🧹 Starting Home Manager cleanup..."
        echo ""
        
        echo "📊 Current Nix store size:"
        du -sh /nix/store 2>/dev/null || echo "Could not determine store size"
        echo ""
        
        echo "🗑️  Removing old Home Manager generations..."
        home-manager expire-generations "-7 days"
        
        echo "🧽 Collecting Nix garbage..."
        nix-collect-garbage
        
        echo "🔥 Collecting garbage with delete option..."
        nix-collect-garbage -d
        
        echo ""
        echo "📊 New Nix store size:"
        du -sh /nix/store 2>/dev/null || echo "Could not determine store size"
        echo ""
        echo "✨ Cleanup complete!"
    end

    # Remove old Home Manager generations
    function nixgc
        if test (count $argv) -eq 0
            echo "Usage: nixgc <days>"
            echo "Example: nixgc 7    # Remove generations older than 7 days"
            echo "         nixgc 0    # Remove all old generations"
            return 1
        end
        
        set days $argv[1]
        
        if test $days -eq 0
            echo "🗑️  Removing ALL old Home Manager generations..."
            home-manager expire-generations
        else
            echo "🗑️  Removing Home Manager generations older than $days days..."
            home-manager expire-generations "-$days days"
        end
        
        echo "🧽 Running garbage collection..."
        nix-collect-garbage -d
        echo "✅ Done!"
    end

    # Show Home Manager generations
    function nixgens
        echo "📜 Home Manager generations:"
        home-manager generations
    end

    # Optimize Nix store
    function nixoptimize
        echo "⚡ Optimizing Nix store (deduplicating files)..."
        nix-store --optimise
        echo "✅ Optimization complete!"
    end

    # Show disk usage of Nix store
    function nixsize
        echo "📊 Nix Store Usage:"
        echo ""
        set store_size (du -sh /nix/store 2>/dev/null | cut -f1)
        echo "📦 Total store size: $store_size"
        echo ""
        
        echo "🔍 Largest store paths (top 10):"
        du -sh /nix/store/* 2>/dev/null | sort -hr | head -10
        echo ""
        
        echo "📈 Home Manager generations:"
        home-manager generations | wc -l | xargs -I {} echo "📜 Total generations: {}"
    end

    # Repair Nix store
    function nixrepair
        echo "🔧 Verifying and repairing Nix store..."
        nix-store --verify --check-contents --repair
        echo "✅ Store verification complete!"
    end

    # Complete Nix maintenance
    function nixmaintenance
        echo "🔧 Starting complete Nix maintenance..."
        echo ""
        
        echo "📊 Before cleanup:"
        nixsize
        echo ""
        
        echo "🗑️  Removing old generations (30+ days)..."
        nixgc 30
        echo ""
        
        echo "⚡ Optimizing store..."
        nixoptimize
        echo ""
        
        echo "🔧 Verifying store..."
        nix-store --verify
        echo ""
        
        echo "📊 After cleanup:"
        nixsize
        echo ""
        echo "✨ Complete maintenance finished!"
    end

    # Initialize tools if available
    if type -q zoxide
        zoxide init fish | source
    else if type -q z
        z --init fish | source
    end

    if type -q fzf
        fzf_key_bindings
    end

    if type -q starship
        starship init fish | source
    end

    # --- END HACKER FISH CONFIG ---

    # Emergency functions
    # Backup important configs
    function backup_configs
        set backup_dir ~/config_backup_(date +%Y%m%d)
        mkdir -p $backup_dir
        cp -r ~/.config/fish $backup_dir/
        cp ~/.bashrc $backup_dir/ 2>/dev/null
        cp ~/.profile $backup_dir/ 2>/dev/null
        echo "Configs backed up to $backup_dir"
    end

    # Quick system cleanup
    function cleanup
        echo "🧹 Cleaning package cache..."
        sudo pacman -Sc --noconfirm
        echo "🗑️  Removing orphaned packages..."
        sudo pacman -Qtdq | sudo pacman -Rns - --noconfirm 2>/dev/null
        echo "✨ Cleanup complete!"
    end

    # Show all aliases and functions
    function showall
        echo "🔧 Current Aliases:"
        echo "===================="
        alias | sort
        echo ""
        echo "⚡ Custom Functions:"
        echo "===================="
        functions -n | grep -v '^_' | sort
        echo ""
        echo "📋 Abbreviations:"
        echo "=================="
        abbr
    end

    # Learning platform shortcuts
    function htb
        cybercd hackthebox $argv
    end

    function thm
        cybercd tryhackme $argv
    end

    function hs
        cybercd hacksmarter $argv
    end

    # Quick navigation to learning platforms
    alias htbdir='cd /opt/Cyber-Sec/hackthebox && ls -la'
    alias thmdir='cd /opt/Cyber-Sec/tryhackme && ls -la'
    alias hsdir='cd /opt/Cyber-Sec/hacksmarter && ls -la'

end

# Add common paths
set -gx PATH $PATH ~/.local/bin

# Set default editor (with fallbacks)
if type -q nvim
    set -gx EDITOR nvim
else if type -q vim
    set -gx EDITOR vim
else if type -q nano
    set -gx EDITOR nano
else
    set -gx EDITOR vi
end

# Better colors for ls
set -gx LS_COLORS 'di=34:ln=35:so=32:pi=33:ex=31:bd=46;34:cd=43;34:su=41;30:sg=46;30'

# Better grep colors  
set -gx GREP_OPTIONS '--color=auto'
set -gx GREP_COLORS 'mt=1;32'

# Better man page colors
set -gx LESS_TERMCAP_mb (set_color --bold red)
set -gx LESS_TERMCAP_md (set_color --bold cyan)
set -gx LESS_TERMCAP_me (set_color normal)
set -gx LESS_TERMCAP_se (set_color normal)
set -gx LESS_TERMCAP_so (set_color --background yellow black)
set -gx LESS_TERMCAP_ue (set_color normal)
set -gx LESS_TERMCAP_us (set_color --underline green)

function fish_right_prompt
    set_color red --bold
    echo -n "h3ll0 "
    set_color cyan --bold  
    echo -n "Fr13nd!"
    set_color normal
end