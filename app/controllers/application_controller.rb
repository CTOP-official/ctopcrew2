class ApplicationController < ActionController::Base
    before_action :require_login
    skip_before_action :verify_authenticity_token

    private

    def require_login
        unless session[:id]
            if request.url.to_s.include?('login')

            else
                flash[:error] = "로그인이 필요합니다."
                redirect_to login_path
            end
        end
    end
end
