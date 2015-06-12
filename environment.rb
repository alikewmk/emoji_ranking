# require this file to initialize develop environment

require 'rubygems'
require 'active_record'
require 'mysql2'
require 'yaml'
require 'twitter'
require 'emoji_data'

# add directory to default ruby file load path
$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__))) unless $LOAD_PATH.include?(File.expand_path(File.dirname(__FILE__)))

# data tables
require 'lib/tables/tweet'
require 'lib/tables/emo'
require 'lib/tables/feature'
require 'lib/tables/dict'
require 'lib/tables/tweet_feature'

# helpers and modules
require 'lib/modules/multi_class_svm'
require 'lib/modules/feature_generator'
require 'lib/modules/unigram_model'

# connect to database
configuration = YAML::load(IO.read('config/database.yml'))
ActiveRecord::Base.establish_connection(configuration['development'])
