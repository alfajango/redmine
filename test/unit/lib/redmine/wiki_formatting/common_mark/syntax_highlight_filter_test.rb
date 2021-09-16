# frozen_string_literal: true
#
require File.expand_path('../../../../../../test_helper', __FILE__)
if Object.const_defined?(:CommonMarker)
require 'redmine/wiki_formatting/common_mark/syntax_highlight_filter'

class Redmine::WikiFormatting::CommonMark::SyntaxHighlightFilterTest < ActiveSupport::TestCase

  def filter(html)
    Redmine::WikiFormatting::CommonMark::SyntaxHighlightFilter.to_html(html, @options)
  end

  def setup
    @options = { }
  end

  def test_should_highlight_supported_language
    input = <<-HTML
<pre><code class="language-ruby">
def foo
end
</code></pre>
    HTML
    expected = <<-HTML
<pre><code class="ruby syntaxhl" data-language="ruby">
<span class="k">def</span> <span class="nf">foo</span>
<span class="k">end</span>
</code></pre>
    HTML
    assert_equal expected, filter(input)
  end

  def test_should_strip_code_class_for_unknown_lang
    input = <<-HTML
<pre><code class="language-foobar">
def foo
end
</code></pre>
    HTML
    expected = <<-HTML
<pre><code data-language="foobar">
def foo
end
</code></pre>
    HTML
    assert_equal expected, filter(input)
  end

  def test_should_preserve_lang_in_data_language_attribute
    input = <<-HTML
<pre><code class="language-c-k&amp;r">
int i;
</code></pre>
    HTML
    expected = <<-HTML
<pre><code data-language="c-k&amp;r">
int i;
</code></pre>
    HTML
    assert_equal expected, filter(input)
  end

  def test_should_ignore_code_without_class
    input = <<-HTML
<pre><code>
def foo
end
</code></pre>
    HTML
    assert_equal input, filter(input)
  end

end
end # if Object.const_defined?(:CommonMarker)

