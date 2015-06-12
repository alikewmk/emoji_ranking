require './environment.rb'

TRAINING_NUM = 20000

# Now training 2015 data
Emo.order(freq: :desc).first(10).map{|e| e.id}.each do |id|
    emo = Emo.find(id)
    MultiClassSVM.liblinear_ova_train(emo, TRAINING_NUM)
end
