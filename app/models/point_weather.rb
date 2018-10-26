# 
# 指定した座標の天気を構成するViewModel。
# 初期化時にデータフェッチするため、new時に例外処理必要。
# 
class PointWeather
  API_EP = "https://api.darksky.net/forecast/488f576ad99a5b57174456137ebd93c8/"
  attr_reader :daily, :hourly, :yesterday

  def initialize(lat, lon)
    current = fetch_current(lat, lon)
    yesterday = fetch_yesterday(lat, lon)

    json_daily = current['daily']['data']
    json_hourly = current['hourly']['data']

    @daily = (0..6).map{|i| Daily.new(json_daily[i])}
    @hourly = (0..7).map{|i| Hourly.new(json_hourly[i*6])}
    @yesterday = Daily.new(yesterday)
  end

  private
  def fetch_current(lat, lon)
    return JSON.parse(Faraday.get("#{API_EP}#{lat},#{lon}", {'units' => 'si'}).body)
  end

  def fetch_yesterday(lat, lon)
    time_serial = Time.mktime(Time.now.year, Time.now.month, Time.now.day - 1).to_i
    whole = Faraday.get "#{API_EP}#{lat},#{lon},#{time_serial.to_s}", {'units' => 'si', 'exclue' => 'hourly'}
    res = JSON.parse(whole.body)['daily']['data']
    res.each do |rec|
      return rec if rec['time'].to_i == time_serial
    end
  end

  #
  # 特定時間のの日時と降水確率を格納するデータクラス。
  #
  class Hourly
    attr_reader :time, :prec

    def initialize(json)
      @time = Time.at(json['time'].to_i).strftime("%d日 %H:00")
      @prec = json['precipProbability'].round(1)
    end
  end

  # 
  # 特定日の天気アイコン・降水確率・最高気温・最低気温を格納するデータクラス。
  #
  class Daily
    attr_reader :icon, :prec, :max, :min

    def initialize(json)
      @icon = "/icon/#{json['icon']}.png"
      @prec = "#{(json['precipProbability']*100).to_f.round(1)}%"
      @max = "#{json['temperatureHigh'].round(1)}℃"
      @min = "#{json['temperatureLow'].round(1)}℃"
    end
  end
end
