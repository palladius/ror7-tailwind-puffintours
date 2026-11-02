module ApplicationHelper
  include Pagy::Frontend
  include Heroicon::Engine.helpers
  include ActsAsTaggableOn::TagsHelper

  def page_title
    "🐧🧳 PuffinTours | #{controller_name.humanize}"
  end

  def body_class
    "#{controller_name}-#{action_name}"
  end

  def nav_link_class(section, extra = nil)
    active = (section == controller_name) || (section == "about_us" && params[:id].to_s == "about_us") || (section == "about_the_app" && params[:id].to_s == "about_the_app")
    if active
      "bg-gradient-to-r from-amber-500/25 to-orange-500/20 text-amber-300 border border-amber-400/30 px-3.5 py-1.5 rounded-full text-sm font-semibold shadow-inner transition-all #{extra}"
    else
      "text-slate-300 hover:bg-white/10 hover:text-white px-3.5 py-1.5 rounded-full text-sm font-medium transition-all #{extra}"
    end
  end

  def time_ago(time_object)
    "#{time_ago_in_words(time_object)} ago"
  end

  def format_time(time_object)
    l(time_object, format: :long)
  end

  def if_admin_and_dev
    return '[CLEAN_INTERFACE_ENABLED]' if CLEAN_INTERFACE_ENABLED
    if (current_user&.is_admin? && Rails.env.development?)
      yield
    end
  end
end
