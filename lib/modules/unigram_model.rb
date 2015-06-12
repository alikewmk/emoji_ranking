# basic unigram model
require 'set'

module UnigramModel

    def self.get_feature(tweet)
        t = tweet.tweet_features.first
        return t.word_ids + t.hashtag_ids
    end

    # rank word by entropy
    def self.get_rank(tweet)

        # get words and hashtags sequence
        feats = get_feature(tweet)
        len_feats = feats.length()

        # get emos that might appear with word
        words_emo_ids = []
        feats.each_with_index do |word_id, idx|
            emo_ids = Feature.where(dict_id: word_id).pluck(:emo_id)
            if idx == 0
                words_emo_ids = Set.new(emo_ids)
            else
                words_emo_ids + emo_ids
            end
        end

        # entropy is sum{-log(C(word_given_emo_id_give_dict_id)/C(word_given_emo_id)}/N
        emo_entropies = []
        words_emo_ids.each do |emo_id|

            log_prob = 0

            feats.each do |word_id|

                word_given_emo = Feature.where(emo_id: emo_id, dict_id: word_id).first
                if word_given_emo.nil?   # hoarse smooth
                    word_given_emo = 10**-5
                else
                    word_given_emo = word_given_emo.freq.to_f
                end

                word_under_emo = Feature.where(emo_id: emo_id).sum(:freq)

                # negative log here
                log_prob -= Math.log(word_given_emo/word_under_emo)
            end

            cross_entropy = log_prob/len_feats
            emo_entropies << [emo_id, cross_entropy] #, Emo.find(emo_id).text]
        end

        return emo_entropies.sort_by{ |en| en[1] }
    end
end
