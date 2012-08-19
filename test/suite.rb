
Dir["#{ File.expand_path(File.dirname(__FILE__)) }/*test.rb"].each do |t|
  require t
end