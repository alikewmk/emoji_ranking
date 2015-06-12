# script solely for truncate table

require './environment.rb'

ActiveRecord::Base.connection.execute("truncate emos")
ActiveRecord::Base.connection.execute("truncate features")
ActiveRecord::Base.connection.execute("truncate dicts")
ActiveRecord::Base.connection.execute("truncate tweet_features")
