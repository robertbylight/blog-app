class ArticlesController < ApplicationController
  def index
    render json: articles
  end

  private

  def articles
    is_using_pagination = params[:page].present? || params[:per_page].present?

    if is_using_pagination
      page = params[:page].to_i > 0 ? params[:page].to_i : 1
      per_page = params[:per_page].to_i > 0 ? params[:per_page].to_i : 2
      Article.paginate(page: page, per_page: per_page)
    else
      Article.all
    end
  end
end
