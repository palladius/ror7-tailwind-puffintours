# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  name                   :string
#  is_admin               :boolean          default(FALSE)
#
class User < ApplicationRecord
  devise :database_authenticatable,
         :registerable,
         :recoverable,
         :rememberable,
         :validatable,
         :omniauthable,
         omniauth_providers: [:facebook, :google_oauth2, :github]

  has_one_attached :avatar
  has_many :articles, dependent: :destroy
  has_many :comments, dependent: :destroy

  acts_as_voter
  acts_as_tagger

  def self.ransackable_attributes(auth_object = nil)
#    ["created_at", "email", "encrypted_password", "id", "id_value", "is_admin", "name", "remember_created_at", "reset_password_sent_at", "reset_password_token", "updated_at"]
#    # Lets remove password related fields and dates or timestamps which dont make sense
    [ "email",  "name" ]
  end

  def self.ransackable_associations(auth_object = nil)
    ["articles", "avatar_attachment", "avatar_blob", "comments", "owned_taggings", "owned_tags", "votes"]
  end

  def name
    @name ||= self[:name].presence || email.split("@").first
  end

  def self.from_omniauth(auth)
    data = auth.info

    User.where(email: data['email']).first_or_create do |user|
      user.name = data['name']
      user.password = Devise.friendly_token[0,20] if user.new_record?
    end
  end

  # User.migrate_from_old_to_new('palladius.bonton@gmail.com','palladiusbonton@gmail.com', delete_old: true)
  def self.migrate_from_old_to_new(old_user_email, new_user_email, delete_old: false)
    #old_user = User.where(email: 'p.alladiusbonton@gmail.com').first
    #new_user = User.where(email: 'palladiusbonton@gmail.com').first
    old_user = User.where(email: old_user_email).first
    raise "OLD User is wrong" unless  old_user.is_a? User
    new_user = User.where(email: new_user_email).first
    raise "NEW User is wrong" unless  new_user.is_a? User
    Article.where(user: old_user).each do |a|
      a.update(user: new_user)
      a.save
    end
    if delete_old
      puts "WARNING: Will now try to delete the old user: #{old_user_email}"
      if old_user.articles.count == 0
        old_user.destroy
        puts "User destroyed: #{old_user_email}"
      else
        puts "Sorry, refusing to delete old user since they stilll have some articles left: #{old_user.articles.count}"
      end
    end
  end

  def to_s
    name
  end

  def admin?
    is_admin == true
  end

  protected

  def password_required?
    new_record? || password.present?
  end
end
