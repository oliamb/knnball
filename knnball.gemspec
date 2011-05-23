Gem::Specification.new do |s|
  s.specification_version = 1 if s.respond_to? :specification_version=
  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.rubygems_version = '1.3.5'

  s.name = 'knnball'
  s.version = '0.0.5'
  s.date = '2011-05-23'
  s.rubyforge_project = 'knnball'

  s.summary = "K-Nearest Neighbor using Balltree Algorithm"
  s.description = "Implements K-Nearest Neighbor algorithm using Balltree in Ruby."

  s.authors = ["Olivier Amblet"]
  s.email = 'olivier@amblet.net'
  s.homepage = 'http://github.com/oliamb/knnball'

  s.require_paths = %w[lib]

  s.rdoc_options = ["--charset=UTF-8"]
  s.extra_rdoc_files = %w[README.md LICENSE]

  # = MANIFEST =
  s.files = %w[
LICENSE
README.md
Rakefile
knnball.gemspec
lib/knnball.rb
]
  # = MANIFEST =

  s.test_files = s.files.select { |path| path =~ /^test\/test_.*\.rb/ }
end