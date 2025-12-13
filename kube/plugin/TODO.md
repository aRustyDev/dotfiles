---
id: 02c42302-0450-4b0a-aafb-0e4637df48b5
title: TODO
created: 2025-12-13T00:00:00
updated: 2025-12-13T16:38
project: dotfiles
scope: kubernetes
type: plan
status: 🚧 in-progress
publish: false
tags:
  - kubernetes
  - kubectl-plugin
  - todo
aliases:
  - TODO
related: []
---

# TODO

Basic Commands (Beginner):
  kubectl create
  kubectl expose
  kubectl run
  kubectl set

Basic Commands (Intermediate):
  kubectl explain
  kubectl get
  kubectl edit
  kubectl delete

Deploy Commands:
  kubectl rollout
  kubectl scale
  kubectl autoscale

Cluster Management Commands:
  kubectl certificate
  kubectl cluster
  kubectl cordon
  kubectl drain

Troubleshooting and Debugging Commands:
  kubectl describe
  kubectl attach
  kubectl exec
    - can I specify "interactive"? does it provide suggestions?
  kubectl port-forward
    - can I specify / target WS, UDP, TCP, etc?
  kubectl proxy
  kubectl cp
  kubectl auth
  kubectl debug
  kubectl events

Advanced Commands:
  kubectl diff
  kubectl patch
  kubectl wait
  kubectl kustomize

Settings Commands:
  kubectl label
  kubectl annotate
  kubectl completion

Subcommands provided by plugins:
  kubectl krew
  kubectl ctx
  kubectl ns

Other Commands:
  kubectl api-resources
  kubectl api-versions
  kubectl config
  kubectl plugin
  kubectl version
