require 'rubygems'
require 'active_record'
require 'mysql2'
# require 'logger'
require 'yaml'
require 'twitter'
require 'emoji_data'

$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__))) unless $LOAD_PATH.include?(File.expand_path(File.dirname(__FILE__)))

require 'lib/tweet'
require 'lib/emo'
require 'lib/feature'
require 'lib/dict'
require 'lib/svm'
require 'lib/feature_generator'

# ActiveRecord::Base.logger = Logger.new('debug.log')
configuration = YAML::load(IO.read('config/database.yml'))
ActiveRecord::Base.establish_connection(configuration['development'])
