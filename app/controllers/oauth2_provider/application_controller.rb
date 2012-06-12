module Oauth2Provider
  class ApplicationController < ::ApplicationController
    (::ApplicationController._process_action_callbacks - ActionController::Base._process_action_callbacks).each{|callback|skip_before_filter callback.filter if callback.kind == :before}

    before_filter :_oauth_provider_authenticate

    include ControllerMixin
    layout 'oauth2_provider/application'
    def _oauth_provider_admin?
      unless current_user.admin?
        flash.alert = "Unauthorized access."
        redirect_to root_path
        return false
      end
    end
  end
end
