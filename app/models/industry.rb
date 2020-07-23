class Industry < ApplicationRecord
  validates :title, presence: true, uniqueness: true
  
  has_and_belongs_to_many :jobs

  def jobs_count
    @jobs_count ||= jobs.size
  end

  def self.jobs_count_order_by
    @jobs_count_order_by ||= includes(:jobs).sort_by(&:jobs_count).reverse.take(Settings.home.limit + 2)
  end
end
