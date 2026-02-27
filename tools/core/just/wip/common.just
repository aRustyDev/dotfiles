set dotenv-path := "./config/.env"
set shell := ["/usr/bin/env", "bash", "-c"]

# Directories (Computed)

root := `git rev-parse --show-toplevel`

# Directories (Defined)

templatesd := root + "/.templates"
scriptsd := root + "/scripts"
configsd := root + "/config"
pythond := scriptsd + "/python"
justd := scriptsd + "/just"
bashd := scriptsd + "/bash"
datad := root + "/data"
varsd := datad + "/vars"
awkd := scriptsd + "/awk"
jqd := scriptsd + "/jq"

# Prefixes

varfiles := varsd / environment

# Files

aws_sso_gov := "~/.config/aws-sso/gov.yaml"

# Variables
# : Default to 'prod'; others are for cloud9 eng team
# : Use CLOUD9_STAGE env var to override
# : CLOUD9_ENDPOINT can also be overridden directly if needed

cloud9_stage := env("CLOUD9_STAGE", "prod")
c9_stage := if cloud9_stage == "prod" { "wwwin-cloud9" } else if cloud9_stage == "test" { "wwwin-cloud9-test" } else { "" }
endpoint := env("CLOUD9_ENDPOINT", if c9_stage != "" { "https://" + c9_stage + ".cisco.com" } else { "https://localhost:8000" })

# UI Helper

br := "\n-----------------------------------\n"

## Config

config := root / "config.yaml"
config_default_tmpl := templatesd / "config.default.mustache"
config_empty_tmpl := templatesd / "config.empty.mustache"

# Dependencies
# : These are used to verify the tool is in the PATH, will cause 'just' to fail if not
# : Call these like '{{ tool_name }}' in recipes
# : Will resolve to the absolute path of the tool if found in PATH

pyenv_root := env("PYENV_ROOT", env("HOME") + "/.pyenv")
mustache := require("mustache")
aws_sso := require("aws-sso")
python3 := require("python3")
python := pyenv_root + "/shims/python3"
packer := require("packer")
sponge := require("sponge")
pyenv := require("pyenv")
aws := require("aws")
awk := require("awk")
jq := require("jq")
yq := require("yq")
go := require("go")

# Env Vars
# : These are for sourcing values that are required but likely already in the ENV.
# : These can be overridden by supplying them to the dot-env file (see top of file 'set dotenv-path' )

token := if which("op") != "" { shell("op read " + env("CLOUD9_TOKEN") + " 2>/dev/null") } else { env("CLOUD9_TOKEN") }
environment := env("ENVIRONMENT", "dev")
debug := if env("DEBUG", "") != "" { "true" } else { "false" }

# === === === === === === === === === === === === === === === === === === === === === === ===
#  Recipes
# === === === === === === === === === === === === === === === === === === === === === === ===
# TODO: this might break due to 'token'?

# HTTP GET wrapper for Cloud9 API using Python. (NEEDS: "CLOUD9_TOKEN" env)
[group('cloud9')]
[group('core')]
[private]
get path:
    #!/usr/bin/env python3
    import sys, os, json, urllib.request, urllib.error

    rel_path = "{{ path }}"
    if not rel_path.startswith("/"):
        rel_path = "/" + rel_path
    url = "{{ endpoint }}" + rel_path

    req = urllib.request.Request(url)
    req.add_header("Authorization", f"Bearer {{ token }}")
    req.add_header("Accept", "*/*")

    try:
        with urllib.request.urlopen(req) as resp:
            data = resp.read()
            ct = resp.headers.get("Content-Type", "")
            # Pretty-print JSON if possible
            if "application/json" in ct or data.strip().startswith((b"{", b"[")):
                try:
                    parsed = json.loads(data)
                    print(json.dumps(parsed, indent=2))
                except Exception:
                    sys.stdout.buffer.write(data)
            else:
                sys.stdout.buffer.write(data)
    except urllib.error.HTTPError as e:
        sys.stderr.write(f"HTTP {e.code} {e.reason}\n")
        print("token: {{ token }}")
        print("path: {{ path }}")
        try:
            body = e.read()
            if body:
                sys.stderr.write(body.decode(errors="replace") + "\n")
        except Exception:
            pass
        sys.exit(1)
    except urllib.error.URLError as e:
        sys.stderr.write(f"Connection error: {e.reason}\n")
        sys.exit(2)

# Update a key/value in the config file
[group('core')]
[private]
update-config key val:
    #!/usr/bin/env bash
    echo "[ :: {{ key }} ]"
    v="{{ val }}" "{{ yq }}" -i '{{ key }} = env(v)' "{{ config }}"
    # If this recipe was called from within another recipe (ie its automated)
    if [ "{{ is_dependency() }}" = "true" ]; then
        v="{{ key }}" "{{ yq }}" -i '.metadata.automated += "env(v)"' "{{ config }}"
    fi

# Hydrate varfile templates using config.yaml
[group('template')]
hydrate-vars tgt:
    #!/usr/bin/env bash
    echo "[ hydrate: {{ tgt }} ]"
    "{{ mustache }}" "{{ config }}" "{{ templatesd }}/{{ tgt }}.mustache" > "{{ varfiles }}.{{ tgt }}.hcl"

# Hydrate Config.yaml file with standard tags
[group('template')]
config-tags: config-tags-git
    #!/usr/bin/env bash
    echo "[ config(tags) ]"
    just update-config ".tags.environment" "{{ environment }}"
    just update-config ".tags.Name" "ami-pipeline-{{ environment }}"

# Hydrate Config.yaml file with git related tags
[group('template')]
config-tags-git:
    #!/usr/bin/env bash
    echo "[ config(tags:git) ]"
    just update-config ".tags.owner.name" $(git config user.name)
    just update-config ".tags.owner.email" $(git config user.email)

# Hydrate Config.yaml file with relevant files/dirs
[group('template')]
config-paths:
    #!/usr/bin/env bash
    echo "[ config(dirs) ]"
    just update-config ".dirs.templates" "{{ templatesd }}"
    just update-config ".dirs.scripts" "{{ scriptsd }}"
    just update-config ".dirs.configs" "{{ configsd }}"
    just update-config ".dirs.bash" "{{ bashd }}"
    just update-config ".dirs.data" "{{ datad }}"
    just update-config ".dirs.vars" "{{ varsd }}"
    just update-config ".dirs.just" "{{ justd }}"
    just update-config ".dirs.root" "{{ root }}"
    just update-config ".dirs.pwd" $PWD
    just update-config ".dirs.py" "{{ pythond }}"
    just update-config ".dirs.jq" "{{ jqd }}"

# Ensure AWS tokens are refreshed
[group('core')]
[private]
authn_aws:
    #!/usr/bin/env bash
    set -euo pipefail
    echo "[ authn(aws) ]"
    if "{{ aws }}" sts get-caller-identity >/dev/null 2>&1; then
        expires=$(date -j -f "%Y-%m-%dT%H:%M:%S" "$("{{ aws }}" configure get x_security_token_expires)" +%s 2>/dev/null)
        now=$(date +%s)
        diff=$(($expires - $now))
        # Refresh if less than 15 minutes left
        if [ "$diff" -lt 900 ]; then
            echo "AWS credentials expiring soon ($diff s); refreshing SSO..."
            "{{ aws_sso }}" -config "{{ aws_sso_gov }}"
        fi
    else
        echo "AWS identity unavailable; invoking SSO login..."
        "{{ aws_sso }}" -config "{{ aws_sso_gov }}"
    fi

# Convert a YAML file to JSON
[group('core')]
[private]
as_json target:
    @yq --output-format json '.' {{ root }}/{{ target }}

cspell action="check":
    #!/usr/bin/env bash
    echo "[ cspell ]"
    words=$(npx -y cspell $(git ls-files) --no-exit-code --unique --config "{{ root }}/.cspell.json" --no-progress --no-summary --gitignore --words-only)
    words=($words)
    json=$(printf '%s\n' "${words[@]}" | jq -R . | jq -s .)
    if [ "{{ action }}" == "fix" ]; then
        jq --argjson json "$json" '.words = ((.words + $json) | sort | unique) ' "{{ root }}/.cspell.json" {{ if action == "fix" { "| sponge " + root + "/.cspell.json" } else { "" } }}
    else
        if [ ${#words[@]} -gt 0 ]; then
            echo "Run: 'just cspell fix' to add these words to .cspell.json"
            echo "$json"
        fi
    fi
