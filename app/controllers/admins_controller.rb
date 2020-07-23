class AdminsController < ApplicationController
  before_action :authenticate_admin!

  def applies
    @cities = City.order("title ASC").all
    @industries = Industry.order("title ASC").all
    query_params = "*"
    if params[:user_email] && params[:user_email] != ""
      query_params << "AND user_email:#{params[:user_email]}"
    end
    if params[:city_ids] && params[:city_ids] != ""
      query_params << "AND city_ids:#{params[:city_ids]}"
    end
    if params[:industry_ids] && params[:industry_ids] != ""
      query_params << "AND industry_ids:#{params[:industry_ids]}"
    end
    if params[:applied_at_from] && params[:applied_at_from] != "" && params[:applied_at_to] && params[:applied_at_to] == ""
      query_params << "AND applied_at:[#{params[:applied_at_from].to_time.to_i} TO *]"
    elsif params[:applied_at_from] && params[:applied_at_from] != "" && params[:applied_at_to] && params[:applied_at_to] != ""
      query_params << "AND applied_at:[#{params[:applied_at_from].to_time.to_i} TO #{params[:applied_at_to].to_time.to_i}]"
    end
    
    @applies = RsolrService.new.query_apply(query_params,params[:page])
  end
  def export_csv
    # csv = ExportCsvService.new(Job.all.limit(10), Job::EXPORT_CSV_ATTRIBUTES)
    # respond_to do |format|
    #   format.csv { send_data csv.perform,
    #     filename: "jobs.csv" }
    # end
  end
end
