$:.unshift(File.dirname(__FILE__))

require 'rubygems'
#core
require 'time'
require 'fileutils'

#internal requires
require 'kikuchi/cli'
require 'kikuchi/site'
require 'kikuchi/post'
require 'kikuchi/page'
require 'kikuchi/layout'

#3rd party
require 'liquid'
require 'rdiscount'
require 'sinatra'

module Kickuchi

end
