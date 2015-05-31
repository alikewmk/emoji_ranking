require 'zlib'
require 'json'

class Tweet < ActiveRecord::Base
    validates :text, :source, :create_time, presence: true

    # DATA_DIR = '~/Downloads/ir_project/data/*.gz'
    DATA_DIR = "/Users/wmk/Dropbox/ohsu_homeworks/IR/Project/twitter_emoji/data/*.gz"

    def self.pull_2013_data()
        i = 0
        Dir.glob(DATA_DIR).each do |file|
            Zlib::GzipReader.open(file) do |gz|
                gz.each_line do |line|
                    parser = JSON.parse(line.strip)
                    # currently only extract data in English
                    if parser['lang'] == 'en'
                        if EmojiData.scan(parser['text']) != []
                            Tweet.create(text: parser['text'].force_encoding("UTF-8"), source: parser['source'], create_time: parser['created_at'])
                            i += 1
                            print i.to_s + "\n"
                        end
                    end
                end
            end
        end
    end

    def self.pull_2015_data()
        client = Twitter::Streaming::Client.new do |config|
          config.consumer_key        = "zmVbzavTCzNaZrtSIcIELOIPA"
          config.consumer_secret     = "HdftzlPdeSI2UH6rsNXP8PcgZHY5m5zTY7HM07TQ87GREyS6w9"
          config.access_token        = "145053175-4B6cWR15HkALu82x1GZD0zhXmnoAFCNKqC8mMvg4"
          config.access_token_secret = "gsXtrHWF0tI90kH6Cgzo0DyOMKhjHLsDqsiM5By67OYIX"
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
end
