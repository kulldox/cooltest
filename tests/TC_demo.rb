#!/usr/bin/env ruby -wKU
$LOAD_PATH << File.join(Dir.pwd,File.dirname(__FILE__),"..","lib");
require File.join(Dir.pwd,File.dirname(__FILE__),"..","lib")+'/cooltest/cooltest'
require File.join(Dir.pwd,File.dirname(__FILE__),"..","lib")+'/cooltest/cooltestrequest'
require File.join(Dir.pwd,File.dirname(__FILE__),"..","lib")+'/cooltest/cooltestcase'

class TC_demo < CoolTestCase

	def test_TC_demo_01(inputOptions = {})

		testOptions = {
			nodelete: false,
			id_suffix: $k.get('sitename'),
			id: "TC_demo_01",
			title: "Check the grep version is correct",
			test_assert: "2.7"

		}.merge(inputOptions||{})

		remoteServer = {
			ssh_h: $k.get('ISIpAddress'),
			ssh_u: $k.get('ISuser'),
			ssh_p: $k.get('ISpasswd'),
			ssh_port: $cfg['ISport1']
		}

		@crSSH = CooltestRequest.new('SSH')

		# ---------------------------------
		# START test
		# ---------------------------------
		@tc = CoolTest.new(testOptions[:id]+"_"+testOptions[:id_suffix], testOptions[:title])
		# ---------------------------------
		# preparations, prerequisites and cleanup
		# ---------------------------------
		os_version = @crSSH.sshcmd(remoteServer[:ssh_h], remoteServer[:ssh_u], remoteServer[:ssh_p], "uname -a", false, {port: remoteServer[:ssh_port]});
		os_date = @crSSH.sshcmd(remoteServer[:ssh_h], remoteServer[:ssh_u], remoteServer[:ssh_p], "date", false, {port: remoteServer[:ssh_port]});
		# ---------------------------------
		# request execution
		# ---------------------------------
		grep_version = @crSSH.sshcmd(remoteServer[:ssh_h], remoteServer[:ssh_u], remoteServer[:ssh_p], "grep -V", false, {port: remoteServer[:ssh_port]});
		assert_match(/#{testOptions[:test_assert]}/,grep_version);

		# ---------------------------------
		# prepare data for DTR sections
		# ---------------------------------
		appLogs = grep_version
		@tc.pause(@pauseBetweenRequests)

		# ---------------------------------
		# populate DTR sections
		# ---------------------------------

		# Prerequisites
		@tc.environment({"OS": os_version});
		@tc.prerequisites({"test prerequisites demo": "you can add here various system checks\n"+os_date});

		# Execution
		# 
		@tc.execution({"Check the 'grep' version is '#{testOptions[:test_assert]}'": grep_version});
		@tc.appLog({"Application log demo": appLogs})

		# ---------------------------------
		# save DTR in the file
		# ---------------------------------
		@tc.end();
	end
end