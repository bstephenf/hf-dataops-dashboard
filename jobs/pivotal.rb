require 'pivotal-tracker'
require 'uri'
require 'rexml/document'

PivotalTracker::Client.token = '8ef302fb547813e8fda79c3aebe54f24'
#@project = PivotalTracker::Project.find settings.pivotal_project_id
@project = PivotalTracker::Project.find(875681)
#@projects = PivotalTracker::Project.all

#Data Ops = http://www.pivotaltracker.com/services/v3/projects/875681/stories
SCHEDULER.every '60s', :first_in => 0 do
  puts "Started: Updating Dashboard Tile - Data Ops Projects"

	resource_uri = URI.parse("http://www.pivotaltracker.com/services/v3/projects/875681/iterations/current_backlog")
	response = Net::HTTP.start(resource_uri.host, resource_uri.port) do |http|
		http.get(resource_uri.path, {'X-TrackerToken' => '8ef302fb547813e8fda79c3aebe54f24'})
	end

	xml = response.body
	#puts xml
	doc = REXML::Document.new(xml)
	project_list = ''

	i = 0
	doc.elements.each('iterations/iteration/stories/story') do |ele|

		if ele.elements['current_state'].text == 'started' and i < 6
			project_list = project_list + '<tr><td align=left>' + ele.elements['name'].text[0..80] + ' ...</td><td align=right>' + ele.elements['owned_by'].text.split[0] + ' ' + ele.elements['owned_by'].text.split[1][0..0] + '.' + '</td><td></tr>'
			i += 1
		end

	end
	project_list = '<table bgcolor=#3498db>' + project_list + '</table>'
	puts project_list
	send_event('pivotaltrackerDOlist', { text: project_list, title: 'Data Operations User Stories: In Progress', moreinfo: ''})
	#send_event('pivotaltrackerDOlist', { moreinfo: 'Source - Pivotal Tracker' })

  puts "Finished Updating Dashboard Tile - Data Ops Projects"
end

#SCHEDULER.every '10m', :first_in => 0 do
#  if @project.is_a?(PivotalTracker::Project)
#    @iteration = PivotalTracker::Iteration.current(@project)
# 
#    # Velocity
#    velocity = @project.current_velocity
# 
#    # Finished stories in the current iteration
#    finished_stories = @iteration.stories.select{|s|s.current_state == "finished"}
#    finished_count = finished_stories.length
#    finished_estimate = finished_stories.reduce(0){|sum, s| sum + s.estimate || 0}
# 
#    # Started stories in the current iteration
#    started_stories = @iteration.stories.select{|s|s.current_state == "started"}
#    started_count = started_stories.length
#    started_estimate = started_stories.reduce(0){|sum, s| sum + s.estimate || 0}
# 
#    # Unstarted
#    unstarted_stories = @iteration.stories.select{|s|s.current_state == "unstarted"}
#    unstarted_count = unstarted_stories.length
#    unstarted_estimate = unstarted_stories.reduce(0){|sum, s| sum + s.estimate || 0}
# 
#    # All stories in the current iteration
#    total_stories = finished_count + started_count + unstarted_count
#    total_estimate = finished_estimate + started_estimate + unstarted_estimate
# 
#    send_event 'pivotal', {velocity: velocity,
#                           iteration_start: @iteration.start.strftime(date_format),
#                           iteration_finish: @iteration.finish.strftime(date_format),
#                           unstarted: unstarted_count,
#                           unstarted_estimate: unstarted_estimate,
#                           started: started_count,
#                           started_estimate: started_estimate,
#                           finished: finished_count,
#                           finished_estimate: finished_estimate,
#                           total: total_stories,
#                           total_estimate: total_estimate
#    }
#  else
#    puts 'Not a Pivotal project'
#  end
#end