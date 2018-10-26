class Daily
  attr_reader :icon, :prec, :max, :min

  def initialize(json)
    @icon = "/icon/#{json['icon']}.png"
    @prec = "#{(json['precipProbability']*100).to_f.round(1)}%"
    @max = "#{json['temperatureHigh'].round(1)}℃"
    @min = "#{json['temperatureLow'].round(1)}℃"
  end
end
