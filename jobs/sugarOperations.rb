require 'sugarcrm'
require 'json'

SCHEDULER.every '1h', :blocking => true, :first_in => 0 do
  puts "Started: Setting Global Variables ..."
  $dateToday = Date.new(Date.today.year, Date.today.month, Date.today.day)
  puts "$dateToday: " + $dateToday.to_s()
  $dateUpdate = $dateToday - 5
  puts "$dateUpdate: " + $dateUpdate.to_s()
  $dateYMD = Date.new(Date.today.year, 1, 1)
  puts "$dateYMD: " + $dateYMD.to_s()
  puts "Finished: Setting Global Variables ..."

  send_event('iframe_statusboard', { url: 'http://status.homefinder.com' })
end

SCHEDULER.every '120s', :blocking => true, :first_in => 0 do
  
  # Establish a connection
  puts "Connecting SugarCRM: sessionSugarSRs ..."
  sessionSugarSRs = SugarCRM.connect("https://homefinder.sugarondemand.com", 'HomeFinder', 'HomeFinder175')

  #Get Sugar ID of DataOps Manager
  idManagerDataOps = sessionSugarSRs::User.find_by_last_name("Clark")
  puts "Manager - DataOps:"
  puts idManagerDataOps.id

  countSRClosedToday = 0
  countSRClosedTodayM1 = 0
  countSRClosedTodayM2 = 0
  countSRClosedTodayM3 = 0
  countSRClosedTodayM4 = 0
  countSROpenInternal = 0
  countSROpenExternal = 0
  countSROpenAll = 0

  puts "Getting Cased Assigned to DataOps user ..."
  sessionSugarSRs::Case.all(:deleted => 0, :conditions => {:assigned_user_id => "cb504e22-f946-cbfa-0833-4d4c55c7f225", :status => "<> 'Closed'", :name => "LIKE '%DQM%'"}) do |querySROpenInternal|
    puts querySROpenInternal.case_number
    #puts querySRClosedToday.date_closed_c.year
    #puts querySRClosedToday.date_closed_c.month
    #puts querySRClosedToday.date_closed_c.day
    countSROpenInternal = countSROpenInternal + 1
    countSROpenAll = countSROpenAll + 1
  end

  sessionSugarSRs::Case.all(:deleted => 0, :conditions => {:assigned_user_id => "cb504e22-f946-cbfa-0833-4d4c55c7f225", :status => "Closed", :date_closed_c => ">= #{$dateToday}"}) do |querySRClosedToday|
    countSRClosedToday = countSRClosedToday + 1
  end
  puts "Closed on " + $dateToday.strftime("%A")
  puts countSRClosedToday

  sessionSugarSRs::Case.all(:deleted => 0, :conditions => {:assigned_user_id => "cb504e22-f946-cbfa-0833-4d4c55c7f225", :status => "Closed", :date_closed_c => ">= #{$dateToday - 1}"}) do |querySRClosedTodayM1|
    countSRClosedTodayM1 = countSRClosedTodayM1 + 1
  end
  puts "Closed on " + ($dateToday-1).strftime("%A")
  puts countSRClosedTodayM1


  send_event('casesDataOpsClosedToday', { current: countSRClosedToday, last: countSRClosedTodayM1 })
  puts "Sent - casesDataOpsClosedToday"

  sessionSugarSRs::Case.all(:deleted => 0, :conditions => {:assigned_user_id => "cb504e22-f946-cbfa-0833-4d4c55c7f225", :status => "Closed", :date_closed_c => ">= #{$dateToday - 2}"}) do |querySRClosedTodayM2|
    countSRClosedTodayM2 = countSRClosedTodayM2 + 1
  end
  puts "Closed on " + ($dateToday-2).strftime("%A")
  puts countSRClosedTodayM2

  sessionSugarSRs::Case.all(:deleted => 0, :conditions => {:assigned_user_id => "cb504e22-f946-cbfa-0833-4d4c55c7f225", :status => "Closed", :date_closed_c => ">= #{$dateToday - 3}"}) do |querySRClosedTodayM3|
    countSRClosedTodayM3 = countSRClosedTodayM3 + 1
  end
  puts "Closed on " + ($dateToday-3).strftime("%A")
  puts countSRClosedTodayM3

  sessionSugarSRs::Case.all(:deleted => 0, :conditions => {:assigned_user_id => "cb504e22-f946-cbfa-0833-4d4c55c7f225", :status => "Closed", :date_closed_c => ">= #{$dateToday - 4}"}) do |querySRClosedTodayM4|
    countSRClosedTodayM4 = countSRClosedTodayM4 + 1
  end
  puts "Closed on " + ($dateToday-4).strftime("%A")
  puts countSRClosedTodayM4

  sessionSugarSRs::Case.all(:deleted => 0, :conditions => {:assigned_user_id => "cb504e22-f946-cbfa-0833-4d4c55c7f225", :status => "<> 'Closed'", :name => "NOT LIKE '%DQM%'"}) do |querySROpenExternal|
    puts querySROpenExternal.case_number
    #puts querySRClosedToday.date_closed_c.year
    #puts querySRClosedToday.date_closed_c.month
    #puts querySRClosedToday.date_closed_c.day
    countSROpenExternal = countSROpenExternal + 1
    countSROpenAll = countSROpenAll + 1
  end

  puts "Getting Cased Assigned to DataOps Manager ..."
  sessionSugarSRs::Case.all(:deleted => 0, :conditions => {:assigned_user_id => idManagerDataOps.id, :status => "<> 'Closed'", :name => "LIKE '%DQM%'"}) do |querySROpenInternal|
    puts querySROpenInternal.case_number
    #puts querySRClosedToday.date_closed_c.year
    #puts querySRClosedToday.date_closed_c.month
    #puts querySRClosedToday.date_closed_c.day
    countSROpenInternal = countSROpenInternal + 1
    countSROpenAll = countSROpenAll + 1
  end

  sessionSugarSRs::Case.all(:deleted => 0, :conditions => {:assigned_user_id => idManagerDataOps.id, :status => "<> 'Closed'", :name => "NOT LIKE '%DQM%'"}) do |querySROpenExternal|
    puts querySROpenExternal.case_number
    #puts querySRClosedToday.date_closed_c.year
    #puts querySRClosedToday.date_closed_c.month
    #puts querySRClosedToday.date_closed_c.day
    countSROpenExternal = countSROpenExternal + 1
    countSROpenAll = countSROpenAll + 1
  end
    
  puts "Getting List of Users in DO ..."
  sessionSugarSRs::User.all(:conditions => {:status => "Active",:reports_to_id => idManagerDataOps.id, :deleted => 0}) do |sugarUserDO| 
    puts sugarUserDO.id
    puts sugarUserDO.first_name
    puts sugarUserDO.last_name
    puts sugarUserDO.status

    sessionSugarSRs::Case.all(:deleted => 0, :conditions => {:assigned_user_id => sugarUserDO.id, :status => "<> 'Closed'", :name => "LIKE '%DQM%'"}) do |querySROpenInternal|
      puts querySROpenInternal.case_number
      #puts querySRClosedToday.date_closed_c.year
      #puts querySRClosedToday.date_closed_c.month
      #puts querySRClosedToday.date_closed_c.day
      countSROpenInternal = countSROpenInternal + 1
      countSROpenAll = countSROpenAll + 1
    end

    sessionSugarSRs::Case.all(:deleted => 0, :conditions => {:assigned_user_id => sugarUserDO.id, :status => "<> 'Closed'", :name => "NOT LIKE '%DQM%'"}) do |querySROpenExternal|
      puts querySROpenExternal.case_number
      #puts querySRClosedToday.date_closed_c.year
      #puts querySRClosedToday.date_closed_c.month
      #puts querySRClosedToday.date_closed_c.day
      countSROpenExternal = countSROpenExternal + 1
      countSROpenAll = countSROpenAll + 1
    end
    
  end

  puts "Internal:"
  puts countSROpenInternal
  puts "External:"
  puts countSROpenExternal
  puts "All:"
  puts countSROpenAll
  send_event('casesDataOpsOpenToday',   { value: countSROpenAll })
  puts "Sent - casesDataOpsOpenToday"


  ### TOP EXCHANGES
  ex_keys = [($dateToday-4).strftime("%A"), ($dateToday-3).strftime("%A"), ($dateToday-2).strftime("%A"), ($dateToday-1).strftime("%A"), $dateToday.strftime("%A")]
  ex_data = (1..10).to_a.sample 7
  ex_data2 = [countSRClosedTodayM4, countSRClosedTodayM3, countSRClosedTodayM2, countSRClosedTodayM1, countSRClosedToday]

  sorted_exchanges = ex_keys.zip(ex_data).sort_by &:last
  ex_cats = sorted_exchanges.map { |ex| ex[0] }
  ex_data = sorted_exchanges.map { |ex| ex[1] }

  send_event('casesDataOpsClosedTrend', { series: [{ data: ex_data2 }], categories: ex_keys, color: '#efad1b' })
  puts "Update Tile - casesDataOpsClosedTrend"
  ### TOP EXCHANGES

  sessionSugarSRs.disconnect!
  puts "Disconnecting SugarCRM: sessionSugarSRs ..."
  #-----#
end