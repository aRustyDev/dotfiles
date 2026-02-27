import 'common.just'

# === === === Variables === === ===

generated_ssh_config := configsd + "/ssh"
ssh_includes := "Include " + generated_ssh_config
ssh_config := dotssh + "/config"
dotssh := env("HOME") + "/.ssh"
awk_config_to_json := awkd + "/ssh-config-to-json.awk"
jq_get_sshid := jqd + "/ssh-identity-file.jq"
insert_at := shell("grep -n -m1 -v '^# ' " + ssh_config + " | cut -d: -f1")

# === === === Command Strings === === ===
# : Convert SSH Config to JSON to parse

convert_ssh_config_to_json := awk + " -f " + awk_config_to_json + " " + ssh_config

# : Get SSH IdentityFile for bastion host

extract_identityfile_path := jq + " --arg bastion '" + ssh_bastion + "' -s -r -f " + jq_get_sshid

# === === === Dynamic Values === === ===
# : Get bastion host from config.yaml

ssh_bastion := shell(yq + " e '.ssh.bastion.host' " + config)

# : Convert SSH config to JSON array of ssh Host entries
# : Then extract just the IdentityFile entry

ssh_identityfile_path := shell(convert_ssh_config_to_json + " | " + extract_identityfile_path)

# === === === === === === === === ===
#               Recipes
# === === === === === === === === ===

# Clean up SSH related changes
[group('ssh')]
ssh-clean:
    #!/usr/bin/env bash
    echo "[ clean(ssh) ]"
    sed -i '' '\|{{ ssh_includes }}|D' "{{ ssh_config }}"

# Hydrate SSH config file from template
[group('ssh')]
hydrate-ssh: config-ssh

# # Initialize SSH config file with include statement
# [group('ssh')]
# ssh-init:
#     #!/usr/bin/env bash
#     mkdir -p "{{ dotssh }}"
#     touch "{{ ssh_config }}"
#     if ! grep -q '{{ ssh_includes }}' '{{ ssh_config }}'; then
#         sed -i '' '{{insert_at}}i\
#     {{ ssh_includes }}' '{{ ssh_config }}'
#     fi

# Update Config.yaml file with ssh configs
[group('template')]
config-ssh:
    #!/usr/bin/env bash
    echo "[ config(ssh) ]"
    just update-config ".ssh.bastion.user" $(whoami)
    just update-config ".ssh.bastion.pub" "{{ ssh_identityfile_path }}"
    just update-config ".ssh.bastion.key" "{{ ssh_identityfile_path }}"
