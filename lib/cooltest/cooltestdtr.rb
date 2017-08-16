##
# The purpose of this class is to create/store/dump the Internal DB with data from Test Execution
# The dump is in Markdown format
# 
class CooltestDTR
	include Logging
	attr_accessor :title, :area, :environment, :requirements, :prerequisites, :execution, :appLog 
	##
	# Initialization of the internal DB
	# ==== Attributes
	# * +params+ - a hash with all the DTR parameters as follows:
	# 
	# 	* @title = {}; 			# test case name/title
	# 	* @area = "";				# Optional: a short description of the test case or some other info, like what is the area this test belongs to
	# 	* @requirements = {};		# Future Use: a list of ERS requirements covered by this test case
	# 	* @prerequisites = {};		# the prerequisites section in the DTR
	# 	* @execution = {}; 			# execution steps  
	# 	* @appLog = {};			# application logs DSPA/PPS/...
	def initialize(params = {})
		# if params.size > 0 
			@title = params[:title] || {}; 		# test case name/title
			@area = params[:area] || "";	# future use, add requirement maybe?
			@environment = params[:environment] || {};	# the environment the TC is executed on
			@requirements = params[:requirements] || {};	# a list of ERS requirements covered by this test case
			@prerequisites = params[:prerequisites] || {};	# the prerequisites section in the DTR
			@execution = params[:execution] || {};	# execution steps
			@appLog = params[:appLog] || {};	# application logs, ex. DSPA/PPS/UPSELL/UI/etc.
		# end
	end

	##
	# Dumps the DTR object (internal DB) to string so that it can be saved into a file in Markdown format
	# 
	# ==== Note:
	# 	the elements in each of the hashes names/keys should have unique values
	# ==== Attributes
	# none
	# 
	def to_s
		out = "";
		# title
		out += "# #{@title[:name].gsub!(/_/,'\_')}: #{@title[:title]}\n\n"
		# environment
		out += "## Environment:\n" if @environment.size > 0
		@environment.each { |pk,pv|
			out += "### #{pk}\n```\n#{pv}\n```\n"	
		}
		# prerequisites
		out += "## Prerequisites:\n" if @prerequisites.size > 0
		@prerequisites.each { |pk,pv|
			out += "### #{pk}\n```\n#{pv}\n```\n"	
		}
		# execution
		out += "## Execution:\n" if @execution.size > 0
		# p execution.size, execution
		@execution.each { |pk,pv|
			out += "### #{pk}\n```\n#{pv}\n```\n"	
		}
		# appLog
		out += "### Application logs:\n" if @appLog.size > 0
		@appLog.each { |pk,pv|
			out += "#### #{pk}\n```\n#{pv}\n```\n"	
		}
		return out
	end
end