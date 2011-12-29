Gem::Specification.new do |s|
    s.name        = "catfriend"
    s.version     = "0.0"
    s.platform    = Gem::Platform::RUBY
    s.authors     = ["James Pike"]
    s.email       = ["catfriend@chilon.net"]
    s.homepage    = "http://chilon.net/catfriend"
    s.summary     = "E-mail checker with desktop notifications."
    s.description = "E-mail checker with libnotify desktop notifications."

    s.required_rubygems_version = ">= 1.3"

    s.files        = %w(LICENSE)
    s.executables  = ['catfriend']
    s.add_dependency('ruby-libnotify', '>=0.5')
    s.add_dependency('ruby-xdg', '>=2')
end
