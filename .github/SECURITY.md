# Security

The code in basic-setup repository is always used at your own risk, all other statements are just opinions.

## In Development

This project is currently in beta with no real versions and should only be used in specifically approved use cases in highly sensitive environments.

## Implementation

Most of the scripts and aliases should be fine as they only affect the local environment.

### Current consideration

* Specifically [environment-validation](/shared-scripts/environment/validation.sh) can call for external installs that may or may not be approved in secure environments.
* [curl-commands](/shared-scripts/environment/curl-commands/) (runs and/or installs) (scripts and/or binaries) from URLs.

There may be others, but the above are the biggest considerations.

### Future goals

These are not currently supported, but should eventually be supported.

* Local interpretation exclusivity should be supported, then the only risk is the code on the system and this repo.

## Reporting

To report a security vulnerability send an email to mrlunchbox777@gmail.com with the following information:

```markdown
# Security Vulnerability Report

## Version
_The vulnerable version(s) of the software_

## Environment
_At a minimum please include OS_

## Relevant CVE
_If applicable_

## What is Vulnerable?
_Provide as much detail as possible_

## Steps to Reproduce
_If not applicable please provide why_
```
