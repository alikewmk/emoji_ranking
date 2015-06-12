# generate features and dictionary of 2013 data

require './environment.rb'

Tweet.send("tweets_"+ARGV[0]).find_each.with_index do |tweet, i|
    p i if i%1000 = 0
    FeatureGenerator.send("gen_" + ARGV[1], tweet)
end
