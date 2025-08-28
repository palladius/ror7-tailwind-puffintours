require "test_helper"

class CommentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @article = articles(:one)
    @comment = comments(:one)
    @comment.article = @article
    @comment.save
  end

  test "should get index" do
    get article_comments_url(@article)
    assert_response :success
  end

  test "should get new" do
    get new_article_comment_url(@article)
    assert_response :success
  end

  test "should create comment" do
    assert_difference("Comment.count") do
      post article_comments_url(@article), params: { comment: { active: @comment.active, body: @comment.body, internal_notes: @comment.internal_notes, parent_id: @comment.parent_id, vote: @comment.vote } }
    end

    assert_redirected_to article_comment_url(@article, Comment.last)
  end

  test "should show comment" do
    get article_comment_url(@article, @comment)
    assert_response :success
  end

  test "should get edit" do
    get edit_article_comment_url(@article, @comment)
    assert_response :success
  end

  test "should update comment" do
    patch article_comment_url(@article, @comment), params: { comment: { active: @comment.active, body: @comment.body, internal_notes: @comment.internal_notes, parent_id: @comment.parent_id, vote: @comment.vote } }
    assert_redirected_to article_comment_url(@article, @comment)
  end

  test "should destroy comment" do
    assert_difference("Comment.count", -1) do
      delete article_comment_url(@article, @comment)
    end

    assert_redirected_to article_comments_url(@article)
  end
end
