require File.join(File.dirname(__FILE__), "lib", "lightview")

ActionView::Helpers::PrototypeHelper.send(:include, Lightview::PrototypeHelper)
ActionController::Base.helper Lightview::HelperMethods
