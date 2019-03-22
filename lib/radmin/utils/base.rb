module Radmin
  module Utils
    module Base
      def path_name_to_class_name(path_name)
        path_name.split('~').collect(&:camelize).join('::')
      end
      module_function :path_name_to_class_name

      def class_name_to_path_name(klass_name)
        klass_name.gsub('::', '~').underscore
      end
      module_function :class_name_to_path_name

      def class_name_to_param_name(klass_name)
        klass_name.gsub('::', '_').underscore
      end
      module_function :class_name_to_param_name
    end
  end
end
