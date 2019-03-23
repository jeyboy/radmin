module Radmin
  module Actions
    class ShowInApp < Radmin::Actions::Base
      Radmin::Actions.register(self)

      register_property :member do
        true
      end

      register_property :visible? do
        authorized? && (bindings[:controller].main_app.url_for(bindings[:object]) rescue false)
      end

      register_property :controller do
        proc do
          redirect_to main_app.url_for(@object)
        end
      end

      register_property :link_icon do
        'icon-eye-open'
      end
    end
  end
end
