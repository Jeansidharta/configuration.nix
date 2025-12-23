# Behavior modules

These modules provide behavior-oriented configuration. That is, a module named
`cli.nix` would provide anything a machine needs for a CLI environment; a module
named `desktop.nix` would provide the tools and packages to build a desktop
environment; and a module named `ssh-server.nix` would provide the tools needed
for the host to become an ssh server.

A host is supposed to import whatever modules it want to have the behavior it
needs. So a desktop host with some server functionality would import `cli.nix`,
`desktop.nix` and `ssh-server.nix`.
