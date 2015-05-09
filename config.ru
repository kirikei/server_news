# This file is used by Rack-based servers to start the application.

require ::File.expand_path('../config/environment',  __FILE__)
run Rails.application


require 'grape/rabl'

use Rack::Config do |env|
  env['api.tilt.root'] = '/Users/admin/rails_lesson/server_news/app/views'
end
