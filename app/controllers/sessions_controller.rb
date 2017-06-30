class SessionsController < ApplicationController
  require 'rest-client'

  def create
    auth = request.env["omniauth.auth"]
    user = User.where(provider: auth["provider"], uid: auth["uid"]).first_or_create! do |u|
      u.token = auth["credentials"]["token"]

      # adding the initial token to the search feature in babili
      url = "#{Rails.application.secrets.provider_site}/api/oread_application_access_token"
      host = request.base_url
      begin
        response = RestClient.post url, {token: u.token, host: host}, {:Authorization => "Bearer #{u.token}"}
      rescue RestClient::ExceptionWithResponse => e
        flash[:alert] = "The Server ist returning #{e}. Perhaps you are not assigned to any projects. Service Token for babili not sent."
      end

    end
    user.update(email: auth["info"]["email"], name: auth["info"]["name"], gender: auth["info"]["gender"], birthday: auth["info"]["birthday"])
    session[:user_id] = user.id
    session[:access_token] = auth["credentials"]["token"]

    redirect_to (request.env['omniauth.origin'] || root_url), notice: "You have been signed in through #{user.provider.humanize}."
  end

  def destroy
    session[:user_id] = nil
    session[:access_token] = nil
    session[:per_page] = nil

    redirect_to root_url, notice: "Bye!"
  end
  
  def set_per_page
    session[:per_page] = params[:per_page].to_i
    redirect_to :back
  end
end