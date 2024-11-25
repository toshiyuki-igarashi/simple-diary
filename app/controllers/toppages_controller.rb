class ToppagesController < ApplicationController
  before_action :search

  include DiariesHelper

  def index
    session[:form_idx] = 0
  end
end
