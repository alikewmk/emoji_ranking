class TweetFeature < ActiveRecord::Base
    belongs_to :tweet
    belongs_to :emo
    serialize :word_ids, Array
    serialize :hashtag_ids, Array
end
