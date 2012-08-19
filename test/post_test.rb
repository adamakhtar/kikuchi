require File.join(File.dirname(__FILE__), "helper")


class TestPost < Test::Unit::TestCase
  def test_valid
    assert Post.valid?("2005-12-31-this-is-post.markdown")
    assert !Post.valid?("2005-12-31.markdown")
  end

  def test_process
    post = Post.allocate
    post.process("2005-12-31-this-is-a-post.markdown")
    assert_equal Time.strptime("2005-12-31","%Y-%m-%d"), post.date
    assert_equal "this-is-a-post", post.slug
    assert_equal ".markdown", post.extension
  end

  def test_render
    p = Post.create(File.join(File.dirname(__FILE__), *%w[fixtures posts]), "2005-12-31-this-is-a-post.markdown") 
    p.render 
    assert_equal "<h1>This is my first post</h1>", p.output.rstrip 
  end

  def test_render_with_layout
    p = Post.create(File.join(File.dirname(__FILE__), "fixtures", "posts"), "2005-12-31-this-is-a-post.markdown") 
    p.render(File.join(File.dirname(__FILE__), *%w[fixtures layouts layout.html]))
    assert_equal %Q{<div id="layout"><h1>This is my first post</h1>\n</div>}, p.output.rstrip
  end

  def test_dir
    p = Post.allocate
    p.date = Time.strptime("2005-12-31","%Y-%m-%d")
    assert_equal "2005/12/31", p.dir
  end

  def test_write
    clear_dest
    post = Post.create( File.join(File.dirname(__FILE__), *%w[fixtures posts]), "2005-12-31-this-is-a-post.markdown")
    post.render
    post.write(dest)
    assert File.exists?(File.join(dest, post.dir, 'this-is-a-post.html'))
  end

  def test_title
    p = Post.allocate
    p.slug = "this-is-a-post"
    assert_equal "This Is A Post", p.title
  end
end