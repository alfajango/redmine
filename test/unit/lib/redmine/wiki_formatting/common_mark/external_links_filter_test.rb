# frozen_string_literal: true
#
require File.expand_path('../../../../../../test_helper', __FILE__)
if Object.const_defined?(:CommonMarker)
require 'redmine/wiki_formatting/common_mark/external_links_filter'

class Redmine::WikiFormatting::CommonMark::ExternalLinksFilterTest < ActiveSupport::TestCase

  def filter(html)
    Redmine::WikiFormatting::CommonMark::ExternalLinksFilter.to_html(html, @options)
  end

  def setup
    @options = { }
  end

  def test_external_links_should_have_external_css_class
    assert_equal %(<a href="http://example.net/" class="external">link</a>), filter(%(<a href="http://example.net/">link</a>))
  end

  def test_locals_links_should_not_have_external_css_class
    assert_equal %(<a href="/">home</a>), filter(%(<a href="/">home</a>))
    assert_equal %(<a href="relative">relative</a>), filter(%(<a href="relative">relative</a>))
    assert_equal %(<a href="#anchor">anchor</a>), filter(%(<a href="#anchor">anchor</a>))
  end

  def test_mailto_links_should_have_email_class
    assert_equal %(<a href="mailto:user@example.org" class="email">user</a>), filter(%(<a href="mailto:user@example.org">user</a>))
  end


end
end # if Object.const_defined?(:CommonMarker)


