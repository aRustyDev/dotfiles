install_kube_plugin(){
    # If kubectl installed and krew installed
    if command -v kubectl && [[ -n $KREW_ROOT || -d $HOME/.krew/bin ]]; then
        kubectl krew install $1
    fi
}
