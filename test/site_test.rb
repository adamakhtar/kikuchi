require File.join(File.dirname(__FILE__), "helper")


class TestSite < Test::Unit::TestCase
  def test_read_posts
    site = Site.new(File.join(File.dirname(__FILE__), *%w[fixtures]), dest)
    site.read_posts
    assert_equal "2005-12-31-this-is-a-post.markdown", site.posts.first.name
  end

  def test_write_posts
    clear_dest
    site = Site.new(File.join(File.dirname(__FILE__), *%w[fixtures]), dest)
    site.process

    post = site.posts.first
    assert File.exists?(File.join(dest, "posts", post.dir, "#{post.slug}.html"))
  end

  def test_write_pages
    clear_dest
    site = Site.new(File.join(File.dirname(__FILE__), *%w[fixtures]), dest)
    site.write_pages
    assert File.exists?(File.join(dest, "index.html"))
  end
end