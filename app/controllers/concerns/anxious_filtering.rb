module AnxiousFiltering
  private

  def filter_articles(articles, field)
    return articles unless params[field].present?

    value = params[field]
    articles.where(field => value)
  end
end
