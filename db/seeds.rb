if User.none?
  10.times do
    User.create!(
      name: Faker::Name.name,
      email: Faker::Internet.email,
      password: "1234asdf"
    )
  end
end

if Article.none?
  20.times do
    Article.create!(
      title: Faker::Commerce.product_name,
      body: Faker::Lorem.paragraphs(number: 5).join,
      user: User.all.sample
    )
  end
end

admins = %w{
  ricc@google.com
  palladiusbonton@gmail.com
  riccardo.and.kate@gmail.com
}

admins.each do |email|
  User.where(email: email).first.update(is_admin: true)
end

User.first.likes Article.first
#User.first.likes Article.find(23)
