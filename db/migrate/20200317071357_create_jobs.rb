class CreateJobs < ActiveRecord::Migration[6.0]
  def change
    create_table :jobs do |t|
      t.string :title
      t.string :updated_date_job
      t.string :level
      t.string :years_of_experience
      t.string :salary
      t.string :expiration_date

      t.text :job_description
      
      t.belongs_to :company

      t.timestamps
    end
    
  end
end
