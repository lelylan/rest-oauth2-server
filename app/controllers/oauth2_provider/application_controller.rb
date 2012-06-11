module Oauth2Provider
  class ApplicationController < ::ApplicationController
    (::ApplicationController._process_action_callbacks - ActionController::Base._process_action_callbacks).each{|callback|skip_before_filter callback.filter if callback.kind == :before}
    include ControllerMixin
    layout 'oauth2_provider/application'
  end
end
