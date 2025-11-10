xdg_config := env("XDG_CONFIG_HOME", env("HOME") + "/.config")
mcp_root := env("HOME") + "/repos" + "/mcp"
dot_mcp := root + "/.ai/mcp"
root := `git rev-parse --show-toplevel`
claude_desktop_config := env("HOME") + "/Library/Application Support/Claude/claude_desktop_config.json"
zed_global_config := env("HOME") + "/.config/zed/settings.json"
zed_project_config := root + "/.zed/settings.json"
free_cad_mods_dir := env("HOME") + "/Library/Preferences/FreeCAD/Mod"

config-all-ai-tools mcptool: (config-claude-desktop mcptool)
    # config-claude-code "{{ mcptool }}"
    # config-claude-cortex "{{ mcptool }}"

config-claude-desktop key:
    #!/usr/bin/env bash
    json=$(export MCP_ROOT="{{ mcp_root }}" && yq --output-format json '.{{ key }}' "{{ dot_mcp }}/mcp.yaml" | envsubst)
    jq --argjson mcp "{\"{{ key }}\": $json}" '.mcpServers += $mcp' "{{ claude_desktop_config }}" | sponge "{{ claude_desktop_config }}"

config-zed key scope="global":
    #!/usr/bin/env bash
    echo "TODO"
    json=$(export MCP_ROOT="{{ mcp_root }}" && yq --output-format json '.{{ key }}' "{{ dot_mcp }}/mcp.yaml" | envsubst)
    jq --argjson mcp "{\"{{ key }}\": $json}" '.context_servers += $mcp' "{{ claude_desktop_config }}" | sponge "{{ claude_desktop_config }}"
    # settings.json

kicad: (config-all-ai-tools "kicad")
    #!/usr/bin/env bash
    brew install uv
    cd "{{ mcp_root }}"
    # git clone https://github.com/lamaalrajih/kicad-mcp.git
    cd kicad-mcp
    # Install dependencies – `uv` will create a `.venv/` folder automatically
    # (Install `uv` first: `brew install uv` on macOS or `pipx install uv`)
    make install
    # Optional: activate the environment for manual commands
    source .venv/bin/activate
    # Edit the .env file
    echo "" > .env
    # Add paths to your KiCad projects (comma-separated)
    echo "KICAD_APP_PATH=/Applications/KiCad/KiCad.app" >> .env
    echo "KICAD_SEARCH_PATHS=~/repos/hardware" >> .env
    echo "KICAD_USER_DIR=~/Documents/KiCad" >> .env
    # python main.py

kicad-alt:
    #!/usr/bin/env bash
    # Install Node.js
    brew install node@20
    # Clone and build
    cd "{{ dot_mcp }}"
    git clone https://github.com/mixelpixx/KiCAD-MCP-Server.git "kicad-mcp-alt"
    cd KiCAD-MCP-Server
    npm install
    pip3 install -r requirements.txt
    npm run build

surrealdb:
    #!/usr/bin/env bash
    echo "TODO"

docling: (pyenv "3.12" "docling") (config-all-ai-tools "docling")
    #!/usr/bin/env bash
    brew install tesseract leptonica pkg-config
    cd "{{ mcp_root }}/docling"
    python3 -m pip install --upgrade pip
    python3 -m pip install "docling[asr,vlm,easyocr,tesserocr,ocrmac,rapidocr]" --extra-index-url https://download.pytorch.org/whl/cpu

pyenv ver local:
    #!/usr/bin/env bash
    brew install pyenv
    if ![[ pyenv "local" | grep -o "{{ ver }}" ]]; then
        mkdir -p "{{ mcp_root }}/docling"
        cd "{{ mcp_root }}/{{ local }}"
        pyenv install "{{ ver }}"
        pyenv local "{{ ver }}"
    fi

freecad: (pyenv "3.12" "docling") (config-all-ai-tools "docling")
    #!/usr/bin/env bash
    brew install freecad
    mkdir -p "{{ free_cad_mods_dir }}"
    cd "{{ free_cad_mods_dir }}"
    git clone https://github.com/bonninr/freecad_mcp.git "freecad-mcp"

gitlab-ci-local:
    #!/usr/bin/env bash
    volta install gitlab-ci-local
    echo "TODO"

github:
    #!/usr/bin/env bash
    echo "TODO"

gitlab:
    #!/usr/bin/env bash
    echo "TODO"


gitea:
    #!/usr/bin/env bash
    echo "TODO"

gitea:
    #!/usr/bin/env bash
    echo "TODO"

bitbucket:
    #!/usr/bin/env bash
    echo "TODO"

jira:
    #!/usr/bin/env bash
    echo "TODO"

confluence:
    #!/usr/bin/env bash
    echo "TODO"

gitea:
    #!/usr/bin/env bash
    echo "TODO"
