$:.unshift File.expand_path '../lib', __FILE__
require 'lens_of_truth/version'

Gem::Specification.new do |s|
  s.name        = 'lens_of_truth'
  s.version     = LensOfTruth::VERSION
  s.author      = 'D.E. Akers'
  s.email       = '0x0dea@gmail.com'

  s.summary     = 'Use the Lens of Truth to find objects hidden nearby.'
  s.description = 'lens_of_truth adds Object#find_nearby to look around in proximal memory for things of interest.'

  s.homepage    = 'https://github.com/0x0dea/lens_of_truth'
  s.license     = 'WTFPL'

  s.files       = `git ls-files`.split
end
