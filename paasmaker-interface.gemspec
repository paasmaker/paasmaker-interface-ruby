
Gem::Specification.new do |s|
  s.name        = "paasmaker-interface"
  s.version     = "0.9"
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Daniel Foote"]
  s.email       = ["freefoote@paasmaker.org"]
  s.homepage    = "http://paasmaker.org"
  s.summary     = "An application interface to Paasmaker."
  s.description = "A helper class that makes it easier to interface with the Paasmaker platform-as-a-service."
  s.license     = "MIT"

  s.files        = ['lib/paasmaker.rb', 'README.md', 'LICENSE']
  s.add_dependency('json')
end