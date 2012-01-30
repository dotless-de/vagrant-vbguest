# vagrant-vbguest

`vagrant-vbguest` is a [Vagrant](http://vagrantup.com) plugin wich automatically installes the host's VirtualBox Guest Additions on the guest system.

## Installation

Requires vagrant 0.9.0

    gem install vagrant-vbguest

Compatibly for vagrant 0.8 is provided by version 0.0.3

## Configuration / Usage

In your `Vagrantfile`:

    Vagrant::Config.run do |config|
      # we will try to autodetect this path. 
      # However, if we cannot or you have a special one you may pass it here
      config.vbguest.iso_path = '/Applications/VirtualBox.app/Contents/MacOS/VBoxGuestAdditions.iso'
      
      # set auto_update to false, if do NOT want to check the correct additions 
      # version on each 'vagrant up' (default: true)
      config.vbguest.auto_update = false
    end
    
You may also run the installer manually:

    $ vagrant vbguest [vm-name] [-f|--force]

## Knows Issues

* The installer script, which mounts and runs the GuestAdditions Installer Binary, works on linux only. Most likely it will run on most unix-like plattform. 
* The installer script requires a directory `/mnt` on the host system