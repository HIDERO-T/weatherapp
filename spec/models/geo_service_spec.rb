require 'rails_helper'

RSpec.describe GeoService, type: :model do
  describe ".coord_from_dist" do
    it "raises exception with invalid argument" do
      expect{GeoService.coord_from_dist("どこにも県", "無い市")}.to raise_error(GeoService::InvalidArgument)
    end

    it "raises no exception with valid argument" do
      expect{GeoService.coord_from_dist("埼玉県", "志木市")}.not_to raise_error
    end

    context "given valid prefecture or city" do
      let(:valid_city) { GeoService.coord_from_dist("埼玉県", "志木市") }

      it "has 2 float objects." do
        expect(valid_city.size).to eq 2
        valid_city.each do |i|
          expect(i).to be_an_instance_of Float
        end
      end
    end
  end

  describe ".dist_from_coord" do
    it "raises exception with invalid argument" do
      expect{GeoService.dist_from_coord(999, 999)}.to raise_error(GeoService::InvalidArgument) 
    end

    it "raises no exception with valid argument" do
      expect{GeoService.dist_from_coord(35, 135)}.not_to raise_error
    end

    context "given valid prefecture or city" do
      let(:valid_coord) { GeoService.dist_from_coord(35, 135) }

      it "has 2 float objects." do
        expect(valid_coord.size).to eq 2
        valid_coord.each do |i|
          expect(i).to be_an_instance_of String 
        end
      end
    end
  end
end
