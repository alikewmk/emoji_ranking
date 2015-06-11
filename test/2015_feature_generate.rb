# generate features and dictionary of 2013 data

require './environment.rb'

generator = FeatureGenerator
i = 0
Tweet.tweets_2015().find_each do |tweet|
    p i += 1
    # generator.gen_train(tweet)
    generator.gen_test(tweet)
end
