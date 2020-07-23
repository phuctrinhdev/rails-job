module CookiesHistory
  def set_job_histories
    arr_job_ids = cookies[:job_ids_history].to_s.split(",")
    unless arr_job_ids.include? (@job.id.to_s)
      arr_job_ids.shift if arr_job_ids.count == 10
      arr_job_ids << @job.id.to_s
    end
    cookies[:job_ids_history] = { value: arr_job_ids.join(","), expires: Time.now + 3600 }
  end
end