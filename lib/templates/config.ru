require 'sinatra/base'

class StaticFileServer < Sinatra::Base
  get /.+/ do
    serve_static_page(request.path_info)
  end

  def serve_static_page(filename)
    filepath = File.join(File.dirname(__FILE__), "public")
    filepath = /^\/$/.match(filename)  ? File.join(filepath, "index.html") : File.join(filepath, "#{filename}.html")
    send_file(filepath, :type => 'html') 
  end
end

run StaticFileServer