module SharedHelper
  def title(page_title, show_header = true)
    content_for(:title) { h(page_title.to_s) }
    @show_header = show_header
  end
end