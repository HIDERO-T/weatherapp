require 'faraday'
require 'json'
require 'date'
require './app/services/prefecture_service'

class WelcomeController < ApplicationController
  PrefectureService::API_CITY_EP = "http://geoapi.heartrails.com/api/json"
  DEFAULT_PREF = "埼玉県"
  DEFAULT_CITY = "志木市"

  include PrefectureService

  def index
    @pref_list = get_pref_list

    @pref = (@pref || params[:p]) || DEFAULT_PREF 
    @city = (@city || params[:c]) || DEFAULT_CITY
    @coord = get_coord(@pref, @city)

    bundle = PointWeather.new(*@coord)
    @daily = bundle.daily
    @hourly = bundle.hourly
    @yesterday = bundle.yesterday
    
    render "welcome/index"
  end

  def redirect
    lat = params[:lat].to_f
    lon = params[:lon].to_f
    res = Faraday.get API_CITY_EP, {'method' => 'searchByGeoLocation', 'x' => lon, 'y' => lat}
    towns = JSON.parse(res.body)['response']
    city = towns['location'].group_by{|loc| loc['city']}.sort{|a,b|a[1].length<=>b[1].length}.reverse[0][0]
    pref = towns['location'].group_by{|loc| loc['prefecture']}.sort{|a,b|a[1].length<=>b[1].length}.reverse[0][0]

    @pref = pref
    @city = city
    index
  end
end

