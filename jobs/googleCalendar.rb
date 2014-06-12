require 'rubygems'
require 'google_calendar'

cal_do_rotation = Google::Calendar.new(:username => 'support@homefinder.com', :password => 'hf1suPport', :calendar => 'DataOps Production Rotation')

SCHEDULER.every '1h', :first_in => 0 do
  rotation_dataops = cal_do_rotation.find_events_in_range(Time.now-1, Time.now).title.split[0]

  if rotation_dataops == 'Dave'
    rotation_dataops_img = 'dmitchell.jpg'
  elsif rotation_dataops == 'Mike'
    rotation_dataops_img = 'mclark.jpg'
  elsif rotation_dataops == 'Rob'
    rotation_dataops_img = 'rwold.jpg'
  elsif rotation_dataops == 'Stephen'
    rotation_dataops_img = 'sbrehm.jpg'
  else
    rotation_dataops_img = ''
  end

  rotation_dataops = '<table width=100% bgcolor=#97c0d2><tr><td>Production Support</td></tr><tr><td><img width=75% height=75% src="/assets/' + rotation_dataops_img + '"></td></tr><tr><td>' + rotation_dataops + '</td></tr></table>'
  puts rotation_dataops
  
  send_event('rotationDO', { text: rotation_dataops, title: '', moreinfo: ''})
  puts "Updated Tile: rotationDO"
end