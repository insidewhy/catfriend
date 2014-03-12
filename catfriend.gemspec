Gem::Specification.new do |s|
    s.name        = "catfriend"
    s.version     = "0.19"
    s.platform    = Gem::Platform::RUBY
    s.authors     = ["James Pike"]
    s.email       = %w(catfriend@chilon.net)
    s.homepage    = "https://github.com/nuisanceofcats/catfriend"
    s.summary     = "E-mail checker with desktop notifications."
    s.description = "E-mail checker with libnotify desktop notifications."

    s.required_rubygems_version = ">= 1.3"

    s.has_rdoc     = true
    s.files        = %w(LICENSE catfriend.example) + Dir.glob('lib/catfriend/*.rb')
    s.license      = 'Expat'
    s.executables  = %w(catfriend)
    s.add_runtime_dependency('libnotify', '>=0.7.1', '~> 0.8')
    s.add_runtime_dependency('ruby-dbus', '>=0.7', '~> 0.11')
    s.add_runtime_dependency('events', '~> 0.9')
    # s.add_runtime_dependency('xdg', '>=2') # optional
end
