require 'faraday'
require 'json'
require 'date'

class WelcomeController < ApplicationController
  DEFAULT_PREF = "埼玉県"
  DEFAULT_CITY = "志木市"

  def index
    @pref_list = GeoService.get_pref_list

    @pref = (@pref || params[:p]) || DEFAULT_PREF 
    @city = (@city || params[:c]) || DEFAULT_CITY
    @coord = GeoService.coord_from_dist(@pref, @city)

    PointWeather.api_key = Weatherapp::Application.config.darksky_key
    bundle = PointWeather.new(*@coord)
    @daily = bundle.daily
    @hourly = bundle.hourly
    @yesterday = bundle.yesterday
    
    render "welcome/index"
  end

  def redirect
    (@pref, @city) = GeoService.dist_from_coord(params[:lat].to_f, params[:lon].to_f)
    redirect_to "/#{@pref}/#{@city}"
  end
end

