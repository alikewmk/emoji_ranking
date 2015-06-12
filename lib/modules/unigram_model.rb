# basic unigram model

class UnigramModel

    def get_feature(tweet)
        t = tweet.tweet_features.first
        return t.word_ids + t.hashtag_ids
    end

    def get_rank(tweet)
        feats = get_feature(tweet)
        len_feats = feats.length()
        words_emo_ids = []
        feats.each_with_index do |word_id, idx|
            emo_ids = Feature.where(dict_id: word_id).pluck(:emo_id)
            if idx == 0
                words_emo_ids = emo_ids
            else
                words_emo_ids &= emo_ids
            end
        end

        # entropy is -sum{log(C(word_given_emo_id_give_dict_id)/C(word_given_emo_id)}/N
        emo_entropies = []
        words_emo_ids.each do |emo_id|
            log_prob = 0
            feats.each do |word_id|
                log_prob += Math.log(Feature.where(emo_id: emo_id, dict_id: word_id).first.freq.to_f/Feature.where(emo_id: emo_id).sum(:freq))
            end
            cross_entropy = -(log_prob/len_feats)
            emo_entropies << [emo_id, cross_entropy, Emo.find(emo_id).text]
        end

        return emo_entropies.sort_by{|en| en[1]}
    end
end
# first get features from tweet
# use 796 unigram models to calculate probablity of each emoji
# rank the probablities
# then gets labels(emojis) from tweet
# compare rank with labels
