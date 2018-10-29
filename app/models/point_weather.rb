# 
# 指定した座標の天気を構成するViewModel。
# 初期化時にデータフェッチするため、new時に例外処理必要。
# 
class PointWeather
  API_EP = "https://api.darksky.net/forecast/"
  attr_reader :daily, :hourly, :yesterday
  class APIKeyError < StandardError; end
  class APIResponseError < StandardError; end

  class << self
    attr_writer :api_key
    
    def base_url
      API_EP + @api_key + '/'
    end
  end

  def initialize(lat, lon)
    current_json = download_from_api(lat, lon)
    json_daily = current_json['daily']['data']
    json_hourly = current_json['hourly']['data']

    time_serial = Time.mktime(Time.now.year, Time.now.month, Time.now.day - 1).to_i
    past_json = download_from_api(lat, lon, time_serial)
    json_yesterday = past_json['daily']['data'].select{|rec| rec['time'].to_i == time_serial}.first

    @daily = (0..6).map{|i| Daily.new(json_daily[i])}
    @hourly = (0..7).map{|i| Hourly.new(json_hourly[i*6])}
    @yesterday = Daily.new(json_yesterday)
  end

  private
  def download_from_api(lat, lon, time_serial = nil)
    raw = if time_serial
      Faraday.get("#{self.class.base_url}#{lat},#{lon},#{time_serial.to_s}", {'units' => 'si', 'exclue' => 'hourly'}).body
    else
      Faraday.get("#{self.class.base_url}#{lat},#{lon}", {'units' => 'si'}).body
    end

    raise APIKeyError.new("API Key is invalid.") if /.*Forbidden.*/ === raw
    raise APIKeyError.new("API Key is not set.") if /.*Not\sFound.*/ === raw

    json = JSON.parse(raw)
    raise APIResponseError.new("fetch_yesterday: #{json['error']}.") if json['error']

    return json
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
