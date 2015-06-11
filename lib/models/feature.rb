class Feature < ActiveRecord::Base
    belongs_to :emo
    belongs_to :dict
    # Label 0: word
    # Label 1: hashtag
end
