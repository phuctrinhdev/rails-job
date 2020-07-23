class CrawlerService
  def self.convert_salary(salary)
    return [0, 999_999_999] if salary == "Cạnh tranh"

    vn_salary = salary.tr("^[0-9]{1,2}[.,]\d{1-2}", " ")
                      .tr(",",".")
                      .split(" ")
                      .map { |s| (s.to_f*1_000_000).to_i }

    return [0, vn_salary[0]] if salary.include? "Dưới"
    return [vn_salary[0], 0] if salary.include? "Trên"

    [vn_salary[0], vn_salary[1]]
  end

  def self.imports(job_attributes, company_attributes, cities, industries)
    raise Exception.new "Not enough data transferred" if job_attributes.nil? || company_attributes.nil? || cities.nil? || industries.nil?
    ActiveRecord::Base.transaction do
      job_attributes[:company_id] = Company.find_or_create_by!(company_attributes).id
      job = Job.find_or_create_by!(job_attributes)
      if job.errors.full_messages.present?
        raise Exception.new "#{job.errors.full_messages.join(",")}"
        raise ActiveRecord::Rollback
      end
      cities = cities.map do |city|
        City.find_or_create_by({title: city})
      end
      industries = industries.map do |industry|
        Industry.find_or_create_by({title: industry})
      end
      cities.each do |city|
        job.cities << city
      end
      industries.each do |industry|
        job.industries << industry
      end
    end
  end
end