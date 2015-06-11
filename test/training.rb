require './environment.rb'

# Training Part
# get crying face, id:4, and
# tears with joy face, id: 6 to train and classify

svm = MultiClassSVM.new()
emo = Emo.find(4)
svm.liblinear_ova_train(emo)
emo = Emo.find(6)
svm.liblinear_ova_train(emo)


# Now training 2015 data
