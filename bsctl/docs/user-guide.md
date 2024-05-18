# User Guide

The bsctl Command line interface(CLI) tool is designed to simplify development, deployment, auditing and troubleshooting of the BigBang product in a kubernetes cluster. The bsctl repository is mirrored to PartyBus code.il2.dso.mil where a Mission DevOps pipelne is run and a package is built and pushed back to repo1.dso.mil. The code has passed security scans and is eligible to receive a certificate to field(CTF).

## Installation

1. `curl -1fLsq https://raw.githubusercontent.com/mrlunchbox777/basic-setup/main/basic-setup.sh | sh`

## Usage

The bsctl tool is self documenting so only a few simple examples are included here. The bsctl commands work similar to other well known tools such as `kubectl`

```bash
# get help for commands
bsctl -h
# get bsctl version
bsctl version
```

## Command completion

To enable command completion using the tab key, ensure that bsctl completion script gets sourced in all your shell sessions. Execute the following command for details on how to generate the completion script and load it in the supported shells:

```
bsctl completion -h
```

## Configuration Files

NOTE: If you are using this, you should be encrypting your home directory at a minimum

You can define a configuration file named `config` in `~/.bsctl`, `/etc/bsctl`, or `./`. This file should be valid YAML, will only contain root level key-value-pairs, and will be read to provide environment variables.

Example:

```yaml
"basic-setup-repo": "/home/johndoe/.basic-setup/basic-setup"
"other-var": "other value"
```

### Encrypting Home Directory

- [Ubuntu](https://askubuntu.com/questions/1335006/what-is-the-recommended-method-to-encrypt-the-home-directory-in-ubuntu-21-04) - also just on os install /home/{{username}}/
- [Red Hat](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/9/html/security_hardening/encrypting-block-devices-using-luks_security-hardening) /home/{{username}}/
- [MacOS](https://support.apple.com/guide/mac-help/protect-your-mac-information-with-encryption-mh40593/mac#:~:text=In%20the%20Finder%20on%20your,password%20in%20a%20safe%20place.) /home/{{username}}/
- [Windows](https://support.microsoft.com/en-us/windows/how-to-encrypt-a-file-1131805c-47b8-2e3e-a705-807e13c10da7) - also disk level with tpm in settings if you have pro or better C:\Users\{{username}}\
