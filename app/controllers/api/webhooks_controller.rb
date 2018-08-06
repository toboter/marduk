class Api::WebhooksController < ActionController::API
  require 'rest-client'
  require 'json'

  before_action :set_token

  # application_url/v1/hooks/update_accessibilities?access_token=babili-token
  def update_user_accessibilities
    user_url = "#{Rails.application.secrets.provider_site}/v1/user"
    crud_url = "#{Rails.application.secrets.provider_site}/v1/my/accessibilities/crud/#{Rails.application.secrets.client_id}"
    projects_url = "#{Rails.application.secrets.provider_site}/v1/my/accessibilities/projects/#{Rails.application.secrets.client_id}"

    user_response = RestClient.get user_url, {:Authorization => "Bearer #{@token}"}
    user_parsed = JSON.parse(user_response.body)

    crud_response = RestClient.get crud_url, {:Authorization => "Bearer #{@token}"}
    crud = JSON.parse(crud_response.body, object_class: OpenStruct)

    projects_response = RestClient.get projects_url, {:Authorization => "Bearer #{@token}"}
    projects = JSON.parse(projects_response.body, object_class: OpenStruct)

    user = User.where(provider: 'babili', uid: user_parsed['id']).first
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

    if user.save
      render json: {message: 'updated', status: 200}, status: :ok
    else
      render json: {message: 'failed', status: 400}, status: :bad_request
    end

    # raise user.inspect
    # erwartet oauth access token für babili
    # fragt nach user.accessibilities mit access token
  end

  # application_url/v1/hooks/upload_local_user_token?access_token=babili-token
  def add_token_to_babili
    user_url = "#{Rails.application.secrets.provider_site}/v1/user"
    user_response = RestClient.get user_url, {:Authorization => "Bearer #{@token}"}
    user_parsed = JSON.parse(user_response.body)

    user = User.where(provider: 'babili', uid: user_parsed['id']).first

    url = "#{Rails.application.secrets.provider_site}/v1/oread_applications/set_access_token"
    host = request.protocol + request.host
    port = request.port
    begin
      response = RestClient.post url, {token: user.token, host: host, port: port}, {:Authorization => "Bearer #{@token}"} 
      render json: {message: 'updated', status: 200}, status: :ok
    rescue RestClient::ExceptionWithResponse => e
      render json: {message: "failed with #{e}", status: 400}, status: :bad_request
    end

    # raise user.inspect
    # erwartet oauth access token für babili
    # sendet token mithilfe oauth access token an babili
  end

  private
  def set_token
    @token = request.headers['Authorization'] ? request.headers['Authorization'].split(' ').last : params[:access_token]
  end

end