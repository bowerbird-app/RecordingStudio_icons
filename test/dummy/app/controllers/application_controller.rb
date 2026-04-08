class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  layout :application_layout

  before_action :ensure_demo_data, if: :development_mode?
  before_action :authenticate_user!
  before_action :set_current_actor

  private

  def application_layout
    devise_controller? ? "application" : "flat_pack_sidebar"
  end

  def development_mode?
    Rails.env.development?
  end

  def ensure_demo_data
    Dummy::DemoData.ensure!
  end

  def set_current_actor
    Current.actor = current_user
  end
end
