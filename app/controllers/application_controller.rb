class ApplicationController < ActionController::Base
  include Pagy::Backend


  rescue_from CanCan::AccessDenied do |exception|
    redirect_to request.referer || root_path, alert: exception.message
  end

  # before_action :set_cors
  before_action :cors_set_access_control_headers

  # def set_cors
  #   headers['Access-Control-Allow-Origin'] = '*'
  #   headers['Access-Control-Request-Method'] = '*'
  # end
  #
def cors_set_access_control_headers
  headers['Access-Control-Allow-Origin'] = '*'
  headers['Access-Control-Allow-Methods'] = 'POST, PUT, DELETE, GET, PATCH, OPTIONS'
  headers['Access-Control-Request-Method'] = '*'
  headers['Access-Control-Allow-Headers'] = 'Origin, X-Requested-With, Content-Type, Accept, Authorization'
end

  # CurrUs should be here: https://stackoverflow.com/questions/36352521/rails-service-object-with-current-user
  # def current_user
  #   # define current user here
  #   # return current_user
  #   #user_signed_in?
  #   #nil
  # end

  # from BArd..
  # def authenticate_user!
  #   unless current_user
  #     redirect_to login_path
  #   end
  # end

end
