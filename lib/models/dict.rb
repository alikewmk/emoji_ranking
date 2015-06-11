class Dict < ActiveRecord::Base
    # Label 0: word
    # Label 1: hashtag
    has_many :features
end
