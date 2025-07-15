module HappySorting
  private

  def sort_articles(articles)
    return articles unless params[:sort_by].present?

    case params[:sort_by]
    when "title"
      articles.order(title: sort_order)
    when "created_at"
      articles.order(created_at: sort_order)
    else
      articles
    end
  end

  def sort_order
    params[:sort_order]&.downcase == "desc" ? :desc : :asc
  end
end
