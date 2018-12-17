class ToppagesController < ApplicationController
  before_action :search

  include DiariesHelper

  def index
  end
end
