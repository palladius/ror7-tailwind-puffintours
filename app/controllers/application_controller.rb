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
  # TODO(ricc): #hardening As a best practice, you should dedicate a specific bucket for this data access. This approach prevents your site from inadvertently over-exposing static resources to all of storage.googleapis.com. For example, if you want to dedicate a bucket named mybucket for data access, you should have the website serve the CORS header Access-Control-Allow-Origin: https://mybucket.storage.googleapis.com instead of Access-Control-Allow-Origin: https://storage.googleapis.com.
  #headers['Access-Control-Allow-Origin'] = "https://#{GcsBucket}.storage.googleapis.com"
  headers['Access-Control-Allow-Origin'] = '*'
  headers['Access-Control-Allow-Methods'] = 'POST, PUT, DELETE, GET, PATCH, OPTIONS'
  headers['Access-Control-Request-Method'] = '*'
  #headers['Access-Control-Allow-Headers'] = 'Origin, X-Requested-With, Content-Type, Accept, Authorization'
  headers['Access-Control-Allow-Headers'] = '*'
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
