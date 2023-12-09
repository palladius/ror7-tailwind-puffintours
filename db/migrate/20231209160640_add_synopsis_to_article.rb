class AddSynopsisToArticle < ActiveRecord::Migration[7.0]
  def change
    add_column :articles, :article_synopsis, :text
    add_column :articles, :main_image_synopsis, :text
  end
end
