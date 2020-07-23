class IndustriesController < ApplicationController
  def index
    @industries = Industry.all
  end
end
