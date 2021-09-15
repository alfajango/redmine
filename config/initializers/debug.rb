# There is an issue that I cannot figure out where Ruby 2.6.8 with all gems
# loaded is exhibiting the wrong behavior for the Hash[] method used in the
# initialize method below in the Rails source. This is causing the Rails app to fail to boot in production mode (but not in development), due to incorrectly parsing the constraints from the options.
# In both development and production, the `split_options` hash looks the same, but in the next line, the `constraints` hash will be correct in development but incorrect in production.
# I was able to narrow this down to the pure Ruby behavior of Hash[]. I can do this in the development mode Rails console and get the expected behavior:
#
# Hash[ [[:path, /.+?/]] ] #=> {:path => /.+?/}
#
# But if I tried it in the production mode Rails console (even on the same machine), it would have the incorrect behavior:
#
# Hash[ [[:path, /.+?/]] ] #=> {0=>[:path, /.+?/]}
#
# I monkeypatched the Hash class in an initializer to see if anything in Redmine or the plugins was messing the the Ruby Hash[] method, but it didn't show anything, which leads me to believe it's a gem somewhere in the dependency tree, but I didn't have time to go looking for it. So for now, we have this ugly patch, which changes all instances of:
#
# Hash[ some_array ]
#
# To:
#
# some_array.to_h
#
# In the ActionDispatch::Routing::Mapper::Mapping#initialize method, with everything else being the same as the original, which can be found here:
#
# https://github.com/rails/rails/blob/48661542a2607d55f436438fe21001d262e61fec/actionpack/lib/action_dispatch/routing/mapper.rb#L102-L148
#
# Ideally, we can delete this in a future version or Redmine and/or Rails. The error this fixes is upon booting the Rails app, you would see this in the logs, followed by the app crashing:
#
# TypeError: 0 is not a symbol nor a string
# /app/vendor/bundle/ruby/2.6.0/gems/actionpack-5.2.6/lib/action_dispatch/routing/mapper.rb:180:in `public_method_defined?'
# /app/vendor/bundle/ruby/2.6.0/gems/actionpack-5.2.6/lib/action_dispatch/routing/mapper.rb:180:in `block in build_conditions'
# /app/vendor/bundle/ruby/2.6.0/gems/actionpack-5.2.6/lib/action_dispatch/routing/mapper.rb:179:in `keep_if'
# /app/vendor/bundle/ruby/2.6.0/gems/actionpack-5.2.6/lib/action_dispatch/routing/mapper.rb:179:in `build_conditions'
# /app/vendor/bundle/ruby/2.6.0/gems/actionpack-5.2.6/lib/action_dispatch/routing/mapper.rb:173:in `conditions'
# /app/vendor/bundle/ruby/2.6.0/gems/actionpack-5.2.6/lib/action_dispatch/routing/mapper.rb:154:in `make_route'
# /app/vendor/bundle/ruby/2.6.0/gems/actionpack-5.2.6/lib/action_dispatch/journey/routes.rb:67:in `add_route'
# /app/vendor/bundle/ruby/2.6.0/gems/actionpack-5.2.6/lib/action_dispatch/routing/route_set.rb:591:in `add_route'
# /app/vendor/bundle/ruby/2.6.0/gems/actionpack-5.2.6/lib/action_dispatch/routing/mapper.rb:1933:in `add_route'
# /app/vendor/bundle/ruby/2.6.0/gems/actionpack-5.2.6/lib/action_dispatch/routing/mapper.rb:1904:in `decomposed_match'
# /app/vendor/bundle/ruby/2.6.0/gems/actionpack-5.2.6/lib/action_dispatch/routing/mapper.rb:1868:in `block in map_match'
# /app/vendor/bundle/ruby/2.6.0/gems/actionpack-5.2.6/lib/action_dispatch/routing/mapper.rb:1862:in `each'
# /app/vendor/bundle/ruby/2.6.0/gems/actionpack-5.2.6/lib/action_dispatch/routing/mapper.rb:1862:in `map_match'
# /app/vendor/bundle/ruby/2.6.0/gems/actionpack-5.2.6/lib/action_dispatch/routing/mapper.rb:1610:in `match'
# /app/vendor/bundle/ruby/2.6.0/gems/actionpack-5.2.6/lib/action_dispatch/routing/mapper.rb:743:in `map_method'
# /app/vendor/bundle/ruby/2.6.0/gems/actionpack-5.2.6/lib/action_dispatch/routing/mapper.rb:704:in `get'
# /app/config/routes.rb:279:in `block (2 levels) in <top (required)>'
#
# This would happen for any route that either used direct parameter constraints without the :constraints hash, like this with the :id constraint:
#
# match '/issues/:id/quoted', :to => 'journals#new', :id => /\d+/, :via => :post, :as => 'quoted_issue'
#
# And also any route that used path globbing, like this:
#
# get "projects/:id/repository/:repository_id/revisions/:rev/#{action}(/*path)",
#     :controller => 'repositories',
#     :action => action,
#     :format => 'html',
#     :constraints => {:rev => /[a-z0-9\.\-_]+/, :path => /.*/}

module ActionDispatch
  module Routing
    class Mapper
      class Mapping
        def initialize(set, ast, defaults, controller, default_action, modyoule, to, formatted, scope_constraints, blocks, via, options_constraints, anchor, options)
          @defaults = defaults
          @set = set

          @to                 = to
          @default_controller = controller
          @default_action     = default_action
          @ast                = ast
          @anchor             = anchor
          @via                = via
          @internal           = options.delete(:internal)

          path_params = ast.find_all(&:symbol?).map(&:to_sym)

          options = add_wildcard_options(options, formatted, ast)

          options = normalize_options!(options, path_params, modyoule)

          split_options = constraints(options, path_params)

          constraints = scope_constraints.merge (split_options[:constraints] || []).to_h

          if options_constraints.is_a?(Hash)
            @defaults = options_constraints.find_all { |key, default|
              URL_OPTIONS.include?(key) && (String === default || Integer === default)
            }.to_h.merge @defaults
            @blocks = blocks
            constraints.merge! options_constraints
          else
            @blocks = blocks(options_constraints)
          end

          requirements, conditions = split_constraints path_params, constraints
          verify_regexp_requirements requirements.map(&:last).grep(Regexp)

          formats = normalize_format(formatted)

          @requirements = formats[:requirements].merge requirements.to_h
          @conditions = conditions.to_h
          @defaults = formats[:defaults].merge(@defaults).merge(normalize_defaults(options))

          if path_params.include?(:action) && !@requirements.key?(:action)
            @defaults[:action] ||= "index"
          end

          @required_defaults = (split_options[:required_defaults] || []).map(&:first)
        end
      end
    end
  end
end
