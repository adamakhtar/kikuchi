
module Kikuchi
  class Post
    attr_accessor :name, :date, :slug, :extension
    attr_accessor :content, :output
    attr_accessor :source_path

    MATCHER = /(\d+-\d+-\d+)-(.*)(\.[^.]*)/
    def self.valid?(name)
      name =~ MATCHER
    end

    # createa post if it has a valid name
    # [source_path] the string path of the directory containing the source file
    # [name] the filename of the post.
    def self.create(source_path, name)
      return unless valid? name
      Post.new(source_path, name)
    end

    #The directory into which this post will be placed in
    def dir
      date.strftime("%Y/%m/%d")
    end

    #TODO link to post
    def url
      "posts/#{date.strftime("%Y/%m/%d")}/#{slug}"
    end

    #returns humany friendly title
    #e.g. 10 Mistakes That You Musn't Make
    def title
      @title ||= slug.split("-").map{|x| x.capitalize}.join(" ")
    end


    def initialize(source_path, name)
      self.source_path = source_path
      self.name = name
      process(name)
      read_content
    end

    # reads the contents of the post's file
    def read_content
      self.content = File.read( File.join(source_path, name))
    end

    # extract date, url slug and file extension from fileame
    # [name] is the post's string filename
    def process(name)
      m, date, slug, extension = *MATCHER.match(name)
      self.date = Time.strptime(date, "%Y-%m-%d")
      self.slug = slug
      self.extension = extension
    end

    # Post.sort is based on date
    def <=>(other)
      self.date <=> other.date
    end

    #transform markdown into html
    def transform(input)
       RDiscount.new(input).to_html.strip if extension == ".markdown"
    end

    #renders the post with its layout
    #[layout] is the path string to layout file
    def render(layout=nil)
      self.content = Liquid::Template.parse(content).render()
      self.content = transform(content)
      self.output   = self.content
      
      #render layout
      return unless layout
      layout_content = File.read(layout)
      self.output = Liquid::Template.parse(layout_content).render('content' => self.output)
    end

    #renders and saves post in the destination directory
    def write(destination)
      destination_dir = File.join(destination, dir)
      FileUtils.mkdir_p destination_dir

      File.open(File.join(destination_dir, "#{slug}.html"), "w") do |f|
        f.write output
      end
    end

    # convert post to hash form for use in Liquid templates
    def to_liquid
      {'title' => title, 'url' => url, 'date' => date, 'content' => content}
    end
  end
end