Gem::Specification.new do |s|
    s.name        = "catfriend"
    s.version     = "0.1"
    s.platform    = Gem::Platform::RUBY
    s.authors     = ["James Pike"]
    s.email       = %w(catfriend@chilon.net)
    s.homepage    = "https://github.com/nuisanceofcats/catfriend"
    s.summary     = "E-mail checker with desktop notifications."
    s.description = "E-mail checker with libnotify desktop notifications."

    s.required_rubygems_version = ">= 1.3"

    s.has_rdoc     = true
    s.files        = %w(LICENSE) + Dir.glob('lib/catfriend/*.rb')
    s.license      = 'Expat'
    s.executables  = %w(catfriend)
    s.add_dependency('ruby-libnotify', '>=0.5')
    s.add_dependency('xdg', '>=2')
end
