class UsersController < ApplicationController
  before_action :authenticate_user!

  def info
  end

  def apply_jobs
    @applied_jobs = Apply.where("user_id = #{current_user.id}")
  end

  def favorite_jobs
    @favorite_jobs = Favorite.where("user_id = #{current_user.id}")
  end

  def apply_or_favorite_jobs
    if params[:job_ids].present?
      params[:job_ids].each do |id|
        if params[:type] == "apply"
          Apply.find_or_create_by({:user_id => current_user.id, :job_id => id})
        else
          Favorite.find_or_create_by({:user_id => current_user.id, :job_id => id})
        end
      end
      payload = {
        message: "Thank you for #{params[:type] == "apply" ? "applied" : "favourited"} with VenJob",
      }
      render :json => payload, :status => :ok
    end
  end

  def remove_favorite_job
    if params[:favorite_id].present?
      Favorite.find_by(id: params[:favorite_id]).destroy
      payload = {
        message: "Remove successfully"
      }
      render :json => payload, :status => :ok
    end
  end
end
