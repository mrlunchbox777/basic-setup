# README

The `index.json` will function as a list of all of the packages that basic-setup is going to manage. The format will be [standaradized](#json-format). JSON was selected because `jq` is more widely installed than yq for manipulation of files with minimal requirements.

[Supported Labels](#supported-labels)

[Supported Package Managers](#supported-package-managers)

## JSON Format

Below you'll find the [schema](#json-schema) that the index.json will take as well as an [example](#json-example).

### JSON Schema

```js
{
    /**
    * The array of managed package objects.
    * @type Object[]
    */
    "packages": [
        {
            /**
            * The friendly description of the package.
            * @type string
            */
            "description": null,
            /**
            * The install page for the package.
            * This will be given as the fallback
            * if the package or package manager
            * isn't found.
            * @type string
            */
            "install-page": null,
            /**
            * Labels that will be used to group,
            * filter, and identify packages. Check
            * documentation for a list of supported labels.
            * @type string[]
            */
            "labels": [],
            /**
            * The friendly name of the package.
            * @type string
            */
            "name": null,
            /**
            * Array of package instance objects.
            * @type Object[]
            */
            "package-instances": [
                {
                    /**
                    * The string representing additional
                    * arguments that should be used to
                    * install the package.
                    * @type string
                    */
                    "arguments": null,
                    /**
                    * If the package is currently supported.
                    * @type boolean
                    */
                    "enabled": false,
                    /**
                    * The name of the package manager for
                    * this package instance. Check documentation
                    * for a list of supported package managers.
                    * @type string
                    */
                    "manager-name": null,
                    /**
                    * Any additional notes for the package instance.
                    * @type string
                    */
                    "notes": null,
                    /**
                    * The canonical name of the package instance
                    * on the package manager.
                    * @type string
                    */
                    "package-name": null
                }
            ]
        }
    ]
}
```

### JSON Example

```json
{
    "packages": [
        ...
        {
            "description": "This is an example package.",
            "install-page": "https://example.com/install/",
            "labels": [
                ...
                "core",
                "example",
                ...
            ],
            "name": "example-package",
            "package-instances": [
                ...
                {
                    "arguments": "--arg 'for stuff'",
                    "enabled": true,
                    "manager-name": "apt-get",
                    "notes": "The arg argument is required because I said so.",
                    "package-name": "exmpl-pkg"
                },
                ...
            ]
        },
        ...
    ]
}
```

### Template

You can find a template for adding a package [here](/resources/install/package-template.json)

## Supported Labels

This is intended to be an exhaustive list and explanation of `labels`` used for `packages` in `index.json`. If new labels need to be created and used, they should be added here as well.

* `amd64-only`
    * If this package is only supported on amd64 architectures.
* `arm64-only`
    * If this package is only supported on arm64 architectures.
* `big-bang`
    * Required packages that are used for [big bang](https://github.com/DoD-Platform-One/big-bang) development and operations.
* `big-bang-full`
    * All packages used for [big bang](https://github.com/DoD-Platform-One/big-bang) development and operations.
* `core`
    * If this package should always be installed.
* `darwin-only`
    * If this package is only supported on Mac operating systems.
* `entertainment`
    * If this package is for entertainment purposes.
* `windows-only`
    * If this package is only supported on Windows operating systems.
* `linux`
    * If this package is only supported on Linux operating systems.

## Supported Package Managers

These are the main package managers we are looking to support. These should be included in the `package-instances` for `packages` in the `index.json`.

* `apt-get`
    * [Find packages](https://packages.ubuntu.com/)
    * [Github](https://github.com/Debian/apt)
* `brew`
    * [Find formulae and casks](https://formulae.brew.sh/)
    * [Install page](https://brew.sh/)
* `pacman`
    * [Find packages](https://archlinux.org/packages/)
    * [Wiki page](https://wiki.archlinux.org/title/pacman)
* `rpm`
    * [rpm doesn't have a browser-based browser :(](https://serverfault.com/questions/239205/official-online-rpm-package-browser-search-for-centos)
        * [3rd party search](https://rpmfind.net/linux/rpm2html/search.php)
    * [Website](https://rpm.org/)
    * Don't forget that [yum uses rpm](https://phoenixnap.com/kb/rpm-vs-yum)
* `winget`
    * [winget doesn't have a browser-based browser :(](https://www.reddit.com/r/Windows10/comments/gvfoqr/we_made_a_website_for_browsing_winget_packages/)
        * [3rd party search](https://winget.run/)
    * [winget docs](https://learn.microsoft.com/en-us/windows/package-manager/winget/)
