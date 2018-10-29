module GeoService
  API_CITY_EP = "http://geoapi.heartrails.com/api/json"
  class InvalidArgument < StandardError; end

  class << self
    def coord_from_dist(p, c)
      # 域内の町丁の緯度経度を平均して、区域の緯度経度とする。
      res = Faraday.get API_CITY_EP, {'method' => 'getTowns', 'prefecture' => p, 'city' => c}
      towns = JSON.parse(res.body)['response']
      raise InvalidArgument.new("No such prefecture or city.") if towns['error']

      lon = (towns['location'].map{|loc| loc['x'].to_f}.sum) / towns['location'].length
      lat = (towns['location'].map{|loc| loc['y'].to_f}.sum) / towns['location'].length
      return [lat, lon]
    end

    def dist_from_coord(lat, lon)
      res = Faraday.get API_CITY_EP, {'method' => 'searchByGeoLocation', 'x' => lon, 'y' => lat}
      towns = JSON.parse(res.body)['response']
      raise InvalidArgument.new("No district for given coordinate.") if towns['error']

      city = towns['location'].group_by{|loc| loc['city']}.sort{|a,b|a[1].length<=>b[1].length}.reverse[0][0]
      pref = towns['location'].group_by{|loc| loc['prefecture']}.sort{|a,b|a[1].length<=>b[1].length}.reverse[0][0]
      return [pref, city]
    end

    def get_pref_list
      pref = 0
      File.open("/home/vagrant/weatherapp/public/pref.json") do |j|
        pref = JSON.load(j)
      end
      return pref['marker'].map{|pr| pr['pref']}
    end
  end

end
