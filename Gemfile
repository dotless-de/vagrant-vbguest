source 'https://rubygems.org'

group :development do
  # We depend on Vagrant for development, but we don't add it as a
  # gem dependency because we expect to be installed within the
  # Vagrant environment itself using `vagrant plugin`.
  if ENV['VAGRANT_VERSION']
    gem 'vagrant', :git => 'https://github.com/hashicorp/vagrant.git', tag: "v#{ENV['VAGRANT_VERSION']}"
  elsif ENV['VAGRANT_LOCAL']
    gem 'vagrant', path: ENV['VAGRANT_LOCAL']
  else
    gem 'vagrant', :git => 'https://github.com/hashicorp/vagrant.git'
  end
  gem 'rake', '>= 12.3.3'
end

group :plugins do
  gem 'vagrant-vbguest', path: '.'
end
