class HomeController < ApplicationController
  def index
    @amount_job = Job.count
    @latest_jobs = Job.latest_jobs
    @latest_cities = City.jobs_count_order_by
    @latest_industries = Industry.jobs_count_order_by
  end
end
