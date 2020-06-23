# VgarntVbguestUnikon Sample Installer

**This is an Example** for creating or overriding a installer to be used by [vagrant-vbguest](https://github.com/dotless-de/vagrant-vbguest) based on a hypothetical Linux calles "Unikorn". (If it turns out to be an actual system, I'm very sorry for the misguidance)


You are free to use this code **as a boilerplate**. When doing so, please **rename your project/gem** by replacing occurrences of `vagrant-vbguest-unikorn` with your own, ideally unique project name.
Please take care when using "namespaces" and avoid creating objects under `VagrantVbguest`:

- `VagrantVbguest::MySystem` : **BAD**
- `VagrantVbguestMySystem` : **good**
- `MySystem::VagrantVbguest` : **good**

## Development

The vagrant documentation has a lot of information on how to develop an own vagrant-plugin:

* [Plugin Development Basics](https://www.vagrantup.com/docs/plugins/development-basics.html)
* [Packaging & Distribution](https://www.vagrantup.com/docs/plugins/packaging.html)

Here's some TL;DR:

After checking out the repo, run `bin/setup` to install dependencies. 
You can also run `bin/console` for an interactive prompt that will allow you to experiment.
This project also adds a `bin/vagrant` which let's the bundled vagrant run in it's own sandbox. This sandbox defaults to path of this project, but can be overwritten by setting the `VAGRANT_DEV` environment variable.

To release a new version , update the version number in `version.rb`.

To create a gem file form onto your local machine run `bundle exec rake build`. This will create a new file like `pkg/vagrant-vbguest-unikorn-0.1.0.gem`. 

To release your gem, run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

### Creating your own installer

Have a ook at the sample [installer.rb](https://github.com/dotless-de/vagrant-vbguest/tree/main/testdrive/vagrant-vbguest-unikorn/lib/vagrant-vbguest-unikorn/installer.rb) and it's comments. It fulfills 3 major roles:

- Check if this installer should be used for a system
- Prepare the guest system for installing the gust additions (eg: install packages or cleaning up conflicting installations)
- Register itself at `VagrantVbguest`

When implementing your own installer class, you might want to look  at existing installer.
However, for best compatibility your should always subclass from `VagrantVbguest::Installers::Linux` (or, when not dealing with Linux form `VagrantVbguest::Installers::Base`).

### Other files you'd need to look into, when using this as a boilerplate

When using this code as a direct boilerplate, you would make changes to all those files:

* `vagrant-vbguest-unikorn.gemspec` (also, this should be renamed)
* `Gemfile`
* `lib/vagrant-vbguest-unikorn` should be renamed
* `lib/vagrant-vbguest-unikorn.rb` (also, this should be renamed)
* `lib/vagrant-vbguest-unikorn/version`s

## Installation

Assuming, that you already have [vagrant](https://www.vagrantup.com/) installed, make sure you also have the `vagrant-vbguest` plugin installed. Then, install your own installer-plugin.

Depending on how you'd released your gem, you have those options:

### Non-Release ("released" as gem file)

You might choose to not release your gem to the public registry at rubygems.org or any other registry and simple ship your gem file along your vagrant project.

```bash
vagrant plugin install /path/to/vagrant-vbguest-unikorn.gem
```

### Released gem

If you have released your plugin to rubygems you can simply:

```
vagrant plugin install vagrant-vbguest-unikorn
```

If you put your gem somewhere else, your own registry for example. Have a look in the `--plugin-source` and `--plugin-clean-sources` options of the `vagrant plugin install` command


## Usage

After installing your installer gem, vagrant-vbguest will pick it up and check it against a guest system, taking it's registration priority into account.

You can force the usage of your installer class in a `Vagrantfile` like this:

```ruby
Vagrant.configure("2") do |config|
  config.vbguest.installer = VagrantVbguestUnikorn::Installer
end
```

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

