module PrefectureService
  
  private

  def get_coord(p, c)
    # 域内の町丁の緯度経度を平均して、区域の緯度経度とする。
    res = Faraday.get API_CITY_EP, {'method' => 'getTowns', 'city' => c}
    towns = JSON.parse(res.body)['response']
    lon = (towns['location'].map{|loc| loc['x'].to_f}.sum) / towns['location'].length
    lat = (towns['location'].map{|loc| loc['y'].to_f}.sum) / towns['location'].length
    return [lat, lon]
  end

  def get_pref_list
    pref = 0
    File.open("/home/vagrant/weatherapp/public/pref.json") do |j|
      pref = JSON.load(j)
    end
    return pref['marker'].map{|pr| pr['pref']}
  end
end
