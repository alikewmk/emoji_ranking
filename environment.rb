require 'rubygems'
require 'active_record'
require 'mysql2'
# require 'logger'
require 'yaml'
require 'twitter'
require 'emoji_data'

$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__))) unless $LOAD_PATH.include?(File.expand_path(File.dirname(__FILE__)))

# data models
require 'lib/models/tweet'
require 'lib/models/emo'
require 'lib/models/feature'
require 'lib/models/dict'
require 'lib/models/tweet_feature'

# helpers and modules
require 'lib/modules/multi_class_svm'
require 'lib/modules/feature_generator'
require 'lib/modules/unigram_model'

# connect to database
# ActiveRecord::Base.logger = Logger.new('debug.log')
configuration = YAML::load(IO.read('config/database.yml'))
ActiveRecord::Base.establish_connection(configuration['development'])
