## 0.25.0 (unreleased)

- Renames mainline branch from "master" to "main"
- Fix not detecting running GuestAdditions on some systems [GH-347], [GH-376]. Thanks @Morac2 for [GH-377]
- Fixes package installation issues on CentOS 8.
  CentOS installers no longe use the `--enablerepo` parameter when running `yum` to install packages.
  Thanks @ghoneycutt for [GH-384]

## 0.24.0 (2020-04-29)

No code changes to 0.24.0.beta1

## 0.24.0.beta1 (2020-04-28)

- Add a new configuration `installer_options`, as an optional way to pass options to Installer classes.
- Add new `installer_options` for the CentOS Installer. Thanks @pedrofurtado for [GH-373]
  + `allow_kernel_upgrade`: Will update the kernel and reboots the box
  + `reboot_timeout`: Optionally, set the max amount of seconds to wait after reboot

## 0.23.0 (2020-01-05)

- Fix Oracle Linux Installer. Installs `elfutils-libelf-devel`. [GH-364], @fribeiro1 [GH-365]


## 0.22.0 (2019-12-06)

- Fix checking for `vboxadd` tools. [GH-362]

## 0.22.0 (2019-12-01)

- Opensuse installer now uninstalls packaged guest additions
- Fix error trying to rebuild/start guest additions when no `vboxadd` to is present [GH-358]
- Fix Oracle installer to support non UEK kernel. [GH-357]

## 0.21.0 (2019-11-11)

- Default `web_path` to virtualbox now uses https. @adamzerella [GH-354]
- Support for Centos7-style compressed modules. @jude [GH-352]

## 0.20.0 (2019-09-27)

- Add Windows support. @thumperward [GH-343]
- Add `allow_downgrade` config. Set it to `false` to prevent downgrades. [GH-310]
- the gem version is now hold in a plain text file `VERSION` (additionally to the ruby constant `VagrantVbguest::VERSION`)

## 0.19.0 (2019-07-09)

- Relax version pin on micromachine dependency. Allow 2.x to 3.x. @johanneskastl [GH-341]

## 0.18.0 (2019-05-20)

- Fix Linux kernel module detection for VirtuaBox >= 6.0.6. @carlosefr [GH-334]

## 0.17.2 (2019-01-23)

- ContOS installer now activates all repositories when installing the kernel-devel-`uname -r` package and there's no specific release repository. [GH-320]
- Fix CentOS release version detection for major.minor version numbers. Thanks @jaredg [GH-324]
- Open upper version limit for Suse installer, supporting Suse 15 (and possibly above). Thanks @Fdall [GH-323]

## 0.17.1 (2018-12-20)

- CentOS keeps default redhat dependencies if kernel-devel-`uname -r` exists [GH-318]

## 0.17.0 (2018-12-13)

No changes to 0.17.0.beta2

## 0.17.0.beta2 (2018-12-07)

- Fix Incorrect syntax on parameter passing in CentOS installer. @bstopp [GH-315]

## 0.17.0.beta1 (2018-12-07)

- New CentOS specific installer. Thanks @bstopp [GH-314]
- Big cleanup, dropping support for Vagrant < 1.3. [GH-313]
- Changes the status message for "No Virtualbox Guest Additions installation found". Thanks @SchnWalter [GH-308]

## 0.16.0 (2018-09-04)

No changes to 0.16.0.beta1

## 0.16.0.beta1 (2018-08-29)

- Refactoring of reading the GuestAdditions version. For VirtualBox >= 4.2, we'll try `VBoxManage showvminfo` first, and use Vagrant as a fallback.  
This should fix a lot of those "Got different reports about installed GuestAdditions version" error messages.  
See discussion in [GH-300]. Thanks @cbj4074 for asking the right questions.
- Add support for Amazon 2. Thanks @ghoneycutt [GH-304], [GH-303]

## 0.15.2 (2018-05-22)

- On RedHad based guest, the installer will now try to install the 'kernel-devel' package additionally to 'kernel-devel-`uname -r`' Thanks @ghoneycutt [GH-299]

## 0.15.1 (2018-01-08)

- Fix disabling `yes |` via options. Thanks @davidjb [GH-280]

## 0.15.0 (2017-09-21)

- Interactive user inputs from the installer run will be answered with "yes" by default. Thanks @jerr0328 [GH-268], [GH-267]
- Added logging of mounting/umounting VBoxGuestAdditions.iso file. Thanks @m03 [GH-249]
- Updates remote location of development dependencies.

## 0.14.2 (2017-05-09)

- Fix Debian installer. Thanks @chrisko [GH-255], [GH-256]

## 0.14.1 (2017-05-05)

- Fix GA version string parsing. Thanks @curtisharvey [GH-253]

## 0.14.0 (2017-05-04)

No changes.

## 0.14.0-beta1 (2017-02-24)

- Added support for VirtualBox 5.1. Thanks @cdloh [GH-238], [GH-230]
  + Waring: The helper method `vboxadd_tool` was replaced by `find_tool(tool)`
- The installers `distro(vm)` helper method got moved from the `Linux` class down the `Base` class which should make implementing non-linux installers easier. This change was purposed by @fabriciocolombo back in [GH-129]
- The debian installer added support for proxmox VE. Thanks @maninga [GH-246]
- The debian installer now calls `apt-get update` with `-y --force-yes` options. Thanks @podarok [GH-237]
- Add synopsis for help/list-commands. Thanks @m03 [GH-235], [GH-236]
- Fix typo in the `Installers::Base#yield_installation_warning` method name (keeping the incorrect `yield_installation_waring` as an alias for backward compatibility. This alias will be removed in a future version) Thanks @m03 [GH-234]

## 0.13.0 (2016-08-12)

- Fix a bug introduced by upgrading "micormachine". Thanks @omenlabs for [GH-225]
- Fix a typo in a local variable. Thanks @vdloo for [GH-227]
- Add an Arch Linux specific installer. Thanks @vdloo, also for fixing some typos in [GH-229]
- Add a SUSE Linux Enterprise Server (sles) specific installer to address [GH-219] and [GH-216]. Thanks @vpereira, @glookie1 for the hard digging. Thanks @vpereira for [GH-219]. Thanks @bkeepers for the dontenv project, from which I stole it's parser.

## 0.12.0 (2016-06-16)

- Fix version comparison when version is reported with revision. Thanks @apeabody for [GH-179], [GH-201]
- Fix package manager detection on Fedora. Thanks @robnagler for [GH-185]
- Fix missing `binutils` dependency for RedHat. Thanks @andy-maier for [GH-188]
- Fix detecting of `chkconfg` or `service` command. Thanks @jherre for [GH-191]
- Fix cleaning up temp files on Windows. Thanks @JexCheng for [GH-212]
- Fix ubuntu removing packaged_additions for old installations. [GH-199] Also thanks @thpang67 for [GH-208]
- Fix driver and service version comparison. Big thanks to @NeMO84 for [GH-213] and [GH-214]
- Improve installing dependencies on openSUSE. Thanks @vpereira for [GH-190]
- Improve detection of the VBoxGuestAdditions.iso file. Thanks @Raskil for [GH-206]
- Add the vm name to log outputs. Thanks @Tomohiro for [GH-210]


For those who want to create their own (or overwrite existing) installers, this sample for a vbguest driver plugin might help you to get started: https://github.com/dotless-de/vagrant-vbguest/tree/master/testdrive/vagrant-vbguest-unikorn

For a full diff see: https://github.com/dotless-de/vagrant-vbguest/compare/v0.11.0...v0.12.0

## 0.11.0 (2015-10-29)

  - Add installer for opensuse. Thanks @darnells for [GH-163]
  - Add installer for fedora. Thanks @jamesgecko and @PatrickCoffey for [GH-158]
  - Add installer for oracle. Thanks @TobyHFerguson for [GH-145]
  - Add redhat installer support for centos7. Thanks @roidelapluie for [GH-162]
  - Add debian installer support for debian8. Thanks @ubermuda for [GH-171]
  - Add ISO auto-detection on Archlinux hosts. [GH-135]
  - Add lookup for the `vboxadd` tool, instead of assuming it in `/etc/init.d`
  - And systemd-ish startup methods if available, instead of assuming `/etc/init.d/vboxadd` being useable.
  - Add configuration options for iso upload path and mount point.
  - Add a `--no-cleanup` command-line switch to make debugging a bit more convenient.

## 0.10.1 (2015-10-08)

  - Make sure our log message strings are loaded [GH-107]
  - Add ‘bzip2’ as a dependency for redhat based distributions. [GH-155], [GH-167]

## 0.10.0 (2013-12-09)

  - Adds new config option `installer_arguments`   
    Customize arguments passed to the VirtualBox GuestAdditions shell script
    installer. Defaults to "--no-x11". [GH-98]
  - Cope with UbuntuCloudImage by default [GH-86], [GH-64], [GH-43]
    On Ubuntu, always try to remove conflicting installations of
    GuestAdditions by removing those packages:
    virtualbox-guest-dkms virtualbox-guest-utils virtualbox-guest-x11
  - Unload kernel modules when UbuntuCloudImage packages are installed.
    (Thanks @eric1234 for commenting on ec9a7b1f0a)
  - Wait for SSH connection to be ready. Fixes timing issues with vagrant
    v1.3.0 and later. [GH-80], [GH-90]
  - Fix a typo in command description [GH-84]
  - Tweak gem dependencies [GH-82]
    - add rake as development dependency
    - remove version locks on gems provided by vagrant
  - Pass plugin name when registration the action hook for vagrant ≥1.1 [GH-80]
  - Fix crash on Vagrant 1.4 [GH-100]

### heads-up
  
  - With [GH-94] the **name**, `vagrant-vbguest` registers itself to vagrant's
    (≥1.1) plugin-system changed from 'vbguest management' to
    'vagrant-vbguest'

## 0.9.0

  - Adds support for vagrant 1.3 [GH-71], [GH-72]
  - Fix crash when using as a command [GH-68].
  - Don't trust VirtualBox Media Manager informations when
    looking for an iso file. [GH-70]

### heads-up

  - Be lax about missing installer for guest OS.
    No longer throws an error when no Installer class
    for the guest os was found. Keep the error message,
    stop vbguest workflow, but keep vagrant running.
    [GH-65]


## 0.8.0

  - Adds Vagrant 1.2 compatibility [GH-59], [GH-60], [GH-62] /
    (thanks @Andrew8xx8 for pointing directions)
  - Fix basic/fallback linux installer [GH-56]
  - Guard auto-reload on broken vagrant builds.
    Some vagrant 1.1.x versions have a bug regarding ssh and cleaning
    up old connections, which results in vagrant crashing when a box
    is reloaded.

## 0.7.1

  - Fix auto-reloading for vagrant 1.1 [GH-52]
    Also changes the reload method for vagrant 1.0 when ran
    as middleware (to not run build-in actions manually).

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
    environment is passed around. Also decoupled GuestAdditions
    finder into a separate class.
  - Introduce a vagrant 1.0 compatibility layer for Installers and
    other vbguest internals

### heads-up

  - [GH-44] changes the behaviour of vbguest to that effect, that it
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
        changed to `communicate.sudo 'apt-get update'`
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

## 0.6.1 (2013-01-13)

  - Fix missing command output block and parameters for
    installation process [GH-37]
  - Update README to reflect new wording for status informations

## 0.6.0 (2013-01-13)

 - Debian installer now cope with missing `dkms` package [GH-30]
 - Fixed some issues when running on just creating boxes [GH-31]
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
    command (which is disabled by default when running as command)
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

  - Add Fedora to the list of supported platforms [GH-17]
  - Add system package update (`apt-get update`) to the
    debian installer if package installation fails [GH-16]
  - Drop dependency on `vagrant` gem [GH-15]

## 0.3.2

  - Stop GuestAdditions installation and fail with an error
    when installation of dependency packages fails [GH-13]

## 0.3.1

  - Ruby 1.8.7 compatibility [GH-12]

## 0.3.0

  - Removed dependency to the `virtualbox` gem by using
    `vagrant`s vm driver [GH-8]

## 0.2.1

  - Typo fixes in readme and internal renaming. [GH-9], [GH-7]

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
