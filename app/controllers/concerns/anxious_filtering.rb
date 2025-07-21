module AnxiousFiltering
  private

  def filter_articles(articles, field)
    unless [ "status", "created_at" ].include?(field)
      raise ErrorHandling::InvalidFilterError, "Invalid filter field '#{field}': must use either 'status' or 'created_at'."
    end

    return articles unless params[field].present?

    value = params[field]
    articles.where(field => value)
  end
end
