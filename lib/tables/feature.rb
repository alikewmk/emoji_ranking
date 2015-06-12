class Feature < ActiveRecord::Base
    # Label 0: word
    # Label 1: hashtag
    belongs_to :emo
    belongs_to :dict
end
