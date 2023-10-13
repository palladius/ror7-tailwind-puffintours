class AddArticleTypeAndDateToArticle < ActiveRecord::Migration[7.0]
  def change
    add_column :articles, :article_type, :string, default: 'article'
    add_column :articles, :content_date, :date
    add_column :articles, :published, :boolean, default: true
  end
end
