require 'twitter'
require 'zlib'
require 'json'

class Tweet < ActiveRecord::Base
    validates :text, :source, :create_time, presence: true
    has_many :tweet_features

    DATA_DIR = "/Users/wmk/Dropbox/ohsu_homeworks/IR/Project/twitter_emoji/data/*.gz"
    DATE = Date.new(2014,1,1).to_time

    def self.pull_data(data_num)
        i = 0
        Dir.glob(DATA_DIR).each do |file|
            Zlib::GzipReader.open(file) do |gz|
                gz.each_line do |line|
                    parser = JSON.parse(line.strip)
                    # currently only extract data in English
                    if parser['lang'] == 'en'
                        if EmojiData.scan(parser['text']) != []
                            p parser['text'].force_encoding("UTF-8")
                            Tweet.create(text: parser['text'].force_encoding("UTF-8"), source: parser['source'], create_time: parser['created_at'])
                            i += 1
                            print i.to_s + "\n"
                            return 0 if i == data_num
                        end
                    end
                end
            end
        end
    end

    # pull data from local computer
    def self.pull_2015_data()
        client = Twitter::Streaming::Client.new do |config|
          config.consumer_key        = "XXX"
          config.consumer_secret     = "XXX"
          config.access_token        = "XXX"
          config.access_token_secret = "XXX"
        end

        i = 0
        client.sample({language: 'en'}) do |object|
            if object.is_a?(Twitter::Tweet)
                if EmojiData.scan(object.text) != []
                    Tweet.create(text: object.text, source: object.source, create_time: Time.now)
                    i += 1
                    print i.to_s + "\n"
                end
            end
        end
    end

    # get 2013 tweets collection
    def self.tweets_2013()
        Tweet.where("create_time < :date", {date: DATE})
    end

    # get 2015 tweets collection
    def self.tweets_2015()
        Tweet.where("create_time > :date", {date: DATE})
    end
end
