require 'rubygems'
require 'thor'
require 'stringex'

module Kikuchi
  class Cli < Thor
    include Thor::Actions

    def self.source_root; File.expand_path('../../templates', __FILE__); end

    desc "new PROJECT_NAME", "creates a new project"
    def new(project_name)
      empty_directory project_name
      empty_directory File.join(project_name, "source")
      empty_directory File.join(project_name, "source", "posts")
      empty_directory File.join(project_name, "source", "layouts")
      empty_directory File.join(project_name, "public")
      copy_file "index.html", File.join(project_name, *%w[source index.html])
      copy_file "layout.html", File.join(project_name, *%w[source layouts layout.html])
      copy_file "config.ru", File.join(project_name, *%w[config.ru])
    end

    desc "generate", "generates site in the public folder"
    def generate
      say "Cant find source directory in current path. Are you in the root of your project?" unless File.directory? "source"
      site = Site.new("source", "public")
      site.process
    end

    desc "new_post POST_TITLE", "creates a new post"
    def new_post(post_title)
      filename = "#{Time.now.strftime("%Y-%m-%d")}-#{post_title.to_url}.markdown"
      say "Cant find source directory in current path. Are you in the root of your project?" unless File.directory? "source"
      FileUtils.mkdir("source/posts") unless File.directory? "source/posts"
      f = File.open(File.join("source/posts", filename), "w")
      f.close
    end


    desc "preview", "start a server at given port to view site in browser"
    method_option :port, :aliases=> '-p', :default => '3000'
    def preview()
      say "Cant find source directory in current path. Are you in the root of your project?" unless File.directory? "source"
      puts "Starting Rack on port #{options[:port]}"
      rackupPid = Process.spawn("rackup --port #{options[:port]}")

      trap("INT") {
        [rackupPid].each { |pid| Process.kill(9, pid) rescue Errno::ESRCH }
        exit 0
      }
      [rackupPid].each { |pid| Process.wait(pid) }
    end
  end
end