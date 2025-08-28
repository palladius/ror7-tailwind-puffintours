class PagesController < ApplicationController
  include GcpHelper
  before_action :authenticate_user!, only: [:family]

  def family
  end

  def show
    render template: "pages/#{params[:page]}"
      rescue ActionView::MissingTemplate
    render "errors/not_found", status: 404
  end

end
