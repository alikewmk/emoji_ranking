require 'libsvm'
require 'liblinear'
require 'logger'

# should the tweet_feature be distinct in tweet id?
#
class MultiClassSVM

    attr_accessor :logger

    def initialize()
        $stdout.sync = true
        @logger = Logger.new $stdout
        @logger.level = Logger::DEBUG
    end

    # one vs all approach
    # TODO: maybe try one vs one?
    def liblinear_ova_train(emo)
        param = Liblinear::Parameter.new
        # might need to change this
        param.solver_type = Liblinear::L2R_L2LOSS_SVC_DUAL
        param.C = 1
        bias    = 0.5

        @logger.debug("\n-----------------")
        @logger.debug("start handling emo " + emo.id.to_s)

        @logger.debug("generating training data...")
        labels, training_data = gen_ova_data(emo)

        @logger.debug("training model...")
        prob = Liblinear::Problem.new(labels, training_data, bias)
        linear_model = Liblinear::Model.new(prob, param)

        @logger.debug("saving model...")
        linear_model.save("models/"+ emo.id.to_s + "_model")
    end

    def gen_ova_data(emo)
        len_dict = Dict.count
        dict_feat = Array.new(len_dict){0}

        labels = []
        data = []

        Tweet.find_each.with_index do |tweet, idx|

            # show current process
            @logger.debug(idx.to_s) if idx%1000 == 0

            # TODO: maybe choose the one with less frequent emo?
            feat     = tweet.tweet_features.first

            next if feat.nil?

            feat_val = feat.word_ids + feat.hashtag_ids

            next if feat_val == []

            # label 1 indicate feature match label
            if feat.emo_id == emo.id
                labels << 1
            else
                labels << 0
            end

            dict_feat = Array.new(len_dict){0}
            feat_val.each{|i| dict_feat[i-1] = 1 }
            data << dict_feat
        end

        return labels, data
    end

    def evaluate_ova_model(emo, data_num, model_file)

        l_model = Liblinear::Model.new(model_file)
        labels, testing_data = gen_ova_data(emo, data_num)

        result = []

        testing_data.each_with_index do |item, idx|
            p idx
            result << l_model.predict(item)
        end

        count = 0
        true_count = 0
        true_true_count = 0
        labels.each_with_index do |l, i|

            if l == 1
                true_count += 1
                true_true_count += 1 if l == result[i]
            end

            count += 1 if l == result[i]

        end

        return count, data_num, true_true_count, true_count
    end

    # add cross validation to Liblinear SVM

    ###################################################################
    #######################  deprecated  ##############################
    ###################################################################

    # libsvm approach, take too long to train on large scale data
    def libsvm_train()
        ### Train
        problem = Libsvm::Problem.new
        parameter = Libsvm::SvmParameter.new

        parameter.cache_size = 1000 # in megabytes
        parameter.eps = 0.1
        parameter.c   = 100
        parameter.kernel_type = Libsvm::KernelType.const_get(:LINEAR)

        p "get features"

        len_dict = Dict.count

        # Train classifier using training set
        # one vs all strategy
        one_feats = Emo.find(2).tweet_features.order(:id).limit(1000).pluck(:word_ids).reject{|i| i == []}
        all_feats = TweetFeature.order(:id).where("emo_id != 2").limit(1000).pluck(:word_ids).reject{|i| i == []}

        feats = one_feats + all_feats
        training_data = []
        feats.each_with_index do |f, idx|
            p idx
            ary = Array.new(len_dict){0}
            f.each{|i| ary[i-1] = 1}
            training_data << Libsvm::Node.features(ary)
        end

        target = Array.new(one_feats.length){0} + Array.new(all_feats.length){1}

        # training_data = training_feats.map{|w| Libsvm::Node.features(w)}
        problem.set_examples(target, training_data)

        p 'training...'
        # # training model is the most time consuming part
        self.model = Libsvm::Model.train(problem, parameter)

        p "testing..."
        ### Test
        # Notice that features are always wrapped in Node
        feats = Emo.find(4).tweet_features.order(:id).offset(1000).limit(100).pluck(:word_ids).reject{|i| i == []}
        testing_feats = []
        feats.each_with_index do |f, idx|
            p idx
            ary = Array.new(len_dict){0}
            f.each{|i| ary[i-1] = 1}
            testing_feats << ary
        end

        result = []
        testing_feats.each do |f|
            test_features = Libsvm::Node.features(f)
            result << model.predict(test_features)
        end
        p result
    end

    # multi class approach, not working, never fit the data
    def liblinear_mc_train(features)
        param = Liblinear::Parameter.new
        # might need to change this
        param.solver_type = Liblinear::L2R_LR
        param.C = 100
        bias = 0.5

        labels, training_data = gen_mc_train(features)

        prob = Liblinear::Problem.new(labels, training_data, bias)
        p "training"
        self.linear_model = Liblinear::Model.new(prob, param)

        self.linear_model.predict([1,2,3])

        # linear_model.save(file_name)
        # linear_model.predict([])
    end

    def gen_mc_train(features)
        len_dict = Dict.count

        training_data = []
        labels = []

        features.each do |f|
            p f.id
            feat = f.word_ids
            if feat != []
                ary = Array.new(len_dict){0}
                feat.each{|i| ary[i-1] = 1}
                training_data << ary
                labels << f.emo_id
            end
        end

        return labels, training_data
    end
end
