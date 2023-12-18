class CreateComments < ActiveRecord::Migration[7.0]
  def change
    create_table :comments do |t|
      t.text :body
      t.integer :article_id
      t.integer :parent_id
      t.integer :vote, default: 0
      t.text :internal_notes
      t.boolean :active, default: true
      t.integer :user_id

      t.timestamps
    end
  end
end
