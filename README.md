# check_freenas
[![GitHub issues](https://img.shields.io/github/issues/patricknbyrne/check_freenas.svg)](https://github.com/PatrickNByrne/check_freenas/issues)
[![license](https://img.shields.io/github/license/patricknbyrne/check_freenas.svg)](https://github.com/PatrickNByrne/check_freenas/blob/master/LICENSE)

##### A Nagios type plugin to query the Freenas API for volume and disk status

## Requirements

* Bash
* rsync
* mail & postfix | sendmail | exim | another MTA

## Installation

```
git clone https://github.com/PatrickNByrne/rmirror.git
```


## Usage

```
    Usage: rmirror.sh [OPTIONS] -s <source> -d <destination>

    OPTIONS

      -h --help       Print this message
      -V --version    Print Version 
      -v --verbose    Output to stdout and stderr instead of log file
      -e --email      E-mail Address [default: root@localhost]
      -s --source     Source
      -d --dest       Destination
      -r --rflags     Rsync flags [default: -av --delete]
      -l --logfile    Log file [default: <scriptdir>/log/rmirror.log]
```

#### Notes


## History

* V0.1.0 - Initial release

## License

* Apache 2.0

