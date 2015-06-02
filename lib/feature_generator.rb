require 'tokenizer'
require 'lingua/stemmer'

module FeatureGenerator

    class << self; attr_accessor :tokenizer, :stemmer; end
    self.tokenizer = Tokenizer::Tokenizer.new(:en)
    self.stemmer = Lingua::Stemmer.new(:language => "en")

    # 1.delete unrecognized Unicode char, remove all emoji, keep them in a separate thing
    # 2.remove duplicate emojis in one tweet
    # 3.keep the hashtag word in a separate thing
    # 4.remove @(maybe replace with a symbol?)
    # 5. deal with &lt
    # 6. should I worry about retweet?(RT)
    def self.tokenize(tweet)
        # remove https
        # remove puncutuation
        # remove emoji
        words = tokenizer.tokenize(tweet)
    end

    # ruby stemmer didn't do case fold, so do it your self
    def self.stem(word)
        # case fold
        # stem
        stemmer.stem(word)
    end

    #try 140 vector first
    def self.gen_feats(tweets)
        emojis = []
        words = []
        hastags = []
        # check if emoji in database, if not, create new one
        # check word and hashtag in dictionary, if not, create new one and store id
        # store new feature vector to emoji
    end

end
