{
  # https://github.com/LnL7/nix-darwin
  description = "Example Darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {
    self,
    nix-darwin,
    nixpkgs,
    home-manager,
  }: {
    krewPlugins = with nixpkgs.krewPlugins; [
      kubectl
      kubectx
      kubens
      kubeseal
      kustomize
      helm
      jq
      yq
      rook-ceph
      kubectl-lint
      kubelogin
      kubectl-topology
      kubectl-tree
      kubectl-graph
      kubectl-dig
      kubectl-warp
      kubectl-who-can
      kubectl-kubesec
      ksniff
      kube-profefe
      kubectl-swiftnp
      kubectl-dfi
      kubectl-df-pv
      # kubectl-tsh # TODO: create this
      # kubectl-tctl # TODO: create this
      kubectl-texec
      Pod-Dive
      kubectl-use
      km
      kubectl-grep
      kubectl-rotate-pods
      kube-capacity
      kubectl-tmux-logs
      kubectl-doctor
      kubectl-rainbow
      konfig
      kubectl preflight
      kubectl support-bundle
      kubectl-cilium
      kubectl-carbonetes-scan # TODO: Extend this to support other tools
      kubectl-cyclonus
      kubectl-view-webhook
      kubectl-datree
      kubectl-translate
      kubectl-irsa
      cert-manager
      capture
      blame
      cluster-compare
      cnf
      community-images
      commander
      cost
      dds
      debug-pdb
      dumpy
      explore
      exec-as
      gadget
      history
      kubescape
      kubesec-scan
      log2rbac
      minio
      node-logs
      node-admin
      node-shell
      open-svc
      netobserv
      node-restart
      nodegizmo
      portal
      popeye
      nodepools
      passman
      permissions
      pexec
      pod-shell
      pod-dive
      pv-migrate
      pvmigrate
      pv-mounter
      rbac-lookup
      rbac-tool
      rbac-view
      retina
      schemahero
      score
      service-tree
      shell-ctx
      shovel
      sick-pods
      strace
      starboard
      sniff
      snap
      sudo
      topology
      unused-volumes
      unlimited
      trace
      view-utilization
      virt
      vpa-recommendation
      whoami
      browse-pvc
      bd-xray
      aws-auth
    ];
  };
}
