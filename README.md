# flicollage
Make a great looking collage with flickr images


How to use:
  - `git clone https://github.com/MikeAndrianov/flicollage.git`
  - `cd <flicollage>`
  - Make sure that you have installed `flickraw, httparty, rmagick, fileutils`. Otherwise use `gem install <gem_name>`
  - run `ruby flicollage.rb`
  - You can edit this line in the `flicollage.rb` for changing output filename or keywords: `Flicollage::Base.call('collage_name.png', 'hamburg', 'vilnius', ...)`
