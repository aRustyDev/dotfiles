import '../.build/just/lib.just'

dot := xdg_config + "/git"
git := root + "/git"

# Reads configs/*, hydrates them, and writes to {{ xdg }}/git/configs/
install: mktree configs config bins templates allowed_signers

configs: mktree
    @for config in `lsd --classic {{git}}/configs`; do \
        cat configs/$config | envsubst | op inject -f -o "{{ dot }}/configs/$config"; \
    done
    @echo "Configs complete"

config: mktree
    @cat config | envsubst | op inject -f -o "{{ dot }}/config"
    @echo "Config complete"

allowed_signers: mktree
    @for signer in `lsd --classic {{git}}/allowed_signers`; do \
        cat allowed_signers/$signer | envsubst | op inject -f -o "{{ dot }}/allowed_signers/$signer"; \
    done
    @echo "Authorized signers complete"

mktree:
    @mkdir -p "{{ dot }}"/{templates,configs,bin,allowed_signers}

bins: mktree
    @cp -r bin/* "{{ dot }}/bin"
    @echo "Bins complete"

templates: mktree
    @cp -r templates/* "{{ dot }}/templates"
    @echo "Templates complete"
