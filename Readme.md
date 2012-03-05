# vagrant-vbguest

`vagrant-vbguest` is a [Vagrant](http://vagrantup.com) plugin wich automatically installes the host's VirtualBox Guest Additions on the guest system.

## Installation

Requires vagrant 0.9.4 or later

    gem install vagrant-vbguest

or, using vagrant's gem wrapper

    vagrant gem install vagrant-vbguest

Compatibly for vagrant 0.8 is provided by version 0.0.3 (which lacks a bunch of new options)

## Configuration / Usage

If you're lucky, `vagrant-vbguest` does not require any configurations. 
Hoever, here is an example for your `Vagrantfile`:

    Vagrant::Config.run do |config|
      # we will try to autodetect this path. 
      # However, if we cannot or you have a special one you may pass it like:
      # config.vbguest.iso_path = "#{ENV['HOME']}/Downloads/VBoxGuestAdditions.iso"
      # or
      # config.vbguest.iso_path = "http://company.server/VirtualBox/$VBOX_VERSION/VBoxGuestAdditions.iso"
      
      # set auto_update to false, if do NOT want to check the correct additions 
      # version when booting this machine
      config.vbguest.auto_update = false
      
      # do NOT download the iso file from a webserver
      config.vbguest.no_remote = true
    end
    
### Config options

* `iso_path` : The full path or URL to the VBoxGuestAdditions.iso file. <br/>
The `iso_path` may contain the optional placeholder `$VBOX_VERSION` for the detected version (e.g. `4.1.8`).
The URI for the actual iso download reads: `http://download.virtualbox.org/virtualbox/$VBOX_VERSION/VBoxGuestAdditions_$VBOX_VERSION.iso`<br/>
vbguest will try to autodetect the best option for your system. WTF? see below.
* `auto_update` (Boolean, dafault: `true`) : Whether to check the correct additions version on each start (where start is _not_ resuming a box).
* `no_install` (Boolean, default: `false`) : Whether to check the correct additions version only. This will warn you about version mis-matches, but will not try to install anything.
* `no_remote` (Boolean, default: `false`) : Whether to _not_ download the iso file from a remote location. This includes any `http` location!

### ISO autodetection

`vagrant-vbguest` will try to autodetect a VirtualBox GuestAdditions iso file on your system, which usually matches your installed version of VirtualBox.
If it cannot find one, it downloads one from the web (virtualbox.org). Those places will be checked in order:

1. Checks your VirualBox "Virtual Media Maganger" for a DVD called "VBoxGuestAdditions.iso"
2. Guess by your operating system:
  * for linux : `/usr/share/virtualbox/VBoxGuestAdditions.iso`
  * for Mac : `/Applications/VirtualBox.app/Contents/MacOS/VBoxGuestAdditions.iso`
  * for Windows : `%PROGRAMFILES%/Oracle/VirtualBox/VBoxGuestAdditions.iso`
    
You may also run the installer manually:

    $ vagrant vbguest [vm-name] [-f|--force] [-I|--no-install] [-R|--no-remote] [--iso VBoxGuestAdditions.iso]

## Knows Issues

* The installer script, which mounts and runs the GuestAdditions Installer Binary, works on linux only. Most likely it will run on most unix-like plattform. 
* The installer script requires a directory `/mnt` on the host system
* On multi vm boxes, the iso file will be downloaded for each vm