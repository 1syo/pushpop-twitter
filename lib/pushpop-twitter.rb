require 'pushpop'
require 'twitter'

module Pushpop

  class Twitter < Step

    PLUGIN_NAME = 'twitter'

    Pushpop::Job.register_plugin(PLUGIN_NAME, self)

    def initialize(*args)
      super
      @options = {}
      @twitter = ::Twitter::REST::Client.new do |config|
        config.consumer_key        = ENV['TWITTER_CONSUMER_KEY']
        config.consumer_secret     = ENV['TWITTER_CONSUMER_SECRET']
        config.access_token        = ENV['TWITTER_OAUTH_TOKEN']
        config.access_token_secret = ENV['TWITTER_OAUTH_SECRET']
      end
    end

    def run(last_response=nil, step_responses=nil)

      self.configure(last_response, step_responses)

      begin

        case @command
        when 'follow'
          @twitter.follow @users, @options
        when 'favorite'
          @twitter.favorite @tweets, @options
        when 'unfavorite'
          @twitter.unfavorite @tweets, @options
        when 'favorites'
          @twitter.favorites @options
        when 'user'
          @twitter.user @id_param, @options
        when 'user_timeline'
          @twitter.user_timeline @id_param, @options
        else
          raise 'No command specified!'
        end

      rescue => e
        puts "Twitter command #{@command} failed!"
        puts e.message
      end

    end

    def favorites(options={})
      @command = 'favorites'
      @options = options
    end

    def follow(users, options={})
      @command = 'follow'
      @users = users
      @options = options
    end

    # param tweet, tweet-sized JSON
    def favorite(tweets, options={})
      @command = 'favorite'
      @tweets = tweets
      @options = options
    end

    def unfavorite(tweets, options={})
      @command = 'unfavorite'
      @tweets = tweets
      @options = options
    end

    def user(id_param, options={})
      @command = 'user'
      @id_param = id_param
      @options = options
    end

    def user_timeline(id_param, options={})
      @command = 'user_timeline'
      @id_param = id_param
      @options = options
    end

    def configure(last_response=nil, step_responses=nil)
      self.instance_exec(last_response, step_responses, &block)
    end

  end

end
