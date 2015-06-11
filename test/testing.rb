require './environment.rb'

# Testing Part
# get crying face, id:4, and
# tears with joy face, id: 6 to train and classify

svm = MultiClassSVM.new()
emo = Emo.find(4)
p svm.evaluate_ova_model(emo, 10000, "models/4_model")
emo = Emo.find(6)
p svm.evaluate_ova_model(emo, 10000, "models/6_model")
