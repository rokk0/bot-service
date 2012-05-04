require 'logger'

# Thanks to
# http://stackoverflow.com/questions/917566/ruby-share-logger-instance-among-module-classes
module Logging
  # This is the magical bit that gets mixed into your classes
  def logger
    Logging.logger
  end

  # Global, memoized, lazy initialized instance of a logger
  def self.logger
    @logger ||= Logger.new(STDOUT)
  end

  def self.included(base)
    base.extend(self)
  end
end

