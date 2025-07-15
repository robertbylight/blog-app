class ArticlesController < ApplicationController
  include HappySorting
  include AnxiousFiltering

  def index
    render json: {
      articles: articles,
      meta: pagination_meta(articles)
    }
  end

  private

  def articles
    article_list = Article.all
    article_list = sort_articles(article_list)
    article_list = filter_articles(article_list, params[:filter_by]) if params[:filter_by].present?

    is_using_pagination = params[:page].present? || params[:per_page].present?

    if is_using_pagination
      page = params[:page].to_i > 0 ? params[:page].to_i : 1
      per_page = params[:per_page].to_i > 0 ? params[:per_page].to_i : 2
      article_list.paginate(page: page, per_page: per_page)
    else
      article_list
    end
  end

  def pagination_meta(articles)
    return {} unless articles.respond_to?(:current_page)

    {
      current_page: articles.current_page,
      total_pages: articles.total_pages,
      total_articles: articles.total_entries
    }
  end
end
