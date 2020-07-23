require "rsolr"

class RsolrService
  attr_accessor :solr_job, :job
  def initialize
    @solr_job = RSolr.connect :url => "http://localhost:8983/solr/job"
    @job = nil
  end

  def query_job(query_params, page)
    job = solr_job.paginate page, Settings.search.limit, "select", :params => {
      :q=>query_params
    }
  end
end