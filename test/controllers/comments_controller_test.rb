require "test_helper"

class CommentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @article = articles(:one)
    @comment = comments(:one)
    sign_in @user
  end

  test "should get index" do
    get article_comments_url(@article)
    assert_response :success
  end

  test "should get new" do
    get new_article_comment_url(@article)
    assert_response :success
  end

  test "should create comment with text and vote" do
    assert_difference("Comment.count", 1) do
      post article_comments_url(@article), params: {
        comment: { body: "Great family trip!", vote: 5 }
      }
    end

    assert_redirected_to article_url(@article)
  end

  test "should create star rating comment without body text" do
    assert_difference("Comment.count", 1) do
      post article_comments_url(@article), params: {
        comment: { body: "", vote: 4 }
      }
    end

    assert_redirected_to article_url(@article)
    assert_equal 4, Comment.last.vote
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
    patch article_comment_url(@article, @comment), params: {
      comment: { body: "Updated comment body", vote: 5 }
    }
    assert_redirected_to article_comment_url(@article, @comment)
  end

  test "should destroy comment and redirect to article" do
    assert_difference("Comment.count", -1) do
      delete article_comment_url(@article, @comment)
    end

    assert_redirected_to article_url(@article)
  end
end
