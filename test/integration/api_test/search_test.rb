# Redmine - project management software
# Copyright (C) 2006-2015  Jean-Philippe Lang
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

require File.expand_path('../../../test_helper', __FILE__)

class Redmine::ApiTest::SearchTest < Redmine::ApiTest::Base
  fixtures :projects, :issues

  test "GET /search.xml should return xml content" do
    get '/search.xml'

    assert_response :success
    assert_equal 'application/xml', @response.content_type
  end

  test "GET /search.json should return json content" do
    get '/search.json'

    assert_response :success
    assert_equal 'application/json', @response.content_type

    json = ActiveSupport::JSON.decode(response.body)
    assert_kind_of Hash, json
    assert_kind_of Array, json['results']
  end

  test "GET /search.xml without query strings should return empty results" do
    get '/search.xml', :q => '', :all_words => ''

    assert_response :success
    assert_equal 0, assigns(:results).size
  end

  test "GET /search.xml with query strings should return results" do
    get '/search.xml', :q => 'recipe subproject commit', :all_words => ''

    assert_response :success
    assert_not_empty(assigns(:results))

    assert_select 'results[type=array]' do
      assert_select 'result', :count => assigns(:results).count
      assigns(:results).size.times.each do |i|
        assert_select 'result' do
          assert_select 'id',          :text => assigns(:results)[i].id.to_s
          assert_select 'title',       :text => assigns(:results)[i].event_title
          assert_select 'type',        :text => assigns(:results)[i].event_type
          assert_select 'url',         :text => url_for(assigns(:results)[i].event_url(:only_path => false))
          assert_select 'description', :text => assigns(:results)[i].event_description
          assert_select 'datetime'
        end
      end
    end
  end
end