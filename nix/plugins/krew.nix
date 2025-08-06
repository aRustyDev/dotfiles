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
    ];
  };
}
