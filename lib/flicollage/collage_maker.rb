module Flicollage
  class CollageMaker
    include Magick

    DEFAULT_OPTIONS = {
      gap_space:        200,
      background_color: 'white', # background of the collage
      image_width:      400,
      image_height:     400,
      columns:          6,
      shadow:           'gray40',
      border_color:     'whitesmoke'
    }

    def initialize(collage_name)
      @collage_name = collage_name
      @pathes = Dir["#{$LOAD_PATH}/#{Flicollage::Fetcher::PHOTO_PATH}/*"]
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

      @collage.write("jpeg:" + __dir__ + @collage_name)
    end

    def cleanup
      ::FileUtils.rm_rf("#{Fetcher::PHOTO_PATH}/.", secure: true)
    end
  end
end
