module Kikuchi
  class Page
    attr_accessor :source_path, :name
    attr_accessor :output, :content

    def initialize(source_path, name)
      self.name        = name
      self.source_path = source_path

      read_content
    end

    # reads content of file
    def read_content
      self.content = File.read(File.join(source_path, name))
    end

    # renders the file to output
    # [layout] is wrapped around the page's content.
    def render(payload, layout=nil)
      # require "pry"; binding.pry
      self.content = Liquid::Template.parse(content).render(payload)
      self.content = transform(content)
      self.output  = self.content
      return unless layout
      layout = File.read(layout)
      self.output = Liquid::Template.parse(layout).render('content' => output)
    end

    #transform markdown into html
    def transform(input)
       RDiscount.new(input).to_html.strip
    end

    #write page to destination directory
    def write(destination)
      FileUtils.mkdir_p destination unless File.directory? destination
      File.open(File.join(destination, name), "w"){|x| x.write output}
    end
  end
end
