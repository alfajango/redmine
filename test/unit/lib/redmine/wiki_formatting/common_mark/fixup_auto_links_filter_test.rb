# frozen_string_literal: true
#
require File.expand_path('../../../../../../test_helper', __FILE__)

if Object.const_defined?(:CommonMarker)
require 'redmine/wiki_formatting/common_mark/fixup_auto_links_filter'

class Redmine::WikiFormatting::CommonMark::FixupAutoLinksFilterTest < ActiveSupport::TestCase

  def filter(html)
    Redmine::WikiFormatting::CommonMark::FixupAutoLinksFilter.to_html(html, @options)
  end

  def format(markdown)
    Redmine::WikiFormatting::CommonMark::MarkdownFilter.to_html(markdown, Redmine::WikiFormatting::CommonMark::PIPELINE_CONFIG)
  end

  def setup
    @options = { }
  end

  def test_should_fixup_autolinked_user_references
    text = "user:user@example.org"
    assert_equal "<p>#{text}</p>", filter(format(text))
    text = "@user@example.org"
    assert_equal "<p>#{text}</p>", filter(format(text))
  end

  def test_should_fixup_autolinked_hires_files
    text = "printscreen@2x.png"
    assert_equal "<p>#{text}</p>", filter(format(text))
  end

end
end # if Object.const_defined?(:CommonMarker)



