class PagesController < ApplicationController
  include GcpHelper
  before_action :authenticate_user!, only: [:family]

  def family
    @family_members = YAML.safe_load(File.read(Rails.root.join('config', 'family.yml')), permitted_classes: [Date])
  end

  def show
    render template: "pages/#{params[:page]}"
      rescue ActionView::MissingTemplate
    render "errors/not_found", status: 404
  end

end
