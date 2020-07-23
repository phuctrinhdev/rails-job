class JobsController < ApplicationController
  include CookiesHistory

  def index
    if params[:city_id]
      @jobs = Job.by_cities(params[:city_id]).page(params[:page])
      @amount_job = Job.by_cities(params[:city_id]).count
    elsif params[:industry_id]
      @jobs = Job.by_industries(params[:industry_id]).page(params[:page])
      @amount_job = Job.by_industries(params[:industry_id]).count
    elsif params[:company_id]
      @jobs = Job.by_companies(params[:company_id]).page(params[:page])
      @amount_job = Job.by_companies(params[:company_id]).count
    else
      @jobs = Job.order(id: :desc).page(params[:page])
      @amount_job = Job.count
    end
  end

  def show
    @job = Job.find_by(id: params[:id])
    return redirect_to page_404_path if @job.blank?
    if user_signed_in?
      @apply = Apply.find_by(job_id: params[:id], user_id: current_user.id)
      @favorite = Favorite.find_by(job_id: params[:id], user_id: current_user.id)
      @history = History.find_by(user_id: current_user.id, job_id: params[:id])
      if @history.nil?
        History.create(user_id: current_user.id, job_id: params[:id])
      else
        @history.update(updated_at: Time.now)
      end
    else
      set_job_histories
    end
    @relate_jobs = Job.related_jobs(@job.company_id, @job.id)
  end
  
  def search
    return redirect_to root_path, alert: "Empty field!" if params[:keyword].blank?
    response = RsolrService.new.query_job("job_title:#{params[:keyword]}", params[:page])
    @jobs = response["response"]["docs"]
    @amount_job = response["response"]["numFound"]
  end
end
