Gem::Specification.new do |s|
  s.specification_version = 1 if s.respond_to? :specification_version=
  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.rubygems_version = '1.3.5'

  s.name = 'knnball'
  s.version = '0.1.0'
  s.date = '2012-05-28'
  s.rubyforge_project = 'knnball'

  s.summary = "Multi-dimensional nearest neighbor search"
  s.description = "Implements K-Nearest Neighbor algorithm using a KDTree in Ruby. Usefull for sorting geolocation or any other multi-dimensional data."

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
lib/knnball/ball.rb
lib/knnball/stat.rb
lib/knnball/kdtree.rb
lib/knnball/result_set.rb
test/spec/ball_spec.rb
test/spec/data.json
test/spec/kdtree_spec.rb
test/spec/knnball_spec.rb
test/spec/result_set_spec.rb
test/spec/spec_helpers.rb
test/units/stat_test.rb
]
  # = MANIFEST =

  s.test_files = s.files.select { |path| path =~ /^test\/units\/\.*_test\.rb|test\/spec\/\.*_spec\.rb/ }
end