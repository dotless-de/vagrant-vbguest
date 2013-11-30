vagrant_version = Gem::Version.new(Vagrant::VERSION)
supported_version = {
  "< 1.1.0"  => "1_0",
  "~> 1.1.0" => "1_1",
  "~> 1.2.0" => "1_2",
  "~> 1.3.0" => "1_3",
}
compat_version = supported_version.find { |requirement, version|
  Gem::Requirement.new(requirement).satisfied_by?(vagrant_version)
}

if compat_version
  compat_version = compat_version[1]
else
  # @TODO: yield warning
  compat_version = supported_version.to_a.last[1]
end

%w{vm_compatible rebootable command download}.each do |r|
  require File.expand_path("../vagrant_compat/vagrant_#{compat_version}/#{r}", __FILE__)
end
