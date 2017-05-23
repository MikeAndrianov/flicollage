require 'flickraw'
require 'httparty'
require 'rmagick'
require 'fileutils'
# require 'pry'

require_relative 'flicollage/api'
require_relative 'flicollage/fetcher'
require_relative 'flicollage/photo'
require_relative 'flicollage/collage_maker'

class Flicollage::Base
  def self.call(collage_name, *keywords)
    Flicollage::Fetcher.new(keywords).call
    Flicollage::CollageMaker.new(collage_name).call
  end
end

# How to run:
# Flicollage::Base.call('~/Desktop/collage.png', 'london', 'vilnius')
