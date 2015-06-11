require 'lingua/stemmer'
require 'stopwords'

module FeatureGenerator

    class << self; attr_accessor :stemmer, :stop_filter; end
    self.stemmer   = Lingua::Stemmer.new(:language => "en")
    self.stop_filter = Stopwords::Snowball::Filter.new("en")

    def self.tokenize_and_stem(tweet)

        hashtags = []
        words = []

        # word level
        tweet.text.split(" ").each do |word|
            # case fold word
            word = word.downcase
            # remove https
            next if word =~ /^http/
            # remove @
            next if word =~ /@/
            # remove html entities
            next if word =~ /(&nbsp|&lt|&gt|&amp|&cent|&pound|&yen|&euro|&copy|&reg)/
            # remove retweet sign
            next if word =~ /^rt$/
            # remove numbers or words with numbers inside them
            next if word =~ /[0-9]+/

            # TODO: maybe dealing with non-dictionary words?(remove them)

            # trim irregular words
            # if word length >= 6
            if word.length > 5
                # continuous_repeat_of_char > 3, trim repeat alphabet to length 2, e.g: "yeeeees"
                if word =~ /([a-z])\1\1+/
                    # non greedy match here
                    word.gsub!(/([a-z]+?)\1+/, '\1\1')
                end
                # if there are repeat pattern in words, remove dup pattern, e.g: "lolol"
                # non greedy match here
                word.gsub!(/([a-z][a-z]+?)\1/, '\1')
            end

            # separate hashtag and word
            if word =~ /#/
                hashtags << word.gsub!(/[^a-z]/, "")
            else
                # remove stop words, only use alphabets and blank
                word.gsub!(/[^a-z]/, "")
                next if stop_filter.stopword? word
                # stem words, remove stop words again
                if !word.nil? && word.length > 1 && !(stop_filter.stopword? word)
                    words << stemmer.stem(word)
                end
            end
        end

        return words, hashtags
    end

    def self.gen_count(e, words, hashtags)
        # incr emoji count
        emo = Emo.find_by_unicode(e.unified)
        if !emo
            # Insert in database if emoji is new
            emo = Emo.create(text: e.render, unicode: e.unified, name: e.name.downcase, short_name: e.short_name.gsub("_", " "), freq: 1)
        else
            emo.increment!(:freq)
        end

        word_ids = []
        hashtag_ids = []
        # increment word count
        words.each do |w|
            # increment word in dict
            word = Dict.where(label: 0).find_by_word(w)
            if word
                word.increment!(:freq)
            else
                word = Dict.create(label: 0, word: w, freq: 1)
            end

            word_ids << word.id

            # increment word in feature
            feature = emo.features.where(label: 0).find_by_word(w)
            if feature
                feature.increment!(:freq)
            else
                emo.features.create(label: 0, word: w, freq: 1, dict_id: word.id)
            end
        end

        # increment hashtag count
        hashtags.each do |w|
            # increment word in dict
            word = Dict.where(label: 1).find_by_word(w)
            if word
                word.increment!(:freq)
            else
                word = Dict.create(label: 1, word: w, freq: 1)
            end

            hashtag_ids << word.id

            # increment word in feature
            feature = emo.features.where(label: 1).find_by_word(w)
            if feature
                feature.increment!(:freq)
            else
                emo.features.create(label: 1, word: w, freq: 1, dict_id: word.id)
            end
        end

        return emo.id, word_ids, hashtag_ids
    end

    def self.gen_train(tweet)
        # Extract emojis from tweets, one of a type
        # generate feature for tweet

        words, hashtags = tokenize_and_stem(tweet)

        EmojiData.scan(tweet.text).uniq.each do |e|
            # generate dictionary table, emo table, and count numbers
            emo_id, word_ids, hashtag_ids = gen_count(e, words, hashtags)

            # generate tweet features
            tweet.tweet_features.create(emo_id: emo_id, word_ids: word_ids, hashtag_ids: hashtag_ids)
        end
    end

    def self.gen_test(tweet)
        words, hashtags = tokenize_and_stem(tweet)

        EmojiData.scan(tweet.text).uniq.each do |e|
            emo = Emo.find_by_unicode(e.unified)
            next if !emo

            word_ids = []
            hashtag_ids = []

            words.each do |w|
                word = Dict.where(label: 0).find_by_word(w)
                next if !word
                word_ids << word.id
            end

            hashtags.each do |w|
                word = Dict.where(label: 1).find_by_word(w)
                next if !word
                hashtag_ids << word.id
            end

            # generate tweet features
            tweet.tweet_features.create(emo_id: emo.id, word_ids: word_ids, hashtag_ids: hashtag_ids)

        end
    end
end
