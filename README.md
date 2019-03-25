# puppet_module_documenter
This script can be used to recursively create a puppet module documentation of every module in a defined directory. It will examine the git top directory and then run over every module in the modules folder.

```
control-repo (GIT Repository)
|-- .git
|
|-- bin
|
|-- manifests
|   |-- site.pp
|-- site
    |-- profile_apache
        |-- manifests
            |-- common.pp
            |-- reverse_proxy_v1.pp
        |-- README.md (will be generated)
    |-- profile_nfs
        |-- manifests
        |-- README.md (will be generated)
```

The `puppet strings` command to generate a documentation of a puppet module uses the tags defined in the header of each puppet manifest file. It could look something like this:
```
# profile_apache::common
#
# Configures a basic apache setup.
#
# @summary This class can be used to setup default
#   apache configuration.
#
# @param cert_key_name [String]
#   The name or the certificate and key files
# @param ssl_cert [String]
#   The ssl_cert for the proxy to use
#   @note If no cert is defined the default cert
#     from the common.yml will be used.
#
# @example
#   include profile_apache::common
```

This would produce a created documentation like this [example profile_apache](README_profile_apache.md).

## Requirements
To use this script the following components are needed.
* puppet binary
* puppet strings installed
* puppet development kit (pdk)
* git

## Customization
Adjust the following lines to match your needs:
* Adjust the `MODULEDIRNAME` to define the name of the folder which contains all modules. (default: "site") 
```
GITBIN="/usr/bin/git"

MODULEDIRNAME="site"
PUPPETBIN="/opt/puppetlabs/bin/puppet"
DOCFORMAT="markdown"
DOCFILE="README.md"
PUPPETARGS="strings generate --format $DOCFORMAT --out $DOCFILE"
PUPPETRUN="$PUPPETBIN $PUPPETARGS"

PDKBIN="/usr/local/bin/pdk"
PDKARGS="update --force"
PDKRUN="$PDKBIN $PDKARGS"
```

## Usage
```
~/github/puppet_module_documenter$ bash puppet_code_docu.sh --help
Usage: puppet_code_docu.sh [-h|--help] [-v|--verbose] [-V|--version]

  -h|--help           Print this help text
  -v|--verbose        Run the script in verbose mode
  -V|--version        Print the version of this script
```
