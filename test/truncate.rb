require './environment.rb'


ActiveRecord::Base.connection.execute("truncate emos")
ActiveRecord::Base.connection.execute("truncate features")
ActiveRecord::Base.connection.execute("truncate dicts")
