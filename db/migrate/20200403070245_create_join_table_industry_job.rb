class CreateJoinTableIndustryJob < ActiveRecord::Migration[6.0]
  def change
    create_join_table :industries, :jobs do |t|
      t.index [:industry_id, :job_id]
      t.index [:job_id, :industry_id]
    end
  end
end
