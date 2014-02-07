require 'bundler'
Bundler.require

run Opal::Server.new { |s|
  s.append_path 'bower_components/todomvc-common'
  s.append_path 'app'

  s.main       = 'app/application'
  s.index_path = 'index.html.haml'

  s.debug = false
}
