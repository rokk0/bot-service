require 'logger'
require 'little_log_friend'

# Thanks to
# http://stackoverflow.com/questions/917566/ruby-share-logger-instance-among-module-classes
module Logging
  # This is the magical bit that gets mixed into your classes
  def logger
    Logging.logger
  end

  # Global, memoized, lazy initialized instance of a logger
  def self.logger
    LittleLogFriend.colorize!
    @logger ||= CustomLogger.new(STDOUT)
  end

  def self.included(base)
    base.extend(self)
  end

end

# Disable useless rack logger completely! Yay, yay!
# http://gromnitsky.blogspot.com/2012/04/how-to-disable-rack-logging-in-sinatra.html
module Rack
  class CommonLogger
    def call(env)
      # do nothing
      @app.call(env)
    end
  end
end

class Clogger

  # Adding our fancy log format
  module Format

    Fancy = "#{Time.now.strftime("%Y-%m-%d %H:%M:%S")} [  REQ] from $remote_addr: \"$request_method $request_uri\" \u25B8 $status"

  end

end

class CustomLogger < Logger

  def error(message, e = nil)
    super message
    error "Exception message: #{e.message}" if e
  end

end
