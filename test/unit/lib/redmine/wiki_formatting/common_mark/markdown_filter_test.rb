# frozen_string_literal: true
#
require File.expand_path('../../../../../../test_helper', __FILE__)
if Object.const_defined?(:CommonMarker)
require 'redmine/wiki_formatting/common_mark/markdown_filter'

class Redmine::WikiFormatting::CommonMark::MarkdownFilterTest < ActiveSupport::TestCase

  def filter(markdown)
    Redmine::WikiFormatting::CommonMark::MarkdownFilter.to_html(markdown)
  end

  # just a basic sanity test. more formatting tests in the formatter_test
  def test_should_render_markdown
    assert_equal "<p><strong>bold</strong></p>", filter("**bold**")
  end


end
end # if Object.const_defined?(:CommonMarker)


