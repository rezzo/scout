ENV['RACK_ENV'] = "development"

require 'rubygems'
require 'bundler/setup'

require 'scout'

run Sinatra::Application