require './environment.rb'

# svm = SVM.new()
# e_y = svm.train()

# y = Feature.order('id').where("emo_id != 1").offset(11000).limit(100).pluck(:emo_id)

# p y.zip(e_y).map{|i| i[0] == i[1]}.reject{|i| i== false}.count

# # just for fun
# test_features = Libsvm::Node.features(["I", " ", "f", "e", "e", "l", " ", "v", "e", "r", "y", " ", "s", "a", "d", " ", "t", "o", "d", "a", "y"])
# p svm.model.predict(test_features)
# p svm.model.support_vectors_count


# test data
# test tokenize
generator = FeatureGenerator
i = 0
Tweet.find_each do |tweet|
    p i += 1
    generator.tokenize_and_stem(tweet.text)
end
