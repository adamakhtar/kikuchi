module Kikuchi
  class Site
    attr_accessor :source_path, :destination_path
    attr_accessor :posts, :layouts
    
    def initialize(source_path, destination_path)
      self.source_path = source_path
      self.destination_path = destination_path
    end

    #process the site and write files to destination.
    def process
      read_posts
      read_layouts
      write_posts
      write_pages
    end

    #read posts from files
    def read_posts
      self.posts = []
      posts_dir = File.join(source_path, "posts")
      entries   = Dir.entries(posts_dir).reject{|f| File.directory?(f)}
      entries.each do |name|
        self.posts << Post.create(posts_dir, name)
      end
      posts.sort! 
    end

    #read layouts from files
    def read_layouts
      self.layouts = []
      layouts_dir = File.join(source_path, "layouts")
      entries   = Dir.entries(layouts_dir).reject{|f| File.directory?(f)}
      entries.each do |name|
        self.layouts << Layout.new(layouts_dir, name)
      end
    end

    #write posts to desitination
    def write_posts
      posts.each do |p|
        # TODO allow user to specify which layouts a post should use 
        p.render(layouts)
        p.write(File.join(destination_path, "posts"))
      end
    end

    # write pages to destination
    def write_pages
      pages = Dir["#{source_path}/*.html"].each do |p_name|
        page = Page.new(source_path, File.basename(p_name))
        # TODO allow user to specify which layouts a page should use 
        page.render(site_payload, layouts.select{|x| x.name == "layout.html"})
        page.write(destination_path)
      end
    end

    # payload for site - passed to render methods so views
    # have access to site data. 
    def site_payload
      {'site' => {'posts' => @posts}}
    end
  end
end
