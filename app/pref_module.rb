module PrefectureService

  # 都道府県・市町村から、およその緯度経度を返す。
  #
  # in: String p: 都道府県名。～県まで入力必須。
  # in: String c: 市町村名。～市まで入力必須。郡部の場合は郡名から。
  # out: [float, float]: 緯度・経度。
  def get_coord(p, c)
    # 域内の町丁の緯度経度を平均して、区域の緯度経度とする。
    res = Faraday.get API_CITY_EP, {'method' => 'getTowns', 'city' => c}
    towns = JSON.parse(res.body)['response']
    lon = (towns['location'].map{|loc| loc['x'].to_f}.sum) / towns['location'].length
    lat = (towns['location'].map{|loc| loc['y'].to_f}.sum) / towns['location'].length
    return [lat, lon]
  end

  # 都道府県名一覧データ（ローカル）から読み出す処理。
  # out: Array(String): 都道府県名
  def get_pref_list
    pref = 0
    File.open("/home/vagrant/weatherapp/public/pref.json") do |j|
      pref = JSON.load(j)
    end
    return pref['marker'].map{|pr| pr['pref']}
  end
end
