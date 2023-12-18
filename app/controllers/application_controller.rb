class ApplicationController < ActionController::Base
  include Pagy::Backend
  before_action :authenticate_user!


  rescue_from CanCan::AccessDenied do |exception|
    redirect_to request.referer || root_path, alert: exception.message
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
