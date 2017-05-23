module Flicollage
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

    def photos_info(keyword)
      get_popular(keyword).map { |image_basic_info| Photo.new(image_basic_info) }
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
end
