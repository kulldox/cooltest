# TODO: implement configuration switch by test environment
# Variables starting with $ are global, variables with @ are instance variables, @@ means class variables, and names starting with a capital letter are constants.

require 'date'
require 'logger'
APPDIR = Dir.pwd;
CURDIR = File.dirname(__FILE__);
$LOAD_PATH << File.join("#{APPDIR}/#{CURDIR}","..","lib");
# require "#{APPDIR}/lib/cooltest/commonFunctions";
# include CommonFunctions

# global variable to store the configuration
$cfg = {}

# one of: DEBUG < INFO < WARN < ERROR < FATAL < UNKNOWN
$cfg['logLevel'] = Logger::DEBUG
# one of: [:info, :debug, :warn, :error, :fatal]
$cfg['soapLogLevel'] = :error
$cfg['logDir'] = "#{APPDIR}/log/"
$cfg['logFile'] = $stdout
# uncomment this line, if you want the execution output to be saved in a file
$cfg['logFile'] = $cfg['logDir']+'myfile.log'
# ages the logfile daily/weekly/monthly
$cfg['logFileAging'] = 'daily'
# the timestamp format in logs according to http://ruby-doc.org/stdlib-2.1.1/libdoc/date/rdoc/Date.html#strftime-method
$cfg['logFileDateFormat'] = '%Y-%m-%d %H:%M:%S.%L%z'

$cfg['dtrDir'] = "#{APPDIR}/dtr/"

# custom configs
require "#{APPDIR}/conf/napGeneral.rb"