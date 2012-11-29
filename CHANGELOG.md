## 0.5.1 (2012-11-30)

 - Fix: Provisioning will not run twice when rebooted due
   to incomplete GuestAdditions installation [GH-27]
   (thanks @gregsymons for pointing)

## 0.5.0 (2012-11-19)

  - Box will be rebooted if the GuestAdditions installation
    process does not load the kernel module [GH-25], [GH-24]
  - Adds this Changelog

## 0.4.0 (2012-10-21)

  - Add global configuration options [GH-22]
  - Add `iso_path` option `:auto` to rest a previously
    configured path [GH-22]

## 0.3.5

  - Fix iso detection for windows hosts [GH-20]

## 0.3.4

  - Fix installer shell script invocation [GH-18]

## 0.3.3

  - Add Fedora to the list of supported plattforms [GH-17]
  - Add system package update (`apt-get update`) to the
    debian installer if package installation fails [GH-16]
  - Drop dependency on `vagrant` gem [GH-15]

## 0.3.2

  - Stop GuestAdditions installation and fail with an error
    when installation of dependency packes fails [GH-13]

## 0.3.1

  - Ruby 1.8.7 compatibility [GH-12]

## 0.3.0

  - Removed dependency to the `virtualbox` gem by using 
    `vagrant`s vm driver [GH-8]

## 0.2.1

  - Typo fixes in readme and internal renamings. [GH-9], [GH-7]

## 0.2.0

  - Makes a guess on where to look for a `VBoxGuestAdditions.iso` file
    based on the host system (when VirtualBox does not tell). [GH-6]
  - Adds command line options `--no-install`, `--no-remote`, `--iso`
  - Requires vagrant v0.9.4 or later

## 0.1.1

  - Fix vagrant 0.9.4 compatibility [GH-4]

## 0.1.0

  - Vagrant 0.9 compatibility (drops 0.8 support) [GH-3]

## Previous (≤ 0.0.3)

  - Vagrant 0.8 support