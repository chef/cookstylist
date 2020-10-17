Gem::Specification.new do |s|
  s.name        = "cookstylist"
  s.version     = "0.1.0"
  s.summary     = "A Github App to autocorrect repositories with Cookstyle"
  s.description = s.summary
  s.authors     = ["Tim Smith"]
  s.email       = "tsmith@chef.io"
  s.homepage    = "http://www.github.com/chef/cookstylist"
  s.license     = "Apache-2.0"

  s.required_ruby_version = ">= 2.7"

  s.add_dependency "octokit", "~> 4.18"
  s.add_dependency "jwt", "~> 2.2"
  s.add_dependency "faraday-http-cache", "~> 2.2"
  s.add_dependency "git", "~> 1.7"
  s.add_dependency "mixlib-log", "~> 3.0"
  s.add_dependency "mixlib-shellout", "~> 3.1"
  s.add_dependency "mixlib-cli", "~> 2.1"
  s.add_dependency "mixlib-config", "~> 3.0"
  s.add_dependency "cookstyle", ">= 6.16"

  s.files         = %w{Gemfile LICENSE cookstylist.gemspec} +
    Dir.glob("{bin,lib}/**/*", File::FNM_DOTMATCH).reject { |f| File.directory?(f) }
  s.executables   = "bin/cookstylist"
  s.require_paths = ["lib"]
end
