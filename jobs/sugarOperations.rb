require 'sugarcrm'
require 'json'
require 'pg'

conn_monitor_gqsjobswaiting = PGconn.connect("hppg1.classifiedventures.com", 5444, '', '', "hsl", "enterprisedb", "enterprisedb")
SCHEDULER.every '120s', :first_in => 0 do
  countGQSJobsWaiting = 0
  res_monitor_gqsjobswaiting = conn_monitor_gqsjobswaiting.exec("select COUNT(*) as count_gqsjobswaiting from RESALE.PROCESSQUE where PROCSERVER is null")
  res_monitor_gqsjobswaiting.each do |row_monitor_gqsjobswaiting|
    row_monitor_gqsjobswaiting.each do |column_monitor_gqsjobswaiting|
      countGQSJobsWaiting = column_monitor_gqsjobswaiting[1].to_i
    end
  end
  puts 'monitorGQSJobsWaiting:'
  puts countGQSJobsWaiting
  send_event('monitorGQSJobsWaiting',   { value: countGQSJobsWaiting })
end

conn_monitor_propqtotalwaiting = PGconn.connect("hppg1.classifiedventures.com", 5444, '', '', "hsl", "enterprisedb", "enterprisedb")
SCHEDULER.every '120s', :first_in => 0 do
  countPropQTotalWaiting = 0
  res_monitor_propqtotalwaiting = conn_monitor_propqtotalwaiting.exec("select COUNT(*) as count_propqtotalwaiting from PROP_QUEUE where STATUS_IND = 'W'")
  res_monitor_propqtotalwaiting.each do |row_monitor_propqtotalwaiting|
    row_monitor_propqtotalwaiting.each do |column_monitor_propqtotalwaiting|
      countPropQTotalWaiting = column_monitor_propqtotalwaiting[1].to_i
    end
  end
  puts 'monitorPropQTotalWaiting:'
  puts countPropQTotalWaiting
  send_event('monitorPropQTotalWaiting',   { value: countPropQTotalWaiting })
end

conn_monitor_instagewaiting = PGconn.connect("hppg1.classifiedventures.com", 5444, '', '', "hsl", "enterprisedb", "enterprisedb")
SCHEDULER.every '120s', :first_in => 0 do
  countInStageWaiting = 0
  res_monitor_instagewaiting = conn_monitor_instagewaiting.exec("select COUNT(*) as count_instagewaiting from INSTG.IN_PROP_QUEUE where STATUS_IND = 'W'")
  res_monitor_instagewaiting.each do |row_monitor_instagewaiting|
    row_monitor_instagewaiting.each do |column_monitor_instagewaiting|
      countInStageWaiting = column_monitor_instagewaiting[1].to_i
    end
  end
  puts 'monitorInStageWaiting:'
  puts countInStageWaiting
  send_event('monitorInStageWaiting',   { value: countInStageWaiting })
end

conn_monitor_imagestotalwaiting = PGconn.connect("hppg1.classifiedventures.com", 5444, '', '', "hsl", "enterprisedb", "enterprisedb")
SCHEDULER.every '120s', :first_in => 0 do
  countImagesTotalWaiting = 0
  res_monitor_imagestotalwaiting = conn_monitor_imagestotalwaiting.exec("select COUNT(*) as count_imagestotalwaiting from INSTG.CVW_IMAGE_QUEUE where STATUS_IND in ('I','T','P')")
  res_monitor_imagestotalwaiting.each do |row_monitor_imagestotalwaiting|
    row_monitor_imagestotalwaiting.each do |column_monitor_imagestotalwaiting|
      countImagesTotalWaiting = column_monitor_imagestotalwaiting[1].to_i
    end
  end
  puts 'monitorImagesTotalWaiting:'
  puts countImagesTotalWaiting
  send_event('monitorImagesTotalWaiting',   { value: countImagesTotalWaiting })
end

conn_actionableissues = PGconn.connect("hppg1.classifiedventures.com", 5444, '', '', "hsl", "enterprisedb", "enterprisedb")
SCHEDULER.every '120s', :first_in => 0 do

  #ActionableIssues - begin
  res_actionableissues_resolved = conn_actionableissues.exec('select KEY_FIELD, COUNT(*)
    from OPS_ANA.TRACKING_LOG
    where KEY_RESOLVED = 1
    group by KEY_FIELD')
  data_actionableissues_resolvedLabels = Array.new 
  data_actionableissues_resolvedValues = Array.new
  res_actionableissues_resolved.each do |row|
    data_actionableissues_resolvedLabels.push [row['key_field']]
    data_actionableissues_resolvedValues.push [row['count'].to_f]
  end
  send_event('issuesResolved2', { title: 'Actionable Issues Resolved: YTD', series: [{ data: data_actionableissues_resolvedValues }], categories: data_actionableissues_resolvedLabels, color: '#efad1b' })
  puts "Update Tile - issuesResolved2"
  #ActionableIssues - end

  res_actionableissues_identified = conn_actionableissues.exec('select KEY_FIELD, COUNT(*)
    from OPS_ANA.TRACKING_LOG
    where KEY_RESOLVED = 0
    group by KEY_FIELD')
  dataActionableIssuesIdentified = Array.new 
  res_actionableissues_identified.each do |row_actionableissues_identified|
    dataActionableIssuesIdentified.push [row_actionableissues_identified['key_field'], row_actionableissues_identified['count'].to_i]
  end
  pie_actionableissues_identified = [{ type: 'pie', name: 'Type', data: dataActionableIssuesIdentified }]
  send_event('issuesResolved', { title: 'Data Issues Identified', series: pie_actionableissues_identified, color: '#f39c12' })

end

SCHEDULER.every '1h', :first_in => 0 do
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

SCHEDULER.every '120s', :first_in => 0 do
  
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

  puts "Getting Closed Cases assigned to DataOps user ..."
  sessionSugarSRs::Case.all(:deleted => 0, :conditions => {:assigned_user_id => "cb504e22-f946-cbfa-0833-4d4c55c7f225", :status => "Closed", :date_closed_c => ">= #{$dateToday}"}) do |querySRClosedToday|
    countSRClosedToday = countSRClosedToday + 1
  end
  puts "Closed on " + $dateToday.strftime("%A")
  puts countSRClosedToday

  sessionSugarSRs::Case.all(:deleted => 0, :conditions => {:assigned_user_id => "cb504e22-f946-cbfa-0833-4d4c55c7f225", :status => "Closed", :date_closed_c => ">= #{$dateToday - 1}"}) do |querySRClosedTodayM1|
    countSRClosedTodayM1 = countSRClosedTodayM1 + 1
  end
  countSRClosedTodayM1 = countSRClosedTodayM1 - countSRClosedToday
  puts "Closed on " + ($dateToday-1).strftime("%A")
  puts countSRClosedTodayM1

  send_event('casesDataOpsClosedToday', { current: countSRClosedToday, last: countSRClosedTodayM1 })
  puts "Sent - casesDataOpsClosedToday"

  sessionSugarSRs::Case.all(:deleted => 0, :conditions => {:assigned_user_id => "cb504e22-f946-cbfa-0833-4d4c55c7f225", :status => "Closed", :date_closed_c => ">= #{$dateToday - 2}"}) do |querySRClosedTodayM2|
    countSRClosedTodayM2 = countSRClosedTodayM2 + 1
  end
  countSRClosedTodayM2 = countSRClosedTodayM2 - (countSRClosedTodayM1 + countSRClosedToday)
  puts "Closed on " + ($dateToday-2).strftime("%A")
  puts countSRClosedTodayM2

  sessionSugarSRs::Case.all(:deleted => 0, :conditions => {:assigned_user_id => "cb504e22-f946-cbfa-0833-4d4c55c7f225", :status => "Closed", :date_closed_c => ">= #{$dateToday - 3}"}) do |querySRClosedTodayM3|
    countSRClosedTodayM3 = countSRClosedTodayM3 + 1
  end
  countSRClosedTodayM3 = countSRClosedTodayM3 - countSRClosedTodayM2 - (countSRClosedTodayM1 + countSRClosedToday)
  puts "Closed on " + ($dateToday-3).strftime("%A")
  puts countSRClosedTodayM3

  sessionSugarSRs::Case.all(:deleted => 0, :conditions => {:assigned_user_id => "cb504e22-f946-cbfa-0833-4d4c55c7f225", :status => "Closed", :date_closed_c => ">= #{$dateToday - 4}"}) do |querySRClosedTodayM4|
    countSRClosedTodayM4 = countSRClosedTodayM4 + 1
  end
  countSRClosedTodayM4 = countSRClosedTodayM4 - countSRClosedTodayM3 - countSRClosedTodayM2 - (countSRClosedTodayM1 + countSRClosedToday)
  puts "Closed on " + ($dateToday-4).strftime("%A")
  puts countSRClosedTodayM4

  puts "Getting Open Cases assigned to DataOps user ..."
  sessionSugarSRs::Case.all(:deleted => 0, :conditions => {:assigned_user_id => "cb504e22-f946-cbfa-0833-4d4c55c7f225", :status => "<> 'Closed'", :name => "LIKE '%DQM%'"}) do |querySROpenInternal|
    countSROpenInternal = countSROpenInternal + 1
    countSROpenAll = countSROpenAll + 1
  end

  sessionSugarSRs::Case.all(:deleted => 0, :conditions => {:assigned_user_id => "cb504e22-f946-cbfa-0833-4d4c55c7f225", :status => "<> 'Closed'", :name => "NOT LIKE '%DQM%'"}) do |querySROpenExternal|
    countSROpenExternal = countSROpenExternal + 1
    countSROpenAll = countSROpenAll + 1
  end

  #puts "Getting Open Cases assigned to DataOps Manager ..."
  #sessionSugarSRs::Case.all(:deleted => 0, :conditions => {:assigned_user_id => idManagerDataOps.id, :status => "<> 'Closed'", :name => "LIKE '%DQM%'"}) do |querySROpenInternal|
  #  puts querySROpenInternal.case_number
  #  countSROpenInternal = countSROpenInternal + 1
  #  countSROpenAll = countSROpenAll + 1
  #end

  #sessionSugarSRs::Case.all(:deleted => 0, :conditions => {:assigned_user_id => idManagerDataOps.id, :status => "<> 'Closed'", :name => "NOT LIKE '%DQM%'"}) do |querySROpenExternal|
  #  puts querySROpenExternal.case_number
  #  countSROpenExternal = countSROpenExternal + 1
  #  countSROpenAll = countSROpenAll + 1
  #end

  #puts "Getting List of Users in DO ..."
  #sessionSugarSRs::User.all(:conditions => {:status => "Active",:reports_to_id => idManagerDataOps.id, :deleted => 0}) do |sugarUserDO| 
  #  puts sugarUserDO.id
  #  puts sugarUserDO.first_name
  #  puts sugarUserDO.last_name
  #  puts sugarUserDO.status
  #  sessionSugarSRs::Case.all(:deleted => 0, :conditions => {:assigned_user_id => sugarUserDO.id, :status => "<> 'Closed'", :name => "LIKE '%DQM%'"}) do |querySROpenInternal|
  #    puts querySROpenInternal.case_number
  #    countSROpenInternal = countSROpenInternal + 1
  #    countSROpenAll = countSROpenAll + 1
  #  end
  #  sessionSugarSRs::Case.all(:deleted => 0, :conditions => {:assigned_user_id => sugarUserDO.id, :status => "<> 'Closed'", :name => "NOT LIKE '%DQM%'"}) do |querySROpenExternal|
  #    puts querySROpenExternal.case_number
  #    countSROpenExternal = countSROpenExternal + 1
  #    countSROpenAll = countSROpenAll + 1
  #  end   
  #end

  puts "Internal:"
  puts countSROpenInternal
  puts "External:"
  puts countSROpenExternal
  puts "All:"
  puts countSROpenAll
  send_event('casesDataOpsOpenToday',   { value: countSROpenAll })
  puts "Sent - casesDataOpsOpenToday"

  #casesDataOpsClosedTrend - begin
  ex_keys = [($dateToday-4).strftime("%A"), ($dateToday-3).strftime("%A"), ($dateToday-2).strftime("%A"), ($dateToday-1).strftime("%A"), $dateToday.strftime("%A")]
  ex_data = (1..10).to_a.sample 7
  ex_data2 = [countSRClosedTodayM4, countSRClosedTodayM3, countSRClosedTodayM2, countSRClosedTodayM1, countSRClosedToday]

  sorted_exchanges = ex_keys.zip(ex_data).sort_by &:last
  ex_cats = sorted_exchanges.map { |ex| ex[0] }
  ex_data = sorted_exchanges.map { |ex| ex[1] }

  send_event('casesDataOpsClosedTrend', { series: [{ data: ex_data2 }], categories: ex_keys, color: '#efad1b' })
  puts "Update Tile - casesDataOpsClosedTrend"
  #casesDataOpsClosedTrend - end

  sessionSugarSRs.disconnect!
  puts "Disconnecting SugarCRM: sessionSugarSRs ..."
end

conn_dataFeedInventory = PGconn.connect("hppg1.classifiedventures.com", 5444, '', '', "hsl", "enterprisedb", "enterprisedb")
SCHEDULER.every '210s', :first_in => 0 do
  #dataFeedInventory - begin
  #BROKERS
  res_dataFeedInventory = conn_dataFeedInventory.exec('select active_brokers, run_date from
    (
    select DATAPNT_VALUE as active_brokers, run_date from OPS_ANA.fdinv_datapnt_value
    where FDINV_DATAPOINT_ID = 14
    order by RUN_DATE desc
    )
    where rownum <= 5')
  dataFeedInventoryLabels = Array.new
  dataFeedInventoryValues = Array.new
  res_dataFeedInventory.each do |row|
    dataFeedInventoryLabels.push [row['run_date']]
    dataFeedInventoryValues.push [row['active_brokers'].to_f]
  end
  send_event('dataFeedInventory', { title: 'Feed Inventory Trend: Number of Active Brokers', series: [{ data: dataFeedInventoryValues }], categories: dataFeedInventoryLabels, color: '#efad1b' })
  dataFeedInventoryLabels.clear
  dataFeedInventoryValues.clear
  puts "Update Tile - dataFeedInventory: brokers"
  sleep 30

  #AGENTS
  res_dataFeedInventory = conn_dataFeedInventory.exec('select active_agents, run_date from
    (
    select DATAPNT_VALUE as active_agents, run_date from OPS_ANA.fdinv_datapnt_value
    where FDINV_DATAPOINT_ID = 22
    order by RUN_DATE desc
    )
    where rownum <= 5')
  dataFeedInventoryLabels = Array.new 
  dataFeedInventoryValues = Array.new 
  res_dataFeedInventory.each do |row|
    dataFeedInventoryLabels.push [row['run_date']]
    dataFeedInventoryValues.push [row['active_agents'].to_f]
  end
  send_event('dataFeedInventory', { title: 'Feed Inventory Trend: Number of Active Agents', series: [{ data: dataFeedInventoryValues }], categories: dataFeedInventoryLabels, color: '#efad1b' })
  dataFeedInventoryLabels.clear
  dataFeedInventoryValues.clear
  puts "Update Tile - dataFeedInventory: agents"
  sleep 30

  #LISTINGS
  res_dataFeedInventory = conn_dataFeedInventory.exec('select active_listings, run_date from
    (
    select DATAPNT_VALUE as active_listings, run_date from OPS_ANA.fdinv_datapnt_value
    where FDINV_DATAPOINT_ID = 5
    order by RUN_DATE desc
    )
    where rownum <= 5')
  dataFeedInventoryLabels = Array.new 
  dataFeedInventoryValues = Array.new 
  res_dataFeedInventory.each do |row|
    dataFeedInventoryLabels.push [row['run_date']]
    dataFeedInventoryValues.push [row['active_listings'].to_f]
  end
  send_event('dataFeedInventory', { title: 'Feed Inventory Trend: Number of Active Listings', series: [{ data: dataFeedInventoryValues }], categories: dataFeedInventoryLabels, color: '#efad1b' })
  dataFeedInventoryLabels.clear
  dataFeedInventoryValues.clear
  puts "Update Tile - dataFeedInventory: listings"
  sleep 30

  #IMAGES
  res_dataFeedInventory = conn_dataFeedInventory.exec('select active_images, run_date from
    (
    select DATAPNT_VALUE as active_images, run_date from OPS_ANA.fdinv_datapnt_value
    where FDINV_DATAPOINT_ID = 57
    order by RUN_DATE desc
    )
    where rownum <= 5')
  dataFeedInventoryLabels = Array.new 
  dataFeedInventoryValues = Array.new 
  res_dataFeedInventory.each do |row|
    dataFeedInventoryLabels.push [row['run_date']]
    dataFeedInventoryValues.push [row['active_images'].to_f]
  end
  send_event('dataFeedInventory', { title: 'Feed Inventory Trend: Number of Active Images', series: [{ data: dataFeedInventoryValues }], categories: dataFeedInventoryLabels, color: '#efad1b' })
  dataFeedInventoryLabels.clear
  dataFeedInventoryValues.clear
  puts "Update Tile - dataFeedInventory: images"
  sleep 30

  #OPENHOUSES
  res_dataFeedInventory = conn_dataFeedInventory.exec('select active_openhouses, run_date from
    (
    select DATAPNT_VALUE as active_openhouses, run_date from OPS_ANA.fdinv_datapnt_value
    where FDINV_DATAPOINT_ID = 65
    order by RUN_DATE desc
    )
    where rownum <= 5')
  dataFeedInventoryLabels = Array.new 
  dataFeedInventoryValues = Array.new 
  res_dataFeedInventory.each do |row|
    dataFeedInventoryLabels.push [row['run_date']]
    dataFeedInventoryValues.push [row['active_openhouses'].to_f]
  end
  send_event('dataFeedInventory', { title: 'Feed Inventory Trend: Number of Active Open Houses', series: [{ data: dataFeedInventoryValues }], categories: dataFeedInventoryLabels, color: '#efad1b' })
  dataFeedInventoryLabels.clear
  dataFeedInventoryValues.clear
  puts "Update Tile - dataFeedInventory: openhouses"
  sleep 30

  #FEEDS
  res_dataFeedInventory = conn_dataFeedInventory.exec('select active_feeds, run_date from
    (
    select DATAPNT_VALUE as active_feeds, run_date from OPS_ANA.fdinv_datapnt_value
    where FDINV_DATAPOINT_ID = 53
    order by RUN_DATE desc
    )
    where rownum <= 5')
  dataFeedInventoryLabels = Array.new 
  dataFeedInventoryValues = Array.new
  res_dataFeedInventory.each do |row|
    dataFeedInventoryLabels.push [row['run_date']]
    dataFeedInventoryValues.push [row['active_feeds'].to_f]
  end
  send_event('dataFeedInventory', { title: 'Feed Inventory Trend: Number of Active Feeds', series: [{ data: dataFeedInventoryValues }], categories: dataFeedInventoryLabels, color: '#efad1b' })
  dataFeedInventoryLabels.clear
  dataFeedInventoryValues.clear
  puts "Update Tile - dataFeedInventory: feeds"
  #dataFeedInventory - end
end