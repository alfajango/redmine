# This file was generated by 'rake config/initializers/session_store.rb',
# and should not be made visible to public.
# If you have a load-balancing Redmine cluster, you will need to use the
# same version of this file on each machine. And be sure to restart your
# server when you modify this file.

# Your secret key for verifying cookie session data integrity. If you
# change this key, all old sessions will become invalid! Make sure the
# secret is at least 30 characters and all random, no regular words or
# you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key => '_redmine_session',
  #
  # Uncomment and edit the :session_path below if are hosting your Redmine
  # at a suburi and don't want the top level path to access the cookies
  #
  # See: http://www.redmine.org/issues/3968
  #
  # :session_path => '/url_path_to/your/redmine/',
  :secret => ENV['SESSION_SECRET']
}
