require './environment.rb'

# Training Part
# get crying face, id:4, and
# tears with joy face, id: 6 to train and classify

# Now training 2015 data
svm = MultiClassSVM.new()
Emo.order(freq: :desc).first(10).last(5).map{|e| e.id}.each do |id|
    emo = Emo.find(id)
    svm.liblinear_ova_train(emo, 20000)
end
