class UsersController < ApplicationController
  require 'rest-client'
  before_action :authorize
  before_action :administrative, only: [:index, :update, :destroy]
  before_action :set_user, only: [:update, :destroy]

  def index
    @users = User.all
  end

  # GET /users/1
  # GET /users/1.json
  def settings

  end

  # GET /users/new
  def new
    @user = User.new
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(user_params)

    respond_to do |format|
      if @user.save
        format.html { redirect_to @user, notice: 'User was successfully created.' }
        format.json { render :show, status: :created, location: @user }
      else
        format.html { render :new }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to @user, notice: 'User was successfully updated.' }
        format.js
      else
        format.html { render :edit }
        format.js
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user.destroy
    respond_to do |format|
      format.html { redirect_to users_url, notice: 'User was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def add_token_to_babili
    if current_user.regenerate_token
      url = "#{Rails.application.secrets.provider_site}/api/oread_applications/set_access_token"
      host = request.protocol + request.host
      port = request.port
      begin
        response = RestClient.post url, {token: current_user.token, host: host, port: port}, {:Authorization => "Bearer #{access_token.token}"} 
        redirect_to settings_users_url, notice: response.code == 200 ? "Token for #{JSON.parse(response.body)['name']} received." : 'An error occured.'
      rescue RestClient::ExceptionWithResponse => e
        redirect_to settings_users_url, alert: "The Server ist returning #{e}. Token not sent."
      end
    else
      redirect_to settings_users_url, alert: 'Token not created.'
    end
  end

  def update_accessibilities
    ability = current_user_app_crud_ability
    user = current_user
    user.memberships.destroy_all
    groups = []

    current_user_projects.each do |project|
      group = Group.where(name: project.name).first_or_create! do |g|
        g.gid = project.id
        g.provider = 'babili'
      end
      groups << group
    end

    user.groups = groups
    user.app_admin = ability.can_manage
    user.app_creator = ability.can_create
    user.app_publisher = ability.can_publish
    user.app_commentator = ability.can_comment

    respond_to do |format|
      if user.save
        format.html { redirect_to settings_users_url, notice: 'Your accessibilities have been successfully updated.' }
      else
        format.html { redirect_to settings_users_url, notice: 'An error occured.' }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.require(:user).permit(:token, :id, :username, :app_admin, :app_commentator, :app_creator, :app_publisher, :group_list => [])
    end

end