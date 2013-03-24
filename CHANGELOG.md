## 0.7.0

  - When looking for a GuestAdditions iso file in media manager
    allow version number in filename. [GH-48], [GH-49] /
    (thanks @neerolyte)
  - Support multiple locations to be searched while "guessing"
    GuestAdditions iso file
  - On Linux guests also search "$HOME/.VirtualBox" for
    GuestAdditions iso file. [GH-48]
  - Add support for redhat-based distributions (Scientific Linux and
    presumably CentOS) [GH-47], [GH-46] / (thanks @neerolyte)
  - Fix an issue with VirtualBox GuestAdditions 4.2.8 [GH-44] /
    (thanks @jimmycuadra)
  - Reworked bunch of internals, particularly how vagrants's
    environemnt is passed arround
  - Intodruce a vagrant 1.0 compatibility layer for Installers and
    other vbguest internals

### heads-up

  - [GH-44] changes the behavior of vbguest to that effect, that it
    will no longer halt vagrant workflow if running the VirtualBox
    GuestAdditions Installer returns an error-code.
    Instead it will print a human readable waring message.
  - The environment (`env`) in custom installers is no longer the
    actions environment `Hash`, but the `Environment` instance.
    Which has some implications on how you can access e.g. the `ui`:
    instead of `env[:ui]` use `env.ui`
  - To achieve compatibility to both vagrant 1.0 and 1.1, custom
    Installers, when executing shell commands on the guest system,
    should use vbguests `communicate` wrapper. e.g.:
        A call like `vm.channel.sudo 'apt-get update'` should be
        changed to `channel.sudo 'apt-get update'`
    The old `vm.channel` syntax will continue to work on vagrant 1.0.x
    but will fail on vagrant 1.1.x.

## 0.6.4 (2013-01-24)

  - Fix passing a installer class as an config option [GH-40]

## 0.6.3 (2013-01-19)

  - Fix generic linux installer for not explicitly supported
    distributions [GH-39]

## 0.6.2 (2013-01-18)

  - Fix typos and wording in error messages and I18n keys
    et al. [GH-38]

## 0.6.1 (2012-01-13)

  - Fix missing command output block and parameters for
    installation process [GH-37]
  - Update README to reflect new wording for status informations

## 0.6.0 (2012-01-13)

 - Debian installer now cope with missing `dkms` package [GH-30]
 - Fixed some issues when runnig on just creating boxes [GH-31]
 - Fixed workding (thx @scalp42) [GH-32]
 - Add debug logging
 - Installers no longer are shell scripts, but ruby classes
 - Users may pass in their own installer classes
   (yes! plugins in plugins)
 - New `sprintf` style `%{version}` placeholder for iso download path.
   (old `$VBOX_VERSION` placeholder still working)
 - Revisited command arguments to not just mirror config values:
   - New `--do` argument: force-run one of those commands:
     * `start`   : Try to start the GuestAdditions Service
     * `rebuild` : Rebuild the currently installed Guest Additions
     * `install` : Run the installation process from "iso file"
   - New `--status` argument
   - Removed `-I|--no-install` argument (instead use `--status`)

## 0.5.1 (2012-11-30)

 - Fix: Provisioning will not run twice when rebooted due
   to incomplete GuestAdditions installation [GH-27] /
   (thanks @gregsymons for pointing)

## 0.5.0 (2012-11-19)

  - Box will be rebooted if the GuestAdditions installation
    process does not load the kernel module [GH-25], [GH-24]
  - Add `--auto-reboot` argument to allow rebooting when running as a
    command (which is disabled by default when runnind as command)
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
