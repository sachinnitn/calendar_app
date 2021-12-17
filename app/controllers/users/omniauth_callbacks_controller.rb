# frozen_string_literal: true

class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  include GoogleCalendarApi

  before_action :assign_user, only: :google_oauth2

  def google_oauth2
    if @user.persisted?
      sync_existing_events(@user) if @user.first_login?
      flash[:notice] = I18n.t "devise.omniauth_callbacks.success", :kind => "Google"
      sign_in_and_redirect @user, :event => :authentication
    else
      session["devise.google_data"] = request.env["omniauth.auth"]
      redirect_to new_user_registration_url
    end
  end

  private

  def assign_user
    @user = User.from_omniauth(request.env["omniauth.auth"])
  end
end
