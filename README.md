# rmirror
[![GitHub issues](https://img.shields.io/github/issues/patricknbyrne/rmirror.svg)](https://github.com/PatrickNByrne/rmirror/issues)
[![license](https://img.shields.io/github/license/patricknbyrne/rmirror.svg)](https://github.com/PatrickNByrne/rmirror/blob/master/LICENSE)


##### A simple bash script to leverage cron, rsync, and email


## Requirements

* Bash
* rsync
* mail
* postfix | sendmail | exim | other MTA


## Installation

```
git clone https://github.com/PatrickNByrne/rmirror.git
```


## Usage

```
    Usage: rmirror.sh [OPTIONS] -s <source> -d <destination>

    OPTIONS

      -h --help         Print this message
      -V --version      Print Version 
      -v --verbose      Output to stdout and stderr instead of log file
      -e --email        E-mail Address [default: root@localhost]
      -s --source       Source
      -d --dest         Destination
      -r --rflags       Rsync flags [default: -av --delete]
      -l --logfile      Log file [default: <scriptdir>/log/rmirror.log]
      -m --max-deletes  The maximum number of deletes [default: 10]
      -x --exclude      Specify the exclude file. One file/dir per line 
```


## History

* V0.1.0 - Initial release
* V1.0.0 - Initial production release
* V1.1.0 - Add exclude file option

## License

* Apache 2.0


