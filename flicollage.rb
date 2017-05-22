require 'flickraw'
require 'httparty'
require 'rmagick'
require 'pry'

module Flicollage
  class Base
    def self.call(collage_name, *keywords)
      Flicollage::Fetcher.new(keywords).call
      Flicollage::CollageMaker.new(collage_name).call
    end
  end

  class Api
    API_KEY = '49383e47623e76c6d00fbac95c80664a'
    SECRET_KEY = '6f856e19c82e9eac'

    def initialize
      FlickRaw.api_key = API_KEY
      FlickRaw.shared_secret= SECRET_KEY
    end

    def get_recent
      flickr.photos.getRecent.first(10)
    end

    def get_popular(keyword)
      flickr.photos.search(search_params(text: keyword))
    end

    private

    # https://hanklords.github.io/flickraw/FlickRaw/Flickr/Photos.html#method-i-search
    def search_params(opts = {})
      {
        sort: 'interestingness-desc',
        per_page: 8,
        pages: 1,
      }.merge(opts)
    end
  end

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

  class Fetcher
    PHOTO_PATH = 'tmp/photos'

    def initialize(keywords = [])
      @api = Api.new
      @photos = []

      keywords.each { |keyword| @photos += photos_info(keyword) }
    end

    def call
      @photos.each { |photo| fetch_photo(photo) }
    end

    def photos_info(keyword)
      @api.get_popular(keyword).map { |image_basic_info| Photo.new(image_basic_info) }
    end

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

module Flicollage
  class CollageMaker
    include Magick

    DEFAULT_OPTIONS = {
      gap_space:        200,
      background_color: 'white', # background of the collage
      image_width:      400,
      image_height:     400,
      columns:          3,
      shadow:           'gray40',
      border_color:     'whitesmoke'
    }

    def initialize(collage_name)
      @collage_name = collage_name
      @pathes = Dir["#{Flicollage::Fetcher::PHOTO_PATH}/*"]
      @photo_count = @pathes.count
    end

    def call
      @collage = Image.new(collage_width, collage_height) do
        self.background_color = DEFAULT_OPTIONS[:background_color]
      end

      put_images_on_collage
      cleanup
    end

    private

    def collage_width
      (DEFAULT_OPTIONS[:columns] * DEFAULT_OPTIONS[:image_width]) + DEFAULT_OPTIONS[:gap_space]
    end

    def collage_height
      rows = (@photo_count / DEFAULT_OPTIONS[:columns].to_f).ceil # with round up
      (rows * DEFAULT_OPTIONS[:image_height]) + DEFAULT_OPTIONS[:gap_space]
    end

    def polaroid_images
      @polaroid_images ||= @pathes.map do |path|
        make_polaroid_image(path).rotate(rand(20) - rand(20))
      end
    end

    def make_polaroid_image(path)
      Image.read(path)[0]
        .resize_to_fill(DEFAULT_OPTIONS[:image_width], DEFAULT_OPTIONS[:image_height]) # Image#read returns array (some objects for GIFs, one object for JPG, PNG)
        .polaroid do
          self.shadow_color = DEFAULT_OPTIONS[:shadow]
          self.border_color = DEFAULT_OPTIONS[:border_color]
        end
    end

    def put_images_on_collage
      position = { x: 50, y: 50 }
      counter = 0

      polaroid_images.each do |image|
        if counter >= DEFAULT_OPTIONS[:columns]
          counter = 0
          position[:y] += DEFAULT_OPTIONS[:image_height]
          position[:x] = 50
        end

        @collage.composite!(image, position[:x], position[:y], OverCompositeOp)

        position[:x] += DEFAULT_OPTIONS[:image_width]
        counter += 1
      end

      @collage.write(@collage_name)
    end

    def cleanup
      FileUtils.rm_rf("#{Fetcher::PHOTO_PATH}/.", secure: true)
    end
  end
end

Flicollage::Base.call('collage.png', 'hamburg', 'vilnius')
