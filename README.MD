
<p align="center">
  <img src="assets/kubev-logo-light-mode.png#gh-light-mode-only" width="700px" />
  <img src="assets/kubev-logo-dark-mode.png#gh-dark-mode-only" width="700px" />
</p>

# Kubermatic Virtualization Downloader

`kubev-downloader` is a command-line tool for downloading [Kubermatic Virtualization](https://www.kubermatic.com/products/kubermatic-virtualization/) from Kubermatic's OCI registry. It handles authentication, artifact retrieval, and local installation in a single command.

This repository hosts the official releases of `kubev-downloader`. Binaries are available on the [Releases page](https://github.com/kubermatic/kubev-downloader/releases).

---

## Table of Contents

- [Installation](#installation)
- [Getting Credentials](#getting-credentials)
- [Getting Kubermatic Virtualization](#getting-kubermatic-virtualization)
- [CLI Reference](#cli-reference)

---

## Installation

The fastest way to install `kubev-downloader` is with the installation script:

```bash
curl -sfL https://get.virtualization.k8c.io | sh
```

This downloads the latest release and installs the `kubev-downloader` binary automatically. No additional setup is required.

### Manual Installation

If you prefer to install manually, download the binary for your platform from the [Releases page](https://github.com/kubermatic/kubev-downloader/releases):

```bash
curl -LO https://github.com/kubermatic/kubev-downloader/releases/download/v<version>/kubev-downloader_<version>_<os>_amd64.tar.gz
tar -xzf kubev-downloader_<version>_<os>_amd64.tar.gz
sudo mv kubev-downloader /usr/local/bin/
```

---

## Getting Credentials

`kubev-downloader` authenticates against Kubermatic's OCI registry using a username and password. To obtain your credentials, contact [sales@kubermatic.com](mailto:sales@kubermatic.com).

Once you have your credentials, store them as environment variables:

```bash
export USERNAME=<your-username>
export PASSWORD=<your-password>
```

---

## Getting Kubermatic Virtualization

`kubev-downloader` is the tool used to download the Kubermatic Virtualization binary from Kubermatic's OCI registry.

### Download the Latest Release

By default, running `kubev-downloader` fetches the latest available release of Kubermatic Virtualization and installs it in the current working directory:

```bash
kubev-downloader --username $USERNAME --password $PASSWORD
```

A successful run produces output similar to the following:

```
INFO[12:42:11 CET] Initializing Kubermatic Virtualization Downloader  output=. tag=v1.1.0
INFO[12:42:11 CET] Starting artifact retrieval from our OCI registry  tag=v1.1.0
INFO[12:42:12 CET] Retrieving the binary artifact
INFO[12:42:24 CET] Downloading binary artifact                   digest="sha256:0ffdfa591b57ee14963c846a86a2ecfc931a20976c8812f7bd13731ffb708430" size="78.99 MB"
INFO[12:42:24 CET] Binary artifact downloaded successfully       size="78.99 MB"
INFO[12:42:24 CET] Installing binary                             path=kubermatic-virtualization permissions=0755 size_bytes=82828164
INFO[12:42:24 CET] Installation completed successfully           binary=kubermatic-virtualization path=.
```

Once complete, the `kubermatic-virtualization` binary is available in your current directory.

### Download a Specific Version

Use the `--tag` (or `-t`) flag to download a specific version of Kubermatic Virtualization:

```bash
kubev-downloader --username $USERNAME --password $PASSWORD --tag v1.1.0
```

---

## CLI Reference

| Flag | Short | Required | Description |
|------|-------|----------|-------------|
| `--username` | | ✅ | Kubermatic registry username |
| `--password` | | ✅ | Kubermatic registry password |
| `--tag` | `-t` | | Version of Kubermatic Virtualization to download (defaults to latest) |
| `--output` | `-o` | | Directory where the binary will be installed (defaults to current directory) |

