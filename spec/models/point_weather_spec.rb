require 'rails_helper'

RSpec.describe PointWeather, type: :model do
  context "when APIKey is invalid," do
    before { PointWeather.api_key = "INVALIDAPIKEY" }

    it "raises APIKeyError when API Key is invalid." do
      expect { PointWeather.new(35, 135) }.to raise_error(PointWeather::APIKeyError)
    end
  end

  context "when API Key is valid," do
    before { PointWeather.api_key = "488f576ad99a5b57174456137ebd93c8" }

    it "reject invalid coordinate with APIResponseError." do
      expect { PointWeather.new(999, 999) }.to raise_error(PointWeather::APIResponseError)
    end

    it "accepts valid coordinate." do
      expect { PointWeather.new(35, 135) }.not_to raise_error
    end

    context "when initialized with no exception," do
      let!(:point_weather) { PointWeather.new(35, 135) }

      it "has Array which consists of 7 Object." do
        expect(point_weather.daily.size).to eq 7
        point_weather.daily.each {|daily| expect(daily).to be_an_instance_of(PointWeather::Daily)}
      end
#       subject { point_weather.daily.size }
#       it { is_expected.to eq 7 }

      it "has #hourly which consists of 8 PointWeather::Hourly Objects." do
        expect(point_weather.hourly.size).to eq 8
        point_weather.hourly.each {|hourly| expect(hourly).to be_an_instance_of(PointWeather::Hourly)}
      end
#       subject { point_weather.hourly.size }
#       it { is_expected.to eq 8 }

      subject { point_weather.yesterday }
      it { is_expected.not_to be_nil }
      it { is_expected.to be_an_instance_of(PointWeather::Daily)}
    end
  end
end
