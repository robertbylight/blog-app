class ArticlesController < ApplicationController
  include HappySorting
  include AnxiousFiltering

  def index
    render json: {
      articles: articles,
      meta: meta(articles)
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

  def meta(articles)
    meta = {}

    if articles.respond_to?(:current_page)
      meta.merge!({
        current_page: articles.current_page,
        total_pages: articles.total_pages,
        total_articles: articles.total_entries
      })
    end

    if params[:sort_by].present? && params[:sort_order].present?
      meta[:sort] = {
        field: params[:sort_by],
        order: params[:sort_order]
      }
    end

    if params[:filter_by].present?
      meta[:filter] = {
        field: params[:filter_by],
        value: params[params[:filter_by]]
      }
    end

    meta
  end
end
