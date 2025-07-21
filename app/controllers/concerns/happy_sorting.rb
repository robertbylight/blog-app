module HappySorting
  private

  def sort_articles(articles)
    return articles unless params[:sort_by].present?

    unless [ "title", "created_at" ].include?(params[:sort_by])
      raise ErrorHandling::InvalidSortError,
      "Invalid sort param '#{params[:sort_by]}': allowed fields are 'title', 'created_at'"
    end

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
