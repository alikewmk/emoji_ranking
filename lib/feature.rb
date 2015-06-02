class Feature < ActiveRecord::Base
    belongs_to :emo
    serialize :words, Array
    serialize :hashtags, Array
end
