class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  before_action :load_current_session
  before_action :authenticate
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  private

  def authenticate
    return if Current.user

    redirect_to new_session_path
  end

  def start_new_session_for(user)
    session = user.sessions.create!
    cookies.encrypted[:session_id] = session.id
    Current.session = session
  end

  def after_authentication_url
    root_path
  end

  def load_current_session
  if session_id = cookies.encrypted[:session_id]
    Current.session = Session.find_by(id: session_id)
  end
  end

  class << self
    def allow_unauthenticated_access(only:)
      skip_before_action :authenticate, only: only
    end
  end
end
