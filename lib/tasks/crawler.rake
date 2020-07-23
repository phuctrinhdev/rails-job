require "nokogiri"
require "open-uri"
require "parallel"
require "activerecord-import"

namespace :crawler do
  desc "Crawler Careerbuilder"
  
  task job: :environment do
    # Define crawler logger
    logger = Logger.new("log/crawler_logger.log")
    html_careerbuilder_list_jobs = Nokogiri::HTML.parse(URI.open("https://careerbuilder.vn/viec-lam/tat-ca-viec-lam-vi.html"))
    total_page = (html_careerbuilder_list_jobs.at_css(".search-result-list .container .job-found .job-found-amout p").text.tr(",việc làm","").to_i / 50.0).ceil
    # Loop page
    (1..total_page).each do |page|
      # Fetch and parse HTML document
      html_jobs = Nokogiri::HTML.parse(URI.open("https://careerbuilder.vn/viec-lam/tat-ca-viec-lam-trang-#{page}-vi.html"))
      # Loop item
      Parallel.each(html_jobs.css(".jobs-side-list .job-item"), in_threads: 5) { |item|
        begin
          url = item.css(".figure .figcaption .title .job_link @href").text
          html_job_detail = Nokogiri::HTML.parse(URI.open(URI.encode(url)))
          if html_job_detail.at_css(".search-result-list-detail .tabs div#tab-1").nil?
            logger.warn "Another template #{url}"
            next
          end
          # Set salary, min-salary, max-salary
          if item.at_css(".figure .figcaption .caption .salary").text.include? "USD"
            logger.warn "Another template #{url}"
            next
          end
          salary = item.at_css(".figure .figcaption .caption .salary").text.gsub("$ ","")
          min_salary, max_salary = CrawlerService.convert_salary(salary)
          # Job attributes
          job_attributes = {
            title: item.at_css(".figure .figcaption .title a @title").text,
            updated_date_job: item.at_css(".bottom-right-icon .time time").text,
            salary: salary,
            min_salary: min_salary,
            max_salary: max_salary
          }
          html_job_detail.css(".job-detail-content .row .has-background ul li").each do |ele|
            type = ele.at_css("strong").text
            case type
            when "Hết hạn nộp"
              job_attributes[:expiration_date] = ele.at_css("p").text.squish
            when "Cấp bậc"
              job_attributes[:level] = ele.at_css("p").text.squish
            when "Kinh nghiệm"
              job_attributes[:years_of_experience] = ele.at_css("p").text.squish
            end
          end
          html_job_detail.css(".search-result-list-detail .tabs #tab-1 .job-detail-content .detail-row").each do |ele|
            next if ele.at_css(".detail-title").nil?
            type = ele.at_css(".detail-title").text
            case type
            when "Phúc lợi "
              job_attributes[:benefit] = ele.at_css("ul").inner_html.squish
            when "Mô tả Công việc"
              job_attributes[:job_description] = ele.inner_html.squish.gsub("<h3 class=\"detail-title\">Mô tả Công việc</h3>","")
            when "Yêu Cầu Công Việc"
              job_attributes[:job_requirements] = ele.inner_html.squish.gsub("<h3 class=\"detail-title\">Yêu Cầu Công Việc</h3>","")
            when "Thông tin khác"
              job_attributes[:other_information] = ele.inner_html.squish.gsub("<h3 class=\"detail-title\">Thông tin khác</h3>","")
            end
          end
          next if item.at_css(".figure .image a @href").text == "javascript:void(0);"
          # Company attributes
          html_company_detail = Nokogiri::HTML.parse(URI.open(URI.encode(item.css(".figure .image a @href").text)))
          next if html_company_detail.at_css(".jobsby-company").nil?
          company_css = ".jobsby-company .company-introduction .company-info .info "
          company_attributes = {
            title: html_company_detail.at_css(company_css + ".content .name").text,
            address: html_company_detail.css(company_css + ".content p")[1].text,
            logo: html_company_detail.at_css(company_css + ".img @src").text,
            description: html_company_detail.at_css(company_css + ".content ul").inner_html.squish
          }
          # Defind cities array
          cities = item.css(".figure .figcaption .caption .location ul li").map do |city|
            city.text.squish
          end
          # Defind industries array
          industries = html_job_detail.css(".search-result-list-detail .tabs #tab-1 .job-detail-content .detail-box .industry p a").map do |industry|
            industry.text.tr(",","").squish
          end              

          sleep rand
          Mutex.new.synchronize {
            result = CrawlerService.imports(job_attributes, company_attributes, cities, industries)
          }
          sleep rand

          logger.info "Crawl success url : #{url}"
        rescue => e
          logger.error e
          next
        end
      }
    end
  end

  task city: :environment do
    # Fetch and parse HTML document
    html_cities = Nokogiri::HTML.parse(URI.open("https://careerbuilder.vn/tim-viec-lam.html"))
    # Get city in country
    cities_in_country = html_cities.css(".find-jobsby-categories .main-jobs-by-location .jobs-in-country .list-jobs-by-country li a").map do |title|
      {
        title: title.text.gsub("Việc làm tại ","").squish,
        foreign: false
      }
    end
    # Get city foreign
    cities_foreign = html_cities.css(".find-jobsby-categories .main-jobs-by-location .overseas-jobs .list-overseas-jobs li a").map do |title|
      {
        title: title.text.squish,
        foreign: true
      }
    end
    cities = cities_in_country + cities_foreign
    if cities.length > 0
      City.import cities
    end
  end

  task industry: :environment do
    # Fetch and parse HTML document
    html_industries = Nokogiri::HTML.parse(URI.open("https://careerbuilder.vn/tim-viec-lam.html"))
    # Get industry
    industries = html_industries.css(".find-jobsby-categories .list-of-working-positions .list-jobs li a").map do |title|
      {
        title: title.text.squish
      }
    end
    if industries.length > 0
      Industry.import industries
    end
  end
end
