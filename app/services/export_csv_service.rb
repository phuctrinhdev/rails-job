require "csv"

class ExportCsvService
  def initialize objects, attributes
    @objects = objects
    @attributes = attributes
    @header = @attributes.map{ |attr| I18n.t("header_csv.#{attr}")}
  end
  def perform
    CSV.generate do |csv|
      csv << header
      objects.each do |object|
        csv << attributes.map{ |attr| object.public_send(attr) }
      end
    end
  end

  private
  attr_reader :objects, :attributes, :header
end