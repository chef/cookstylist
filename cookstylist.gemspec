Gem::Specification.new do |s|
  s.name        = "cookstylist"
  s.version     = "0.1.0"
  s.summary     = "A Github App to autocorrect repositories with Cookstyle"
  s.description = s.summary
  s.authors     = ["Tim Smith"]
  s.email       = "tsmith@chef.io"
  s.homepage    = "http://www.github.com/tas50/cookstylist"
  s.license     = "Apache-2.0"

  s.required_ruby_version = ">= 2.7"

  s.add_dependency "octokit", "~> 4.18"
  s.add_dependency "jwt", "~> 2.2"
  s.add_dependency "faraday-http-cache", "~> 2.2"
  s.add_dependency "git", "~> 1.7"
  s.add_dependency "mixlib-log", "~> 3.0"
  s.add_dependency "mixlib-shellout", "~> 3.1"
  s.add_dependency "cookstyle"

  s.files         = `git ls-files -z`.split("\x0")
  s.executables   = "bin/cookstylist"
  s.require_paths = ["lib"]
end
