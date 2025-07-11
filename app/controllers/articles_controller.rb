class ArticlesController < ApplicationController
  def index
    render json: articles
  end
  private

  def articles
    Article.all
  end
end
