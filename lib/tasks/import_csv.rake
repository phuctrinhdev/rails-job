require 'csv'

namespace :import do
  desc "Import CSV"

  task csv: :environment do
    

    csv_text = File.read('jobs.csv')
    csv = CSV.parse(csv_text, :headers => true)
    csv.each do |row|
      # Job attributes
      job_attributes = {
        title: row[9],
        level: row[8],
        salary: row[11],
        job_description: row[7],
        company_id: nil,
      }
      # Company attributes
      company_attributes = {
        title: row[5],
        address: row[2],
        logo: "https://via.placeholder.com/66x38?text=Logo",
        description: row[14]
      }
      # Check exist or create company
      job_attributes[:company_id] = check_exist_or_create_company(company_attributes)
      # Create job
      job = check_exist_or_create_job(job_attributes)
      if job.cities.count == 0 && job.industries.count == 0
        # Industry
        industry = check_exist_or_create_industry(row[1])
        # Industry job
        job.industries << industry
        # City
        city = check_exist_or_create_city(row[16].gsub('["',"").gsub('"]',""))
        # City job
        job.cities << city
      end
    end
  end
  
  def check_exist_or_create_company(company_attributes)
    find_company = Company.find_or_create_by(company_attributes)
    return find_company.id
  end

  def check_exist_or_create_industry(industry_title)
    industries = Industry.where("title LIKE ?", industry_title)
    if industries.count == 0
      industry = Industry.create(title: industry_title)
    else
      industry = industries[0]
    end
    return industry
  end

  def check_exist_or_create_city(city_title)
    cities = City.where("title LIKE ?", city_title)
    if cities.count == 0
      city = City.create(title: city_title)
    else
      city = cities[0]
    end
    return city
  end

  def check_exist_or_create_job(job_attributes)
    job = Job.find_or_create_by(job_attributes)
    return job
  end
end
