require 'flickraw'
require 'httparty'
require 'rmagick'
require 'fileutils'

require_relative 'flicollage/api'
require_relative 'flicollage/collage_maker'
require_relative 'flicollage/fetcher'
require_relative 'flicollage/photo'

class Flicollage::Base
  def initialize(collage_name, *keywords)
    @collage_name = collage_name
    @api = Flicollage::Api.new
    @photos_info = []
    @keywords = []
    extend_keywords(keywords)
  end

  def call
    Flicollage::Fetcher.new(@photos_info).call
    Flicollage::CollageMaker.new(@collage_name).call
  end

  private

  def extend_keywords(keywords)
    keywords.each { |word| get_photo_info(word) }

    words_from_dict = File.read('/usr/share/dict/words').split("\n").select { |word| word.size > 3 && word.size < 10 }
    while @keywords.count < 10 do
      get_photo_info(words_from_dict.sample)
    end

    puts "Keywords: #{keywords}"
  end

  def get_photo_info(word)
    begin
      puts "Fetching info for #{word}"

      @photos_info += @api.photos_info(word)
      @keywords << word
    rescue FlickRaw::FailedResponse
      puts "Nothing found for #{word}"
    end
  end
end

Flicollage::Base.new('collage.jpeg',
  'london', 'vilnius', 'madrid', 'tokio', 'bird', 'porsche', 'mercedes amg', 'hamburg').call
