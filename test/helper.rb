require File.join(File.dirname(__FILE__), *%w[.. lib kikuchi])

require 'test/unit'

include Kikuchi
    

def dest
  File.join(File.dirname(__FILE__), "dest")
end

def clear_dest
  FileUtils.rm_rf dest
end
