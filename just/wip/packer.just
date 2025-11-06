import './common.just'

## Packer

packerd := root + "/packer"
pkrvars := varfiles + ".pkrvars.hcl"
pkrvars_tmpl := templatesd / "pkrvars.mustache"
packer_files := packerd + "/"
packer_log := root + "/data/packer-debug.log"
build_args := if debug == "true" { "-debug " + env("BUILD_ARGS", "") } else { env("BUILD_ARGS", "") }
packer_build_target := if shell(yq + " '.ec2.ami.eks.version' " + config, "ami") == "null" { "base" } else { "eks" }

# Remove Packer artifacts and clear temporary workspace data.
[group('packer')]
packer-clean:
    #!/usr/bin/env bash
    echo "[ clean(packer) ]"
    rm -rf "{{ root }}"/data/tmp/*
    echo "" | "{{ mustache }}" "{{ templatesd }}/config.empty.mustache" > "{{ config }}"

# Run a placeholder test hook (currently does nothing).
[group('packer')]
packer-test:
    #!/usr/bin/env bash
    echo "No tests defined yet."

# Build repo documentation from source local readmes
[group('packer')]
packer-docs:
    #!/usr/bin/env bash
    echo "[ docs(packer) ]"
    packer docs "{{ packer_files }}"

# Initialize Packer templates in the repo.
[group('packer')]
packer-init:
    #!/usr/bin/env bash
    echo "[ init(packer) ]"
    "{{ packer }}" init "{{ packer_files }}"
    "{{ packer }}" validate -var-file "{{ pkrvars }}" "{{ packer_files }}"

# Format Packer templates in the repo.
[group('packer')]
[private]
packer-fmt:
    #!/usr/bin/env bash
    echo "[ fmt(packer) ]"
    "{{ packer }}" fmt "{{ packer_files }}"

# Hydrate Packer variable files from templates.
[group('packer')]
[group('template')]
hydrate-packer: (hydrate-vars "pkrvars")

# Build the AMI using Packer with resolved source and variable files.
[group('packer')]
packer-build: hydrate-packer
    #!/usr/bin/env bash
    echo "[ build(packer) ]"
    printf "{{ if debug == "" { "--> " + source_file() } else { "" } }}"
    {{ if debug == "true" { "export PACKER_LOG=1" } else { "" } }}
    {{ if debug == "true" { "export PACKER_LOG_PATH=" + packer_log } else { "" } }}
    "{{ packer }}" build {{ build_args }} -only '{{ packer_build_target }}.*' -var-file "{{ pkrvars }}" "{{ packer_files }}"

packer-debug id:
    #!/usr/bin/env bash
    aws ec2 describe-instances \
        --instance-ids "{{ id }}" \
        --query 'Reservations[].Instances[].{Id:InstanceId,Priv:PrivateIpAddress,ENI:NetworkInterfaces[0].NetworkInterfaceId,SGs:SecurityGroups[].GroupId,Subnet:SubnetId,VPC:VpcId}' \
        --output table
    aws ec2 describe-security-groups \
        --filters "Name=vpc-id,Values=$(yq '.vpc.id' "{{ config }}")" "Name=group-name,Values=packer_*" \
        --query 'SecurityGroups[].{Name:GroupName,Id:GroupId,Ingress:IpPermissions}' \
        --output json
    aws ec2 describe-security-groups \
        --filters "Name=vpc-id,Values=$VPC_ID" "Name=group-name,Values=packer_*" \
        --query 'SecurityGroups[].{Name:GroupName,Id:GroupId,Ingress:IpPermissions}' \
        --output json
