module Kikuchi
  class Layout
    attr_accessor :source_path, :name
    attr_accessor :content, :output

    def initialize(source_path, name)
      self.source_path = source_path
      self.name = name

      process
    end

    def process
      self.content = File.read(File.join(source_path, name))
    end
  end
end