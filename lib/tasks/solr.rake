require "rsolr"
namespace :solr do
  desc "Solr management"

  solr_job = RSolr.connect :url => "http://localhost:8983/solr/job"

  task import_job: :environment do
    hash_jobs = []
    Job.find_each do |item|
      job = { 
        apply_count: item.applies.size,
        city_ids: item.cities.pluck(:id),
        city_names: item.cities.pluck(:title),
        company_id: item.company_id,
        company_name: item.company.title,
        company_address: item.company.address,
        company_description: item.company.description,
        company_logo: item.company.logo,
        created_at: item.created_at.to_i,
        expiration_date: DateTime.parse(item.expiration_date).to_i,
        favorite_count: item.favorites.size,
        industry_ids: item.industries.pluck(:id),
        industry_names: item.industries.pluck(:title),
        job_description: item.job_description,
        job_benefit: item.benefit,
        job_id: item.id, 
        job_other_information: item.other_information,
        job_requirements: item.job_requirements,
        job_title: item.title,
        level: item.level,
        max_salary: item.max_salary,
        min_salary: item.min_salary,
        salary: item.salary,
        updated_date_job: DateTime.parse(item.updated_date_job).to_i,
        years_of_experience: item.years_of_experience
      } 
      hash_jobs << job
    end
    solr_job.add hash_jobs
    solr_job.commit
  end
  task delete_all_job: :environment do
    solr_job.delete_by_query "*:*"
    solr_job.commit
  end
end
