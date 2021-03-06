class Geo < ActiveRecord::Base
    validates_presence_of :name, :lon, :lat, :message => "Can't be empty, field is mandatory. "
    validates_length_of :name,
		:maximum => 50,
		:too_long => "{{count}} characters is the maximum allowed"

    #Rails used to have a country_select helper for choosing countries,
    #but this has been extracted to the country_select plugin.

    has_many :sampling_sites
    has_one :country

    attr_reader :verbose_me
    def verbose_me
        #return self.name + ' [' + self.lon.to_s + '/' + self.lat.to_s + ']'
        return self.name + ' (' + country_name + ')'
    end

    def country_name
        Country.find(country_id).name
    end

    def lat_name
        lat
        #deg_to_dms(lat)
    end

    def lng_name
        lon
        #deg_to_dms(lon)
    end

    private 
      
        #Degrees to Degree Minutes.m second
        def deg_to_dms(deg)
            d = 1 #int(deg)
            md = abs(deg - d) * 60
            m = 2 #int(md)
            sd = (md - m) * 60
            return [d, m, sd]
        end   
end

