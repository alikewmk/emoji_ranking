require './environment.rb'
require 'set'

TEST_NUM = 2000

# data preparation
tweets = Tweet.tweets_2015().first(TEST_NUM)
emoji_ids = Set.new(Emo.order(freq: :desc).first(10).map{|e| e.id })

# # Evaluate Unigram model
uni_model = UnigramModel.new()
count = 0
right_count = 0
tweets.each_with_index do |tweet, idx|
    p idx if idx%1000 == 0

    feature = tweet.tweet_features.first
    next if feature.nil?
    next if (feature.word_ids + feature.hashtag_ids) == []
    true_emo = feature.emo_id
    next if !emoji_ids.include?(true_emo)

    count += 1
    expected_emo = uni_model.get_rank(tweet).map(&:first)[0]
    right_count += 1 if true_emo == expected_emo
end

p "--------------------"
p count
p right_count

# Evaluate SVM model
svm = MultiClassSVM.new()
emoji_ids.each do |id|
    emo = Emo.find(id)
    p "testing model " + id.to_s
    p svm.evaluate_ova_model(emo, TEST_NUM, "models/"+id.to_s+"_model")
end
