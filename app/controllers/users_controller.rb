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
  def show
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
    current_user.regenerate_token if current_user
    if current_user && current_user.token.present?
      url = "#{Rails.application.secrets.provider_site}/api/oread_application_access_token"
      host = request.base_url
      begin
        response = RestClient.post url, {token: current_user.token, host: host}, {:Authorization => "Bearer #{access_token.token}"}
        redirect_to user_url, notice: response.code == 200 ? 'Token sent.' : 'An error occured.'
      rescue RestClient::ExceptionWithResponse => e
        redirect_to user_url, alert: "The Server ist returning #{e}. Perhaps you are not assigned to any projects. Service Token for babili not sent."
      end
    else
      redirect_to user_url, alert: 'Something went wrong.'
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