# vagrant-vbguest

*vagrant-vbguest* is a [Vagrant](http://vagrantup.com) plugin which automatically installs the host's VirtualBox Guest Additions on the guest system.

[![Join the chat at https://gitter.im/dotless-de/vagrant-vbguest](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/dotless-de/vagrant-vbguest?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)
[![Code Climate](https://codeclimate.com/github/dotless-de/vagrant-vbguest.svg)](https://codeclimate.com/github/dotless-de/vagrant-vbguest)
[![Dependency Status](https://gemnasium.com/dotless-de/vagrant-vbguest.svg)](https://gemnasium.com/dotless-de/vagrant-vbguest)
[![Inline docs](http://inch-ci.org/github/dotless-de/vagrant-vbguest.svg?branch=master)](http://inch-ci.org/github/dotless-de/vagrant-vbguest)
[![Gem Version](https://badge.fury.io/rb/vagrant-vbguest.svg)](https://badge.fury.io/rb/vagrant-vbguest)


## Installation

Requires vagrant 0.9.4 or later (including 1.x)

### Vagrant ≥ 1.1

```bash
$ vagrant plugin install vagrant-vbguest
```

### Vagrant 1.0 and older

Since vagrant v1.0.0 the preferred installation method for vagrant is using the provided packages or installers.
If you installed vagrant that way, you need to use vagrant's gem wrapper:

```bash
$ vagrant gem install vagrant-vbguest
```

If you installed vagrant using RubyGems, use:

```bash
$ gem install vagrant-vbguest
```

Compatibly for vagrant 0.8 is provided by version 0.0.3 (which lacks a bunch of new options)

## Configuration / Usage

If you're lucky, *vagrant-vbguest* does not require any configuration. 
However, here is an example of `Vagrantfile`:

```ruby
Vagrant::Config.run do |config|
  # we will try to autodetect this path. 
  # However, if we cannot or you have a special one you may pass it like:
  # config.vbguest.iso_path = "#{ENV['HOME']}/Downloads/VBoxGuestAdditions.iso"
  # or an URL:
  # config.vbguest.iso_path = "http://company.server/VirtualBox/%{version}/VBoxGuestAdditions.iso"
  # or relative to the Vagrantfile:
  # config.vbguest.iso_path = "../relative/path/to/VBoxGuestAdditions.iso"
  
  # set auto_update to false, if you do NOT want to check the correct 
  # additions version when booting this machine
  config.vbguest.auto_update = false
  
  # do NOT download the iso file from a webserver
  config.vbguest.no_remote = true
end
```

### Config options

* `iso_path` : The full path or URL to the VBoxGuestAdditions.iso file. <br/>
The `iso_path` may contain the optional placeholder `%{version}` replaced with detected VirtualBox version (e.g. `4.1.8`).
Relative paths are tricky, try to use an absolute path where possible. If not, the path is relative to the current working directory, that is where the `vagrant` command is issued. You can make sure to always be relative to the `Vagrantfile` with a little bit of ruby: `File.expand_path("../relative/path/to/VBoxGuestAdditions.iso", __FILE__)`
The default URI for the actual iso download is: `http://download.virtualbox.org/virtualbox/%{version}/VBoxGuestAdditions_%{version}.iso`<br/>
vbguest will try to autodetect the best option for your system. WTF? see below.
* `iso_upload_path` (String, default: `/tmp`): A writeable directory where to put the VBoxGuestAdditions.iso file on the guest system.
* `iso_mount_point` (String, default: `/mnt`): Where to mount the VBoxGuestAdditions.iso file on the guest system.
* `auto_update` (Boolean, default: `true`) : Whether to check the correct additions version on each start (where start is _not_ resuming a box).
* `auto_reboot` (Boolean, default: `true` when running as a middleware, `false` when running as a command) : Whether to reboot the box after GuestAdditions has been installed, but not loaded.
* `no_install` (Boolean, default: `false`) : Whether to check the correct additions version only. This will warn you about version mis-matches, but will not try to install anything.
* `no_remote` (Boolean, default: `false`) : Whether to _not_ download the iso file from a remote location. This includes any `http` location!
* `installer` (`VagrantVbguest::Installers::Base`, optional) : Reference to a (custom) installer class
* `installer_arguments` (Array, default: `['--nox11']`) : List of additional arguments to pass to the installer. eg: `%w{--nox11 --force}` would execute `VBoxLinuxAdditions.run install --nox11 --force`
* `yes` (Boolean or String, default: `true`): Wheter to pipe `yes` to the installer. If `true`, executes `yes | VBoxLinuxAdditions.run install`. With `false`, the command is executed without `yes`. You can also put in a string here for `yes` (e.g. `no` to refuse all messages)

#### Global Configuration

Using [Vagrantfile Load Order](https://www.vagrantup.com/docs/vagrantfile/#load-order-and-merging) you may change default configuration values.
Edit (create, if missing) your `~/.vagrant.d/Vagrantfile` like this:

For Vagrant >= 1.1.0 use:

```ruby
Vagrant.configure("2") do |config|
  config.vbguest.auto_update = false
end
```

For older versions of Vagrant:

```ruby
# vagrant's autoloading may not have kicked in
require 'vagrant-vbguest' unless defined? VagrantVbguest::Config
VagrantVbguest::Config.auto_update = false
```

Settings in a project's `Vagrantfile` will overwrite those setting. When executed as a command, command line arguments will overwrite all of the above.


### Running as a middleware

Running as a middleware is the default way of using *vagrant-vbguest*. 
It will run automatically right after the box started. This is each time the box boots, i.e. `vagrant up` or `vagrant reload`. 
It won't run on `vagrant resume` (or `vagrant up` a suspended box) to save you some time resuming a box.

You may switch off the middleware by setting the vm's config `vbguest.auto_update` to `false`.
This is a per box setting. On multi vm environments you need to set that for each vm.

When *vagrant-vbguest* is running it will provide you some logs:

    [...]
    [default] Booting VM...
    [default] Booting VM...
    [default] Waiting for VM to boot. This can take a few minutes.
    [default] VM booted and ready for use!
    [default] GuestAdditions versions on your host (4.2.6) and guest (4.1.0) do not match.
    stdin: is not a tty
    Reading package lists...
    Building dependency tree...
    Reading state information...
    The following extra packages will be installed:
      fakeroot linux-headers-2.6.32-33 patch

    [...]

    [default] Copy iso file /Applications/VirtualBox.app/Contents/MacOS/VBoxGuestAdditions.iso into the box /tmp/VBoxGuestAdditions.iso
    stdin: is not a tty
    [default] Installing Virtualbox Guest Additions 4.2.6 - guest version is 4.1.0
    stdin: is not a tty
    Verifying archive integrity... All good.
    Uncompressing VirtualBox 4.2.6 Guest Additions for Linux...........
    VirtualBox Guest Additions installer
    Removing installed version 4.1.0 of VirtualBox Guest Additions...
    tar: Record size = 8 blocks
    Removing existing VirtualBox DKMS kernel modules ...done.
    Removing existing VirtualBox non-DKMS kernel modules ...done.
    Building the VirtualBox Guest Additions kernel modules ...done.
    Doing non-kernel setup of the Guest Additions ...done.
    You should restart your guest to make sure the new modules are actually used

    Installing the Window System drivers ...fail!
    (Could not find the X.Org or XFree86 Window System.)
    stdin: is not a tty
    [default] Restarting VM to apply changes...
    [default] Attempting graceful shutdown of VM...
    [default] Booting VM...
    [default] Waiting for VM to boot. This can take a few minutes.
    [default] VM booted and ready for use!
    [default] Configuring and enabling network interfaces...
    [default] Setting host name...
    [default] Mounting shared folders...
    [default] -- v-root: /vagrant
    [default] -- v-csc-1: /tmp/vagrant-chef-1/chef-solo-1/cookbooks
    [default] Running provisioner: Vagrant::Provisioners::ChefSolo...
    [default] Generating chef JSON and uploading...
    [default] Running chef-solo...
    [...]


The plugin's part starts at `[default] Installing Virtualbox Guest Additions 4.1.14 - guest's version is 4.1.1`, telling you that:

* the guest addition of the box *default* is outdated (or mismatching) 
* which guest additions iso file will be used 
* which installer script will be used
* all the VirtualBox Guest Additions installer output.

No worries on the `Installing the Window System drivers ...fail!`. Most dev boxes you are using won't run a Window Server, thus it's absolutely safe to ignore that error.

When everything is fine, and no update is needed, you see log like:

    ...
    [default] Booting VM...
    [default] Waiting for VM to boot. This can take a few minutes.
    [default] VM booted and ready for use!
    [default] GuestAdditions 4.2.6 running --- OK.
    ...


### Running as a Command

When you switched off the middleware auto update, or you have a box up and running you may also run the installer manually.

```bash
$ vagrant vbguest [vm-name] [--do start|rebuild|install] [--status] [-f|--force] [-b|--auto-reboot] [-R|--no-remote] [--iso VBoxGuestAdditions.iso] [--no-cleanup]
```

For example, when you just updated VirtualBox on your host system, you should update the guest additions right away. However, you may need to reload the box to get the guest additions working.

If you want to check the guest additions version, without installing, you may run:

```bash
$ vagrant vbguest --status
```

Telling you either about a version mismatch:

    [default] GuestAdditions versions on your host (4.2.6) and guest (4.1.0) do not match.

or a match:

    [default] GuestAdditions 4.2.6 running --- OK.


The `auto-reboot` is turned off by default when running as a command. Vbguest will suggest you to reboot the box when needed. To turn it on simply pass the `--auto-reboot` parameter:

```bash
$ vagrant vbguest --auto-reboot
```

You can also pass vagrant's `reload` options like:

```bash
$ vagrant vbguest --auto-reboot --no-provision
```

When running the install step manually like this: `vagrant vbguest --do install`, adding `--no-cleanup` keeps the downloaded, uploaded files and mounted iso in their place. Happy debugging ;)

### ISO autodetection

*vagrant-vbguest* will try to autodetect a VirtualBox GuestAdditions iso file on your system, which usually matches your installed version of VirtualBox. If it cannot find one, it downloads one from the web (virtualbox.org).   
Those places will be checked in order:

1. Checks your VirtualBox "Virtual Media Manager" for a DVD called "VBoxGuestAdditions.iso"
2. Guess by your host operating system:
  * for linux : `/usr/share/virtualbox/VBoxGuestAdditions.iso`
  * for Mac : `/Applications/VirtualBox.app/Contents/MacOS/VBoxGuestAdditions.iso`
  * for Windows : `%PROGRAMFILES%/Oracle/VirtualBox/VBoxGuestAdditions.iso`


### Automatic reboot

The VirtualBox GuestAdditions Installer will try to load the newly built kernel module. However the installer may fail to load, just as it is happening when updating GuestAdditions from version 4.1 to 4.2.

Hence, vbguest will check for a loaded kernel module after the installation has finished and reboots the box, if it could not find one.


## Advanced Usage

vagrant-vbguest provides installers for generic linux and debian/ubuntu.  
Installers take care of the whole installation process, that includes where to save the iso file inside the guest and where to mount it.

```ruby
class MyInstaller < VagrantVbguest::Installers::Linux

  # use /temp instead of /tmp
  def tmp_path
    '/temp/VBoxGuestAdditions.iso'
  end

  # use /media instead of /mnt
  def mount_point
    '/media'
  end

  def install(opts=nil, &block)
    communicate.sudo('my_distos_way_of_preparing_guestadditions_installation', opts, &block)
    # calling `super` will run the installation
    # also it takes care of uploading the right iso file into the box
    # and cleaning up afterward
    super
  end
end

Vagrant::Config.run do |config|
  config.vbguest.installer = MyInstaller
end
```


### Extending vbguest (aka Very Advanced Usage)

If you find yourself copying the same installer in each of your vagrant project, it might be a good idea to make it a plugin itself. Like vagrant-vbguest itself, installers can be [distributed as ruby gems](http://guides.rubygems.org/publishing/)

This project contains a [sample installer gem](https://github.com/dotless-de/vagrant-vbguest/tree/master/testdrive/vagrant-vbguest-unikorn) which might serve as an boilerplate. 

## Known Issues

* The installer script, which mounts and runs the GuestAdditions Installer Binary, works on Linux only. Most likely it will run on most Unix-like platforms.
* The installer script requires a writeable upload directory on the guest system. This defaults to `/tmp` but can be overwritten with the `iso_upload_path` option.
* The installer script requires a valid mount point on the guest system. This defaults to `/mnt` but can be overwritten with the `iso_mount_point` option.
* On multi vm boxes, the iso file will be downloaded for each vm.
* The plugin installation on Windows host systems may not work as expected (using `vagrant gem install vagrant-vbguest`). Try `C:\vagrant\vagrant\embedded\bin\gem.bat install vagrant-vbguest` instead. (See [issue #19](https://github.com/dotless-de/vagrant-vbguest/issues/19#issuecomment-7040304))
