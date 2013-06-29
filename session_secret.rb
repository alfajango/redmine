require 'active_support/secure_random'
random_string = ActiveSupport::SecureRandom.hex(30)
puts random_string