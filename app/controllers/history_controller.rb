class HistoryController < ApplicationController
  def index
    if user_signed_in?
      @jobs_history = History.includes(:job, :user).where(user_id: current_user.id).order(updated_at: :desc)
    else
      job_ids = cookies[:job_ids_history].split(",")
      @jobs_history = Job.find(job_ids).reverse
    end
  end
end