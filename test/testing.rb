require './environment.rb'


# data preparation
tweets = Tweet.tweets_2015().first(2000)
emoji_ids = Emo.order(freq: :desc).first(10).map{|e| e.id}
uni_model = UnigramModel.new()


# Evaluate Unigram model
count = 0
right_count = 0
tweets.each_with_index do |tweet, idx|
    p idx
    true_emos = tweet.tweet_features.map(&:emo_id)
    next if (emoji_ids & true_emos) == []
    count += 1
    expected_emos = uni_model.get_rank(tweet).map(&:first)
    right_count += 1 if (true_emos & expected_emos[0..10]) != []
end

p "--------------------"
p count
p right_count

# Evaluate SVM model
# svm = MultiClassSVM.new()
# emoji_ids.each do |id|
#     emo = Emo.find(id)
#     p "testing model " + id.to_s
#     p svm.evaluate_ova_model(emo, 2000, "models/"+id.to_s+"_model")
# end
