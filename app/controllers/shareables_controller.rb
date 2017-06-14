class ShareablesController < ApplicationController
  before_action :authorize
  before_action :set_shareable, only: [:edit, :update, :destroy]

  def new
  end

  def create
    resource_klass = params[:resource_type].classify.constantize
    @resource = resource_klass.find(params[:resource_id])
    share_to = eval(params[:share_to])
    share_to_klass = share_to.first.classify.constantize
    @share_to = share_to_klass.find(share_to.last)

    respond_to do |format|
      if @resource.share_it(current_user, @share_to, edit)
        format.html { redirect_to @resource, notice: 'Share was successfully created.' }
        format.js
      else
        format.html { render :new }
        format.js
      end
    end
  end

  def edit
  end

  def update
    respond_to do |format|
      if @shareable.update(shareable_params)
        format.html { redirect_to @shareable.resource, notice: 'Share was successfully updated.' }
        format.js
      else
        format.html { render :edit }
        format.js
      end
    end
  end

  def destroy
    @shareable.resource.throw_out(current_user, @shareable.shared_to)
    respond_to do |format|
      format.html { redirect_to @shareable.resource, notice: 'Share was successfully destroyed.' }
      format.js
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_shareable
      @shareable = ShareModel.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def shareable_params
      params.require(:shareable).permit(:resource_type, :resource_id, :shared_to, :edit)
    end

end
