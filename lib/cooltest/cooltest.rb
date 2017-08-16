require 'rubygems'
require 'fileutils'
require File.dirname(__FILE__)+"/../config/config";
require "#{APPDIR}/lib/logging/logging"
require "#{APPDIR}/lib/cooltest/cooltestdtr";

##
# CoolTest is basically the main class where all the functions needed to start and execute a test are available. It also exposes connection to the DTR functions and saves it to a file at the end of the run. It represents a single Test Case currently running. 
# 
class CoolTest
	include Logging
	attr_accessor :id, :title #:nodoc:

	def initialize(tcid, tctitle) #:nodoc:
		@dtr ||= CooltestDTR.new();
		@id = tcid;
		@title = tctitle;
		@dtr.environment = $cfg['defEnvironment'];
		@dtr.title = {:name => @id, :title => @title };
		logger.info "Starting: "+@id
	end

	##
	# Waits/pause execution for the given amount of seconds
	# 
	# ==== Attributes
	# * +delayValue+ - seconds
	# 
	def pause(delayValue)
		logger.debug "start sleep for #{delayValue} sec "+DateTime.now.strftime("%Y-%m-%dT%H:%M:%S")
		sleep(delayValue)
		logger.debug "end sleep for #{delayValue} sec "+DateTime.now.strftime("%Y-%m-%dT%H:%M:%S")
	end

	##
	# Updates the ID of the test case
	# 
	# ==== Attributes
	# * +tcid+ - TC ID
	# 
	def setTCID(tcid)
		logger.info "Update TCID from '#{@id}' to '#{tcid}'."
		@id = tcid;
		@dtr.title = {:name => @id, :title => @title};
	end

	##
	# Populates internal DB with a environment Hash
	# 
	# ==== Attributes
	# * +param+ - a Hash like following
	# 	{"Header": contents}
	# 
	def environment(param)
		@dtr.environment = @dtr.environment.merge(param)
	end

	##
	# Populates internal DB with a prerequisite Hash
	# 
	# ==== Attributes
	# * +param+ - a Hash like following
	# 	{"Header": contents}
	# 
	def prerequisites(param)
		@dtr.prerequisites = @dtr.prerequisites.merge(param)
	end

	##
	# Populates internal DB with a execution step Hash
	# 
	# ==== Attributes
	# * +param+ - a Hash like following
	# 	{"Header": contents}
	# 
	def execution(param)
		@dtr.execution = @dtr.execution.merge(param)
	end
	
	##
	# Populates internal DB with an application log step Hash
	# 
	# ==== Attributes
	# * +param+ - a Hash like following
	# 	{"Header": contents}
	# 
	def appLog(param)
		@dtr.appLog = @dtr.appLog.merge(param)
	end
	
	##
	# This method is called at the end of each test to dump the internal DB data into a DTR file. It is saved into the +/dtr+ folder and is called: +<test_id>.txt+
	# ==== Attributes
	# * +subFolderName+ - the subFolder under /dtr to create the DTR in. defaults to the filename where this method is called from
	# 
	def end(subFolderName = '')
		puts DateTime.now.strftime("%Y-%m-%dT%H:%M:%S")+" Ending: "+@id
		sfn = subFolderName != '' ? subFolderName+'/' : caller_locations(1,1)[0].to_s[/\/(.*?):/,1].sub(/\.rb/,"")+'/'
		iFolder = $k.get('dtrDir')+sfn.to_s
		Dir.mkdir(iFolder) unless Dir.exist?(iFolder)
		File.open(iFolder+@id+".txt", 'w') { |file| file.write(@dtr.to_s) }
		logger.info "DTR saved into "+iFolder+@id+".txt"
		logger.close
	end
end