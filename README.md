# Ricc Pufintours!

* Copied from https://github.com/ralixjs/rails-ralix-tailwind . Why? I am a bit lost in 4 different ways of Rails 7 to manage Js and im not a JS specialist... hence.. someone did the effort for me so why not standing on the shoulders of giants?
* Image inspiration: https://ricc.rocks/en/posts/travel/20230404-puffin-tours/

Also Kate asked me to do this:

* Posts
* Active Storage for images
* star rating

--

# 🚀 Rails + Ralix + Tailwind

> Starter Kit to build modern Rails applications fast

Powered by:

- [Rails](https://rubyonrails.org)
- [Ralix](https://github.com/ralixjs/ralix)
- [Tailwind CSS](https://tailwindcss.com)
- [PostgreSQL](https://www.postgresql.org)
- [Turbo](https://turbo.hotwired.dev)
- [esbuild](https://esbuild.github.io)

Rails v7 application template ready to start building your next project, with a pre-configured modern front-end stack and some extras:

- 🎨 Minimalistic and responsive, clean layout
- 📦 Icons pack, via [Heroicons](https://heroicons.com)
- 🔐 Authentication, via [Devise](https://github.com/heartcombo/devise) + [OmniAuth](https://github.com/omniauth/omniauth) for Social Logins
- 👥 Authorization, via [CanCanCan](https://github.com/CanCanCommunity/cancancan)
- 🔍 Searching, via [Ransack](https://github.com/activerecord-hackery/ransack)
- 📝 Rich text edition, via [Trix](https://trix-editor.org)
- 🔢 Pagination, via [Pagy](https://github.com/ddnexus/pagy)
- 📄 Static pages controller (About, Terms, ...)
- 🔴 Custom errors pages: 404, 422, 500
- 📚 *Ready-to-use* components: Tables, Buttons, Forms, Cards, Modals and Tooltips

## Install

Clone this repository (or use the GitHub *template* button), then `cd` into the folder and run:

```
> bin/setup
```

## Run

Start the development server:

```
> bin/dev
```

## INSTALL

```bash

# Acts as Votable
bundle install
rails generate acts_as_votable:migration
# add '[6.0]' to migration (gem is OLD!)
rake db:migrate

```
