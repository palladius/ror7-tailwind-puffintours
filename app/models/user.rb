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

  acts_as_voter
  acts_as_tagger

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

  protected

  def password_required?
    new_record? || password.present?
  end
end
