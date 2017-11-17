require "marduk/engine"
require "omniauth-oauth2"

module Marduk
  extend ActiveSupport::Concern
  
  included do
    before_action :check_token!
    before_action :init_session_per_page

    around_action :set_current_user

    def set_current_user
      User.current = current_user
      yield
    ensure
      # to address the thread variable leak issues in Puma/Thin webserver
      User.current = nil
    end

    rescue_from OAuth2::Error do |exception|
      if exception.response.status == 401
        session[:user_id] = nil
        session[:access_token] = nil

        redirect_to root_url, alert: "Access token expired, try signing in again."
      end
    end
    
    helper_method :current_user_search_abilities, :current_user_app_crud_ability, :current_user_projects

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

  def current_user_search_abilities
    @current_user_search_abilities = JSON.parse(((current_user && access_token) ? access_token.get("/api/my/accessibilities/searchable").body : []), object_class: OpenStruct)
  end

  def current_user_projects
    @current_user_projects = JSON.parse(((current_user && access_token) ? access_token.get("/api/my/accessibilities/projects/#{Rails.application.secrets.client_id}").body : []), object_class: OpenStruct)
    # @current_user_projects = projects.select{ |p| p.oauth_application_uids.include?(Rails.application.secrets.client_id) unless p.oauth_application_uids.nil? }
  end

  def current_user_app_crud_ability
    @current_user_app_crud_ability = JSON.parse(((current_user && access_token) ? access_token.get("/api/my/accessibilities/crud/#{Rails.application.secrets.client_id}").body : []), object_class: OpenStruct)
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