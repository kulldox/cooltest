require 'logger'

module Logging
  class << self
      def logger
        @logger ||= self.config_loger()
      end

      def logger=(logger)
        @logger = logger
      end

      def eod(t)
        Time.mktime(t.year, t.month, t.mday, 23, 59, 59)
      end

      SiD = 24 * 60 * 60

      def previous_period_end(now)
        case $cfg['logFileAging']
          when /^daily$/
            eod(now - 1 * SiD)
          when /^weekly$/
            eod(now - ((now.wday + 1) * SiD))
          when /^monthly$/
            eod(now - now.mday * SiD)
          else
            now
        end
      end

      def config_loger()
        # this is a work around to the standard aging function of the logger lib. 
        iLogFile = $cfg['logFile']
        begin
          
          if FileTest.exist?("#{iLogFile}")
            if File.ctime(iLogFile) <= previous_period_end(Time.now) or File.mtime(iLogFile) <= previous_period_end(Time.now)
              postfix = previous_period_end(Time.now).strftime("%Y%m%d") # YYYYMMDD

              File.rename(iLogFile, iLogFile+"."+postfix)
            end
          end
        rescue Exception => e
              p "=========================================="
              p "Huston, we've got a problem"
              p "=========================================="
              p e
              p "=========================================="
              exit
        end
        iLogFile = File.open($cfg['logFile'], 'a+');
        iLogFile.sync = false
        logger ||= Logger.new(iLogFile, $cfg['logFileAging'])
        logger.level = $cfg['logLevel']
        logger.datetime_format = $cfg['logFileDateFormat']
        logger.formatter = proc { |severity, datetime, progname, msg|
          "#{datetime.strftime($cfg["logFileDateFormat"])}\t#{severity}\t#{caller[4].split(/(\/|\\)/).last.gsub(/(`|')/,'\'')}\t#{msg}\n"
        }
        logger
      end
  end
  # Addition
  def self.included(base)
    class << base
      def logger
        Logging.logger
      end
    end
  end

  def logger
    # self.class.logger
    Logging.logger
  end

end