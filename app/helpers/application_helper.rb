module ApplicationHelper
  include Pagy::Frontend
  include Heroicon::Engine.helpers
  include ActsAsTaggableOn::TagsHelper


  def page_title
#    "Rails + Ralix + Tailwind | #{controller_name.humanize}"
    "🐧🧳 PuffinTours | #{controller_name.humanize}"
  end

  def body_class
    "#{controller_name}-#{action_name}"
  end

  def nav_link_class(section, extra = nil)
    if section == controller_name
      "bg-gray-900 text-white px-3 py-2 rounded-md text-sm font-medium #{extra}"
    else
      "text-gray-300 hover:bg-gray-700 hover:text-white px-3 py-2 rounded-md text-sm font-medium #{extra}"
    end
  end

  def time_ago(time_object)
    "#{time_ago_in_words(time_object)} ago"
  end

  def format_time(time_object)
    l(time_object, format: :long)
  end

  # TODO also add a ENV variable
  def if_admin_and_dev
    return '[CLEAN_INTERFACE_ENABLED]' if CLEAN_INTERFACE_ENABLED
    if (current_user&.is_admin? && Rails.env.development?)
      yield
    end
  end


end #/module ApplicationHelper
