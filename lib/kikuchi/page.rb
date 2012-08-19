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
      self.output = Liquid::Template.parse(content).render(payload)
      return unless layout
      layout = File.read(layout)
      self.output = Liquid::Template.parse(layout).render('content' => output)
    end

    #write page to destination directory
    def write(destination)
      FileUtils.mkdir_p destination unless File.directory? destination
      File.open(File.join(destination, name), "w"){|x| x.write output}
    end
  end
end
