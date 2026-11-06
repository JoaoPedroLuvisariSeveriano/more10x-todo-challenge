require "test_helper"

class TaskTest < ActiveSupport::TestCase
  setup do
    @work = Category.create!(name: "Work")
    @home = Category.create!(name: "Home")
    @a = Task.create!(title: "A", category: @work, status: :pending, priority: :high)
    @b = Task.create!(title: "B", category: @work, status: :completed, priority: :low)
    @c = Task.create!(title: "C", category: @home, status: :pending, priority: :low)
  end

  test "requires title and category" do
    task = Task.new
    assert_not task.valid?
    assert_includes task.errors[:title], "can't be blank"
    assert_includes task.errors[:category], "must exist"
  end

  test "defaults to pending status and medium priority" do
    task = Task.create!(title: "D", category: @work)
    assert task.pending?
    assert task.medium?
  end

  test "rejects invalid enum values" do
    task = Task.new(title: "X", category: @work, status: "bogus")
    assert_not task.valid?
    assert task.errors[:status].any?
  end

  test "by_category filters" do
    assert_equal [@a, @b].sort, Task.by_category(@work.id).to_a.sort
  end

  test "by_status filters" do
    assert_equal [@a, @c].sort, Task.by_status("pending").to_a.sort
  end

  test "by_priority filters" do
    assert_equal [@b, @c].sort, Task.by_priority("low").to_a.sort
  end

  test "scopes combine" do
    assert_equal [@c], Task.by_category(@home.id).by_status("pending").by_priority("low").to_a
  end

  test "blank filters return everything" do
    assert_equal 3, Task.by_category(nil).by_status("").by_priority(nil).count
  end
end
