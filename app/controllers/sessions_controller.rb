class SessionsController < ApplicationController
  require 'rest-client'

  def create
    auth = request.env["omniauth.auth"]
    token = auth["credentials"]["token"]
    user = User.where(provider: auth["provider"], uid: auth["uid"]).first_or_create! do |u|
      u.regenerate_token
      # adding the initial token to the search feature in babili when signing up the first time start
      url = "#{Rails.application.secrets.provider_site}/v1/oread_applications/set_access_token"
      host = request.protocol + request.host
      port = request.port
      begin
        response = RestClient.post url, {token: u.token, host: host, port: port}, {:Authorization => "Bearer #{token}"}
        flash[:success] = "Search token created. #{response}"
      rescue RestClient::ExceptionWithResponse => e
        flash[:alert] = "Server ist returning #{e}. Search token for babili not created."
      end
      # adding token to babili end
    end
   
    # get accessibilities on every log in start
    crud_url = "#{Rails.application.secrets.provider_site}/v1/my/accessibilities/crud/#{Rails.application.secrets.client_id}"
    projects_url = "#{Rails.application.secrets.provider_site}/v1/my/accessibilities/projects/#{Rails.application.secrets.client_id}"

    crud_response = RestClient.get crud_url, {:Authorization => "Bearer #{token}"}
    crud = JSON.parse(crud_response.body, object_class: OpenStruct)

    projects_response = RestClient.get projects_url, {:Authorization => "Bearer #{token}"}
    projects = JSON.parse(projects_response.body, object_class: OpenStruct)

    user.memberships.destroy_all
    groups = []
    
    projects.each do |project|
      group = Group.where(name: project.name).first_or_create! do |g|
        g.gid = project.id
        g.provider = 'babili'
      end
      # gruppen aus denen der user gelöscht wird verbleiben
      groups << group
    end
    user.groups = groups
    user.app_admin = crud.can_manage
    user.app_creator = crud.can_create
    user.app_publisher = crud.can_publish
    user.app_commentator = crud.can_comment
    # accessibilities update end

    user.email = auth["info"]["email"]
    user.name = auth["info"]["name"]
    user.gender = auth["info"]["gender"]
    user.birthday = auth["info"]["birthday"]
    user.image_thumb_url = auth["info"]["image_thumb_50"]

    user.save

    session[:user_id] = user.id
    session[:access_token] = auth["credentials"]["token"]

    redirect_to (session[:user_return_to] || request.env['omniauth.origin'] || root_url), notice: "You have been signed in through #{user.provider.humanize}."
    session[:user_return_to] = nil
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