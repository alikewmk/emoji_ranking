require 'tokenizer'
require 'lingua/stemmer'
require 'stopwords'

module FeatureGenerator

    class << self; attr_accessor :tokenizer, :stemmer, :stop_filter; end
    self.tokenizer = Tokenizer::Tokenizer.new(:en)
    self.stemmer   = Lingua::Stemmer.new(:language => "en")
    self.stop_filter = Stopwords::Snowball::Filter.new("en")

    def self.tokenize_and_stem(tweet)

        new_tweet = ""
        hashtags = []
        words = []

        # word level
        tweet.split(" ").each do |word|
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

            # separate hashtag and word
            if word =~ /#/
                hashtags << word.gsub!(/[^a-z]/, "")
            else
                new_tweet << " " + word
            end
        end

        # char level, only use alphabets and blank
        new_tweet.gsub!(/[^a-z ]/, " ")

        # replace all white space char with blank
        # remove whitespace char at front and end of the string
        new_tweet.gsub!(/\s+/, " ")
        new_tweet.strip!() if !new_tweet.nil?

        # stem words, remove stop words
        words = new_tweet.split(" ").reject{|word| stop_filter.stopword? word }.map{|word| stemmer.stem(word) }

        # Extract emojis from tweets, one of a type
        # Insert in database if emoji is new
        EmojiData.scan(tweet).uniq.each do |e|
            # incr emoji count
            emo = Emo.find_by_text(e.render)
            if !emo
                emo = Emo.create(text: e.render, unicode: e.unified, name: e.name.downcase, short_name: e.short_name.gsub("_", " "), freq: 1)
            else
                emo.increment!(:freq)
            end

            # increment word count
            words.each do |w|
                # increment word in dict
                word = Dict.where(label: 0).find_by_word(w)
                if word
                    word.increment!(:freq)
                else
                    word = Dict.create(label: 0, word: w, freq: 1)
                end

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

                # increment word in feature
                feature = emo.features.where(label: 1).find_by_word(w)
                if feature
                    feature.increment!(:freq)
                else
                    emo.features.create(label: 1, word: w, freq: 1, dict_id: word.id)
                end
            end
        end
    end

    #### try 140 vector first, failed
    # def self.gen_char_feats()
    #     i = 0
    #     Tweet.find_each do |t|
    #         p i+=1
    #         tweet = t.text
    #         # get emojis, each type one feature
    #         # so a tweet with duplicate emoji will be unique to one
    #         emojis = EmojiData.scan(tweet).map(&:render).uniq

    #         emojis.each do |e|
    #             fea_vec = Array.new(140){0}
    #             tweet.split("").each_with_index do |char, i|
    #                 word_in_dict = Dict.find_by_word(char) || Dict.create(word: char, freq: 1)
    #                 # add new feature
    #                 fea_vec[i] = word_in_dict.id
    #             end

    #             emoji = Emo.find_by_text(e) || Emo.create(word: e, emoji_unicode: EmojiData.char_to_unified(e))
    #             emoji.features.create(words: fea_vec)
    #         end
    #     end
    # end
end
