class Job < ApplicationRecord
  scope :by_cities, -> (city_id) {includes(:cities).where("cities.id = ?", city_id).references(:cities)}
  scope :by_industries, -> (industry_id) {includes(:industries).where("industries.id = ?", industry_id).references(:industries)}
  scope :by_companies, -> (company_id) {where("company_id = ?", company_id)}

  EXPORT_CSV_ATTRIBUTES = %w(title updated_date_job level years_of_experience salary expiration_date).freeze
  
  belongs_to :company

  has_many :applies
  has_many :users, through: :applies
  has_many :histories
  has_many :users, through: :histories
  has_many :favorites
  has_many :users, through: :favorites

  has_and_belongs_to_many :industries
  has_and_belongs_to_many :cities

  validate :updated_date_job_cannot_be_greater_than_expiration_date
  
  validates :title, length: { minimum: 6 }
  validates :title, :updated_date_job, :level, :expiration_date, :salary, :min_salary, :max_salary, presence: true
  validates :min_salary, :max_salary, numericality: { only_integer: true }

  def updated_date_job_cannot_be_greater_than_expiration_date
    if DateTime.parse(updated_date_job).to_i > DateTime.parse(expiration_date).to_i
      errors.add(:updated_date_job, "can't be greater than expiration date")
    end
  end

  def self.latest_jobs
    @latest_jobs ||= includes(:cities, :company).last(Settings.home.limit)
  end

  def self.related_jobs(company_id, job_id)
    @related_jobs ||= includes(:cities, :company).where.not(id: job_id)
                                                 .where(company_id: company_id)
                                                 .limit(10)
  end
end
