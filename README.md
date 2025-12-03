# devsetup

This repository is used for setting up development environments.

It's built to setup an entire development system from host machines, docker containers, VM's, and remote machines.

The playbooks here are designed to be used locally and over SSH.  In addition, a collection of scripts used to setup bare systems is also stored here.

## Requirements

For this repository `make`, `uv` and `mise` are required dependencies on all systems.

Homebrew is required to be installed on MacOS/Darwin systems.

Run
```bash
scripts/bootstrap.sh
```
to install these depkendencies.

Note: `uv` and `mise` are installed to `~/.local/bin` by default, and this is checked by bootstrap test.

## Setup

```
make install-deps
make test
```

---

## Identity

Each portal (laptop, desktop) will have it's own ed25519 ssh key pair.

They must be protected with strong passwords (dice with high 80bit+ entropy).

These are per device and per user identities.

## Network

In addition to SSH identities, all devices have a unique WireGuard key.  All personal networking will be protected by these WireGuard keys.

In addition, firewalls will limit peer to peer communication where desired.

### Topology

A Hetnzer remote instance serves as a WireGuard endpoint for peers to find each other and communciate through.

Peers will also connect directly when they can.
