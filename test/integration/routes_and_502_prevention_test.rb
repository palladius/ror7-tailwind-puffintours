require "test_helper"

class RoutesAnd502PreventionTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:one)
    @regular_user = users(:two)
    @public_article = articles(:one)
    @private_article = articles(:two)
  end

  test "GET /up returns 200 OK for Render fast healthcheck" do
    get "/up"
    assert_response :success
  end

  test "GET /articles with overflow page number returns 200 instead of 500 Pagy::OverflowError" do
    get articles_url(page: 999)
    assert_response :success
  end

  test "GET /users with overflow page number returns 200 instead of 500 Pagy::OverflowError" do
    sign_in @admin
    get users_url(page: 999)
    assert_response :success
  end

  test "User.ransackable_attributes includes created_at and is_admin for /users table sorting" do
    assert_includes User.ransackable_attributes, "created_at"
    assert_includes User.ransackable_attributes, "is_admin"
  end

  test "all public pages return 200 OK and render expected UI elements" do
    [
      root_path,
      articles_path,
      article_path(@public_article),
      tag_path("puffintours"),
      page_path(:graphs),
      page_path(:about_us),
      page_path(:about_the_app),
      page_path(:privacy_policy),
      new_user_session_path,
      new_user_registration_path
    ].each do |path|
      get path
      assert_response :success, "Expected 200 OK on #{path}, got #{response.status}"
    end

    # Verify Glassmorphic + A2UI switcher and cover badges on /articles
    get articles_path
    assert_select "#btn-view-glass"
    assert_select "#btn-view-a2ui"
    assert_select "#puffin-a2ui-view"
    assert_match(/🌍/, response.body)
    assert_match(/🔑/, response.body)
  end

  test "authenticated routes return 200 OK for signed in user" do
    sign_in @admin

    [
      users_path,
      "/users/#{@admin.id}",
      edit_user_path,
      family_path,
      new_article_path,
      edit_article_path(@public_article)
    ].each do |path|
      get path
      assert_response :success, "Expected 200 OK on #{path}, got #{response.status}"
    end
  end

  test "article CRUD and minimalist 5-star rating widget work end-to-end" do
    sign_in @admin

    assert_difference("Article.count", 1) do
      post articles_path, params: {
        article: {
          title: "TDD Family Adventure in Lisbon",
          body: "<p>Exploring Lisbon trams with Ale and Seby.</p>",
          article_type: "trip",
          published: true,
          tag_list: "lisbon, family"
        }
      }
    end

    created = Article.order(:id).last
    assert_redirected_to article_path(created)
    follow_redirect!
    assert_response :success
    assert_select "#minimal-star-picker button[data-star]", count: 5
    assert_match(/✍️ Edit Story/, response.body)
    assert_match(/🗑️ Destroy/, response.body)
  end

  test "video ActionText attachment renders HTML5 video player with controls" do
    video_blob = ActiveStorage::Blob.create_and_upload!(
      io: StringIO.new("fake-mp4-bytes"),
      filename: "family_clip.mp4",
      content_type: "video/mp4"
    )
    @public_article.update!(body: "<p>Watch our video:</p><action-text-attachment sgid=\"#{video_blob.attachable_sgid}\"></action-text-attachment>")

    get article_path(@public_article)
    assert_response :success
    assert_select "video[controls]"
  end

  test "image ActionText attachment renders direct blob URL without requiring MiniMagick convert representation" do
    png_bytes = Base64.decode64("iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==")
    img_blob = ActiveStorage::Blob.create_and_upload!(
      io: StringIO.new(png_bytes),
      filename: "trix_paste.png",
      content_type: "image/png"
    )
    @public_article.update!(body: "<p>Pasted photo:</p><action-text-attachment sgid=\"#{img_blob.attachable_sgid}\"></action-text-attachment>")

    get article_path(@public_article)
    assert_response :success
    refute_match(%r{/rails/active_storage/representations/}, response.body,
      "Image blob partial must not generate /representations/ URLs that require ImageMagick 'convert' binary")
    assert_match(%r{/rails/active_storage/blobs/|storage\.googleapis\.com/puffintours-assets/}, response.body)
  end

  test "non-GCP environment does not hang on metadata server when rendering /pages/graphs" do
    # Simulate Render environment where neither K_SERVICE nor local secret key file exist
    old_k_service = ENV["K_SERVICE"]
    ENV.delete("K_SERVICE")
    begin
      t0 = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      get page_path(:graphs)
      elapsed = Process.clock_gettime(Process::CLOCK_MONOTONIC) - t0
      assert_response :success
      assert_operator elapsed, :<, 2.0, "Expected /pages/graphs to render quickly without hanging on metadata server"
    ensure
      ENV["K_SERVICE"] = old_k_service if old_k_service
    end
  end

  test "entrypoint and puma config do not block port binding with a separate rake db:migrate process" do
    entrypoint = File.read(Rails.root.join("entrypoint-8080.sh"))
    refute_match(/^RAILS_ENV=production bundle exec rake db:migrate/, entrypoint,
      "entrypoint-8080.sh must not unconditionally run rake db:migrate at top-level before Puma binds to $PORT")
    assert_match(/RUN_DB_MIGRATE:-false/, entrypoint)

    puma_config = File.read(Rails.root.join("config/puma.rb"))
    assert_match(/persistent_timeout/, puma_config,
      "config/puma.rb should configure persistent_timeout >= 60s to prevent Render 502 connection resets")
    assert_match(/after_booted/, puma_config)
  end

  test "admin_show debug partial renders safely even when @pipeline_body_result is nil" do
    rendered = ApplicationController.render(
      partial: "articles/admin_show",
      assigns: { article: @public_article, pipeline_body_result: nil }
    )
    assert_match(/Insights on images and videos/, rendered)
  end

  test "GcpHelper#gcp_keyfile_path detects /tmp/gcp-sa.json and default bucket is puffintours-assets" do
    helper = Object.new.extend(GcpHelper)
    tmp_key = "/tmp/gcp-sa-test-probe.json"
    File.write(tmp_key, '{"type":"service_account"}')
    assert_equal tmp_key, helper.gcp_keyfile_path(custom_fallback: tmp_key).to_s
    assert_equal "puffintours-assets", GcsBucket
  ensure
    File.delete(tmp_key) if tmp_key && File.exist?(tmp_key)
  end

  test "unauthenticated user visiting /articles/new is redirected to /users/sign_in" do
    get new_article_path
    assert_redirected_to new_user_session_path
  end

  test "signed in user can create article even with short title or empty body" do
    sign_in @admin
    assert_difference("Article.count", 1) do
      post articles_path, params: {
        article: {
          title: "Ciao",
          body: ""
        }
      }
    end
    assert_response :redirect
  end

  test "article card cover falls back to Trix embedded image when main_image is not attached" do
    png_bytes = Base64.decode64("iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==")
    trix_blob = ActiveStorage::Blob.create_and_upload!(
      io: StringIO.new(png_bytes),
      filename: "trix_cover.png",
      content_type: "image/png"
    )
    @public_article.update!(body: "<p>With trix photo</p><action-text-attachment sgid=\"#{trix_blob.attachable_sgid}\"></action-text-attachment>")

    get articles_path
    assert_response :success
    assert_match(/trix_cover\.png|#{trix_blob.key}/, response.body,
      "Expected /articles card cover to use Trix embedded image when main_image is blank")
  end

  test "article card cover does not render non-image video blob inside img tag" do
    video_blob = ActiveStorage::Blob.create_and_upload!(
      io: StringIO.new("fake-mp4-bytes"),
      filename: "not_an_image.mp4",
      content_type: "video/mp4"
    )
    @public_article.main_image.attach(video_blob)

    get articles_path
    assert_response :success
    refute_match(/not_an_image\.mp4/, response.body,
      "Video blobs must not be rendered inside card cover <img> src")
  end
end
