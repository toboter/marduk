require 'marduk/models/actable'
require 'marduk/record_activity'
require 'active_record'

ActiveRecord::Base.send :extend, Marduk::RecordActivity

require "marduk/engine"

module Marduk
  extend ActiveSupport::Concern
  included do
    before_action :check_token!
    before_action :init_session_per_page

    rescue_from OAuth2::Error do |exception|
      if exception.response.status == 401
        session[:user_id] = nil
        session[:access_token] = nil

        redirect_to root_url, alert: "Access token expired, try signing in again."
      end
    end
  end
  
  def init_session_per_page
    session[:per_page] ||= 50
  end

  def oauth_client
    @oauth_client ||= OAuth2::Client.new(Rails.application.secrets.client_id, 
      Rails.application.secrets.client_secret, 
      site: Rails.application.secrets.provider_site)
  end

  def access_token
    @access_token ||= OAuth2::AccessToken.new(oauth_client, session[:access_token]) if session[:access_token]
  end
  
  def authorize
    redirect_to root_url, alert: "Not authorized. Please sign in." if current_user.nil?
  end

  def administrative
    redirect_to root_url, alert: "You need administrative priviledges." if !current_user.app_admin
  end
  
  # The current_user is logged out automatically and redirected to root if the access_token is expired.
  def check_token!
    if current_user && access_token && access_token.expired?
      session[:user_id] = nil
      session[:access_token] = nil
      
      redirect_to root_url, notice: 'Access token expired. You have been logged out.'
    end
  end


end
