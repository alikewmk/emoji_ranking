require 'libsvm'

class SVM

    attr_accessor :model

    def train()
        ### Train
        problem = Libsvm::Problem.new
        parameter = Libsvm::SvmParameter.new

        parameter.cache_size = 10 # in megabytes
        parameter.eps = 0.01
        parameter.c   = 100
        parameter.kernel_type = Libsvm::KernelType.const_get(:LINEAR)

        p "get features"

        # Train classifier using training set
        # the data structure here is like [label1, label2..] [Node1, Node2..]
        # Set the target id as the id of the emoji you currently cared about
        feats = Feature.order('id').where("emo_id != 1").limit(11000)
        training_data = feats.pluck(:words).map{|w| Libsvm::Node.features(w)}
        problem.set_examples(feats.pluck(:emo_id), training_data)

        # training model is the most time consuming part
        self.model = Libsvm::Model.train(problem, parameter)

        p 'training...'

        ### Test
        # Notice that features are always wrapped in Node
        ary = []
        Feature.order('id').where("emo_id != 1").offset(11000).limit(100).each do |f|
            arry = f.words
            test_features = Libsvm::Node.features(arry)
            ary << model.predict(test_features)
        end

        p ary
    end
end
