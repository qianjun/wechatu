namespace :ga do
  
  desc "pull users data from ga"
  task :users_data do
  	require 'rubygems'
    require 'gattica'

    gs = Gattica.new({:email => 'qianjun@comdosoft.com', :password => 'qj015181', :profile_id => "wechatu-18127"})
    results = gs.get({ :start_date => '2016-01-01', :end_date => '2017-01-01', :metrics => 'pageviews', :sort => '-pageviews'})
    p results
  end
end