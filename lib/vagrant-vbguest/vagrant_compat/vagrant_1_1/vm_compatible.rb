module VagrantVbguest
  module Helpers
    module VmCompatible
      def communicate
        vm.communicate
      end

      def driver
        vm.provider.driver
      end

      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods
        def vm_id(vm)
          vm.id
        end

        def communicate_to(vm)
          vm.communicate
        end
      end
    end
  end
end
