module Flicollage
  class Photo
    attr_reader :info

    def initialize(base_info)
      @id = base_info['id']
      @info = flickr.photos.getInfo(photo_id: @id)
    end

    def url
      @url ||= FlickRaw.url_z(@info)
    end

    def format
      @info['originalformat']
    end

    def file_name
      "#{@id}.#{format}"
    end
  end
end
