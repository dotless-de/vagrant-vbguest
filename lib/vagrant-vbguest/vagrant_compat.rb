
compat_version = Vagrant::VERSION < "1.1.0" ? "1_0" : "1_1"

%w{vm_compatible rebootable command}.each do |r|
  require File.expand_path("../vagrant_compat/vagrant_#{compat_version}/#{r}", __FILE__)
end
