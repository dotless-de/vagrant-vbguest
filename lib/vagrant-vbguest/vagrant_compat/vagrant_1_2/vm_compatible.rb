require File.expand_path("../../vagrant_1_1/vm_compatible", __FILE__)
module VagrantVbguest
  module Helpers
    module VmCompatible
      def self.included(base)
        base.extend(ClassMethods)
      end
      module ClassMethods
        def distro_name(vm)
          vm.guest.name
        end
      end
    end
  end
end
