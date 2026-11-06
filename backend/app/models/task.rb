class Task < ApplicationRecord
  belongs_to :category

  enum :status, { pending: 0, in_progress: 1, completed: 2 }, validate: true
  enum :priority, { low: 0, medium: 1, high: 2 }, validate: true

  validates :title, presence: true

  scope :by_category, ->(category_id) { where(category_id: category_id) if category_id.present? }
  scope :by_status, ->(status) { where(status: status) if status.present? }
  scope :by_priority, ->(priority) { where(priority: priority) if priority.present? }
end
