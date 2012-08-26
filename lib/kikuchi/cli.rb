require 'rubygems'
require 'thor'
require 'stringex'
require 'directory_watcher'

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
      copy_file "Gemfile", File.join(project_name, *%w[Gemfile])
      FileUtils.cd(project_name)
      say "Creating bundle for heroku"
      system("bundle install")
      say "Creating compass files"
      system 'compass create --sass-dir "source/sass" --css-dir "public/stylesheets" --javascripts-dir "public/stylesheets" --images-dir "public/images'
      say "Initialize repository and commit"
      system("git init")
      system("git add .")
      system('git commit -am "first commit"')
    end

    desc "generate", "generates site in the public folder"
    def generate
      say "Cant find source directory in current path. Are you in the root of your project?" unless File.directory? "source"
      site = Site.new("source", "public")
      site.process
      system "compass compile --sass-dir source/sass/ --css-dir  public/stylesheets"
    end

    desc "new_post POST_TITLE", "creates a new post"
    def new_post(post_title)
      filename = "#{Time.now.strftime("%Y-%m-%d")}-#{post_title.to_url}.markdown"
      say "Cant find source directory in current path. Are you in the root of your project?" unless File.directory? "source"
      FileUtils.mkdir("source/posts") unless File.directory? "source/posts"
      f = File.open(File.join("source/posts", filename), "w")
      f.close
    end

    desc "watch", "watches for changes to files in source and auto generates"
    def watch
      unless File.directory? "source"
        say "Cant find source directory in current path. Are you in the root of your project?" 
        return 
      end
      system "compass watch --sass-dir source/sass/ --css-dir  public/stylesheets"
      puts Dir.pwd
      dw = DirectoryWatcher.new File.join(".", "source")
      dw.glob = '**/*'
      dw.add_observer do |args|
         t = Time.now.strftime("%Y-%m-%d %H:%M:%S")
         say "#{t} : #{args.size} file(s) changed - auto generating"
         site = Site.new("source", "public")
         site.process
      end
      dw.start
      loop { sleep 1000 }
    end

    desc "preview", "start a server at given port to view site in browser"
    method_option :port, :aliases=> '-p', :default => '3000'
    def preview()
      unless File.directory? "source"
        say "Cant find source directory in current path. Are you in the root of your project?" 
        return 
      end
      puts "Starting Rack on port #{options[:port]}"
      rackupPid =  Process.spawn("rackup --port #{options[:port]}")
      kikuchi_exec = File.expand_path("../../../bin/kikuchi", __FILE__)
      kikuchiPid = Process.spawn("#{kikuchi_exec} watch") 
      compassPid = Process.spawn("compass watch --sass-dir source/sass/ --css-dir  public/stylesheets")
      trap("INT") {
        [rackupPid, kikuchiPid, compassPid].each { |pid| Process.kill(9, pid) rescue Errno::ESRCH }
        exit 0
      }
      [rackupPid, kikuchiPid, compassPid].each { |pid| Process.wait(pid) }
    end
  end
end