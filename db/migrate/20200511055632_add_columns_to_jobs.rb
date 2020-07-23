class AddColumnsToJobs < ActiveRecord::Migration[6.0]
  def change
    add_column :jobs, :min_salary, :bigint, default: 0
    add_column :jobs, :max_salary, :bigint, default: 0
    add_column :jobs, :benefit, :text
    add_column :jobs, :job_requirements, :text
    add_column :jobs, :other_information, :text
  end
end
