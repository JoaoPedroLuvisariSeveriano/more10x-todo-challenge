require "test_helper"

class CategoryTest < ActiveSupport::TestCase
  test "is valid with a name" do
    assert Category.new(name: "Work").valid?
  end

  test "requires a name" do
    category = Category.new(name: "")
    assert_not category.valid?
    assert_includes category.errors[:name], "can't be blank"
  end

  test "requires a unique name (case-insensitive)" do
    Category.create!(name: "Work")
    duplicate = Category.new(name: "work")
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:name], "has already been taken"
  end

  test "has many tasks and destroys them with the category" do
    category = Category.create!(name: "Work")
    category.tasks.create!(title: "Write report")

    assert_difference "Task.count", -1 do
      category.destroy
    end
  end
end
