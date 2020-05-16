# bKit
bKit Client

## Installation
- git clone https://github.com/jvverde/bKit.git bKit

### Windows
On windows it runs over cygwin, so the first thing to do is to install it
- Open a CMD shell 
- cd to bKit directory
- run ``setup.bat``. This will install cygwin automatically with required packages as well shadowspan

### Linux
  Don't require any action

## Usage
If run on windows open a CMD shell, go to bkIt directory and then run bash.bat.
This will open a bash shell and we are now using cygwin

The first thing to do is to point to a bKit server

```./init.sh serveraddress
```

This operations can be repeat as many times as needed/desired. Every time it runs a new key-pair is changed with server using Diffie-Hellman algorithm, and a new password is computed. So it will be a good pratice to run it frequently.

To backup a file or a directory use bkit.sh script

```./bkit.sh directory
```

In order to check whats file or directory are changed sinde last backup

```./dkit.sh directory
```

The restore from last backup use rkit.sh

```./rkit.sh directory
```

If we don't want to restore to de original location, but instead recovery to a another location user --dst option 

```./rkit.sh --dst=newlocationdirectory directory
```

On cases where you we would like to see what version are in the backup we can use vkit.sh

```./vkit.sh directory
```

This will return a list of modified versions existing on backup server, ex:

```$ ../vkit.sh c:/bkit
  Please wait... this may take a while
  @GMT-2019.11.28-22.33.14 have a last modifed version at 2019/11/19-21:13:55 of bkit
  @GMT-2020.01.18-18.25.50 have a last modifed version at 2020/01/18-14:12:49 of bkit
  @GMT-2020.02.13-14.01.47 have a last modifed version at 2020/02/13-14:01:44 of bkit
  @GMT-2020.03.03-21.46.38 have a last modifed version at 2020/03/03-21:46:31 of bkit
  @GMT-2020.03.23-11.49.05 have a last modifed version at 2020/03/13-15:00:02 of bkit
  @GMT-2020.03.29-20.15.09 have a last modifed version at 2020/03/29-21:14:28 of bkit
  @GMT-2020.04.02-09.35.40 have a last modifed version at 2020/03/30-13:31:50 of bkit
  @GMT-2020.04.05-23.57.56 have a last modifed version at 2020/03/31-00:29:49 of bkit
  @GMT-2020.04.07-13.43.21 have a last modifed version at 2020/04/06-15:17:19 of bkit
  @GMT-2020.04.08-06.23.52 have a last modifed version at 2020/04/06-15:17:19 of bkit
  @GMT-2020.05.13-11.52.21 have a last modifed version at 2020/04/13-12:30:52 of bkit
```

Then if you want recovery/restore the version of February, just use the option snap on rkit.sh

```./rkit.sh --snap="@GMT-2020.02.13-14.01.47" c:/bkit
```

After each restore a directory with name .before-restore-on-2020-05-16T14-56-49.bkit will appear under the recovery directory. Inside this directory we will find all the files modified (or deleted if option was used) by restore operation.

```./rkit.sh --dry-run --snap="@GMT-2020.02.13-14.01.47" c:/bkit
```

If we want to see first what will be restored just use the option --dry-run

All the above examples use the default server, which can be checked with

```./server.sh
```

To change to a new server use the same command with option -s

```./server.sh -s newserver
```
