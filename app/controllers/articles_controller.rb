class ArticlesController < ApplicationController
  helper_method :article
  helper_method :articles
  
  def index
    respond_to do |format|
      format.html
    end
  end

  def show
    respond_to do |format|
      format.html
    end
  end

  def publish
    
  end

  def unpublish

  end

  private

  def article
    @article ||= Article.find(params[:id])
  end

  def articles
    @articles ||= Article.all.order(:created_at => 1).to_a
  end
end
