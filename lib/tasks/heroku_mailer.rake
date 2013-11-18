task :send_redmine_weekly_mailer => :environment do
  if Time.now.monday?
    Rake::Task["redmin:stuff_to_do:send_periodic_mailer"].invoke
  end
end
