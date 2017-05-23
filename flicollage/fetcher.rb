module Flicollage
  class Fetcher
    PHOTO_PATH = 'tmp/photos'

    def initialize(photos_info)
      @photos = photos_info
    end

    def call
      @photos.each { |photo| fetch_photo(photo) }
    end

    # def photos_info(keyword)
    #   @api.get_popular(keyword).map { |image_basic_info| Photo.new(image_basic_info) }
    # end

    private

    def full_path(photo)
      "#{PHOTO_PATH}/#{photo.file_name}"
    end

    def fetch_photo(photo)
      full_path(photo).tap do |path|
        File.open(path, 'wb') { |file| file.write(HTTParty.get(photo.url).body) }
      end
    end
  end
end
