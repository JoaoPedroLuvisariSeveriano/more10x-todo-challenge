require "test_helper"

class Api::V1::TasksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @work = Category.create!(name: "Work")
    @home = Category.create!(name: "Home")
    @a = Task.create!(title: "A", category: @work, status: :pending, priority: :high)
    @b = Task.create!(title: "B", category: @work, status: :completed, priority: :low)
    @c = Task.create!(title: "C", category: @home, status: :pending, priority: :low)
  end

  def titles
    response.parsed_body.map { |t| t["title"] }.sort
  end

  test "index returns tasks with their category" do
    get "/api/v1/tasks"

    assert_response :ok
    assert_equal %w[A B C], titles
    assert_equal({ "id" => @work.id, "name" => "Work" }, response.parsed_body.find { |t| t["title"] == "A" }["category"])
  end

  test "index avoids N+1 queries on categories" do
    queries = []
    counter = ->(*, payload) { queries << payload[:sql] if payload[:sql].match?(/FROM "categories"/) }
    ActiveSupport::Notifications.subscribed(counter, "sql.active_record") { get "/api/v1/tasks" }

    assert_equal 1, queries.size
  end

  test "index filters by category" do
    get "/api/v1/tasks", params: { category_id: @home.id }
    assert_equal %w[C], titles
  end

  test "index filters by status" do
    get "/api/v1/tasks", params: { status: "completed" }
    assert_equal %w[B], titles
  end

  test "index filters by priority" do
    get "/api/v1/tasks", params: { priority: "high" }
    assert_equal %w[A], titles
  end

  test "index combines filters" do
    get "/api/v1/tasks", params: { category_id: @work.id, status: "pending", priority: "high" }
    assert_equal %w[A], titles

    get "/api/v1/tasks", params: { category_id: @work.id, status: "pending", priority: "low" }
    assert_empty response.parsed_body
  end

  test "show returns a task with category" do
    get "/api/v1/tasks/#{@a.id}"

    assert_response :ok
    assert_equal "Work", response.parsed_body["category"]["name"]
  end

  test "show returns 404 when not found" do
    get "/api/v1/tasks/0"

    assert_response :not_found
    assert_equal "Task not found", response.parsed_body["error"]
  end

  test "create persists a task" do
    assert_difference "Task.count", 1 do
      post "/api/v1/tasks", params: { task: { title: "New", description: "d", status: "in_progress", priority: "high", due_date: "2026-12-01", category_id: @work.id } }, as: :json
    end

    assert_response :created
    body = response.parsed_body
    assert_equal "in_progress", body["status"]
    assert_equal "2026-12-01", body["due_date"]
    assert_equal "Work", body["category"]["name"]
  end

  test "create returns 422 when invalid" do
    post "/api/v1/tasks", params: { task: { title: "", category_id: @work.id, status: "bogus" } }, as: :json

    assert_response :unprocessable_entity
    errors = response.parsed_body["errors"]
    assert errors["title"].any?
    assert errors["status"].any?
  end

  test "create returns 422 without a category" do
    post "/api/v1/tasks", params: { task: { title: "Orphan" } }, as: :json

    assert_response :unprocessable_entity
    assert response.parsed_body["errors"]["category"].any?
  end

  test "update changes attributes" do
    patch "/api/v1/tasks/#{@a.id}", params: { task: { status: "completed", category_id: @home.id } }, as: :json

    assert_response :ok
    assert @a.reload.completed?
    assert_equal @home, @a.category
  end

  test "update returns 422 when invalid" do
    patch "/api/v1/tasks/#{@a.id}", params: { task: { title: "" } }, as: :json
    assert_response :unprocessable_entity
  end

  test "destroy removes the task" do
    assert_difference "Task.count", -1 do
      delete "/api/v1/tasks/#{@a.id}"
    end
    assert_response :no_content
  end

  test "destroy returns 404 when not found" do
    delete "/api/v1/tasks/0"
    assert_response :not_found
  end
end
