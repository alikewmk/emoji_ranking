class Emo < ActiveRecord::Base
    has_many :features, dependent: :destroy
    has_many :tweet_features
end
