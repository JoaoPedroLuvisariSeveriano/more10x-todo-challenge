require "test_helper"

class Api::V1::CategoriesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @category = Category.create!(name: "Work")
  end

  test "index returns categories" do
    Category.create!(name: "Home")
    get "/api/v1/categories"

    assert_response :ok
    assert_equal %w[Home Work], response.parsed_body.map { |c| c["name"] }
  end

  test "show returns a category" do
    get "/api/v1/categories/#{@category.id}"

    assert_response :ok
    assert_equal "Work", response.parsed_body["name"]
  end

  test "show returns 404 json when not found" do
    get "/api/v1/categories/0"

    assert_response :not_found
    assert_equal "Category not found", response.parsed_body["error"]
  end

  test "create persists a category" do
    assert_difference "Category.count", 1 do
      post "/api/v1/categories", params: { category: { name: "Study" } }, as: :json
    end

    assert_response :created
    assert_equal "Study", response.parsed_body["name"]
  end

  test "create returns 422 with errors when invalid" do
    assert_no_difference "Category.count" do
      post "/api/v1/categories", params: { category: { name: "Work" } }, as: :json
    end

    assert_response :unprocessable_entity
    assert_includes response.parsed_body["errors"]["name"], "has already been taken"
  end

  test "create returns 400 when the category param is missing" do
    post "/api/v1/categories", params: {}, as: :json

    assert_response :bad_request
  end

  test "update changes the name" do
    patch "/api/v1/categories/#{@category.id}", params: { category: { name: "Office" } }, as: :json

    assert_response :ok
    assert_equal "Office", @category.reload.name
  end

  test "update returns 422 when invalid" do
    patch "/api/v1/categories/#{@category.id}", params: { category: { name: "" } }, as: :json

    assert_response :unprocessable_entity
    assert_includes response.parsed_body["errors"]["name"], "can't be blank"
  end

  test "update returns 404 when not found" do
    patch "/api/v1/categories/0", params: { category: { name: "X" } }, as: :json

    assert_response :not_found
  end

  test "destroy removes the category" do
    assert_difference "Category.count", -1 do
      delete "/api/v1/categories/#{@category.id}"
    end

    assert_response :no_content
  end

  test "destroy returns 404 when not found" do
    delete "/api/v1/categories/0"

    assert_response :not_found
  end
end
