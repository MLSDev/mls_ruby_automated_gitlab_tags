lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "mls_ruby_automated_gitlab_tags/version"

Gem::Specification.new do |spec|
  spec.name          = "mls_ruby_automated_gitlab_tags"
  spec.version       = MlsRubyAutomatedGitlabTags::VERSION
  spec.authors       = ["Dmytro Stepaniuk"]
  spec.email         = ["stepaniuk@mlsdev.com"]

  spec.homepage      = "https://mlsdev.com"
  spec.summary       = "Automated tags creation for GitLab"
  spec.description   = "Automated GitLab tags creation allows to prepare release description"
  spec.license       = "MIT"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
end