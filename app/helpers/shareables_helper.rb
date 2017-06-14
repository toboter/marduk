module ShareablesHelper
  def shared_with(obj)
    render partial: 'shareables/list', locals: {obj: obj} # if !obj.published?
  end
end
