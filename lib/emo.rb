class Emo < ActiveRecord::Base
    has_many :features, dependent: :destroy
end
