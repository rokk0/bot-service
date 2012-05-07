$LOG_PATH = File.expand_path('../log/',File.dirname(__FILE__))

require_relative 'core/logger'
require_relative 'core/scheduler'
require_relative 'core/vk'

require_relative 'bots/group'
require_relative 'bots/discussion'

require_relative 'workers/bot'

# TODO: rename this file to some fancy shit
# TODO: make class - wrapper so we don't have to call Resque directly
