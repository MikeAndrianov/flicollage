Gem::Specification.new do |s|
  # s.require_paths = ['lib']

  s.add_dependency 'flickraw'
  s.add_dependency 'httparty'
  s.add_dependency 'rmagick'

  s.name        = 'flicollage'
  s.version     = '0.0.0'
  s.date        = '2017-05-23'
  s.summary     = "Flicollage!"
  s.description = "Helps to make a beautiful collage with photos from Flickr"
  s.authors     = ["Mike Andrianov"]
  s.email       = 'mikeandrianov@gmail.com'
  s.files       = ["lib/flicollage.rb", "lib/flicollage/api.rb", "lib/flicollage/fetcher.rb", "lib/flicollage/photo.rb", "lib/flicollage/collage_maker.rb"]
  s.license       = 'MIT'
end
