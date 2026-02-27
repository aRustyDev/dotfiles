#!/usr/bin/env zsh

# kubectl aliases
alias k='kubectl'
alias ka='kubectl --all-namespaces'
alias kg='kubectl get'
alias kag='kubectl get --all-namespaces'
alias kgp='kubectl get pods'
alias kagp='kubectl get pods --all-namespaces'
alias kgs='kubectl get services'
alias kags='kubectl get services --all-namespaces'
alias kgd='kubectl get deployments'
alias kagd='kubectl get deployments --all-namespaces'
alias kgn='kubectl get nodes'
alias kgi='kubectl get ingress'
alias kgc='kubectl get configmaps'
alias kgsec='kubectl get secrets'

# Describe shortcuts
alias kd='kubectl describe'
alias kdp='kubectl describe pod'
alias kds='kubectl describe service'
alias kdd='kubectl describe deployment'
alias kdn='kubectl describe node'

# Logs
alias kl='kubectl logs'
alias klf='kubectl logs -f'

# Exec
alias kex='kubectl exec -it'

# Apply/Delete
alias kaf='kubectl apply -f'
alias kdf='kubectl delete -f'

# Context/Namespace (with kubectx/kubens)
alias kx='kubectx'
alias kns='kubens'

# k9s
alias k9='k9s'

# Kubecolor (colorized kubectl)
if command -v kubecolor &>/dev/null; then
    alias kubectl='kubecolor'
fi
