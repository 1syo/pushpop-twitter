require 'spec_helper'

describe Pushpop::Twitter do

  let(:example_tweet) { Twitter::Tweet.new({
    id: 449660889793581056,
    id_str: '449660889793581056',
    user: {
      screen_name: 'dzello'
    }
  }) }

  describe 'follow' do
    it 'follows a user' do
      step = Pushpop::Twitter.new do |last_response|
        follow last_response
      end

      stub_request(:post, "https://api.twitter.com/oauth2/token").
        with(:body => "grant_type=client_credentials")

      stub_request(:get, "https://api.twitter.com/1.1/account/verify_credentials.json?skip_status=true").
        to_return(body: File.read("spec/fixtures/dzello.json"))

      stub_request(:post, "https://api.twitter.com/1.1/users/lookup.json").
        with(:body => {:screen_name => 'dzello'}).
        to_return(body: File.read("spec/fixtures/users.json"))

      stub_request(:get, "https://api.twitter.com/1.1/friends/ids.json?cursor=-1&user_id=45297280").
        to_return(body: File.read("spec/fixtures/ids.json"))

      stub_request(:post, "https://api.twitter.com/1.1/friendships/create.json").
        with(:body => {:user_id => '45297280'}).
        to_return(body: File.read("spec/fixtures/dzello.json"))

      result = step.run('dzello')
      expect(result.first.screen_name).to eq('dzello')
    end
  end

  describe 'favorite' do
    it 'favorites a tweet' do
      step = Pushpop::Twitter.new do |last_response|
        favorite last_response
      end

      stub_request(:post, "https://api.twitter.com/1.1/favorites/create.json").
        with(:body => {:id => '449660889793581056'}).
        to_return(body: File.read("spec/fixtures/status.json"))

      stub_request(:post, "https://api.twitter.com/oauth2/token").
        with(:body => "grant_type=client_credentials")

      result = step.run(example_tweet)
      expect(result.first.id).to eq(449660889793581056)
    end
  end

  describe 'unfavorite' do
    it 'unfavorites a tweet' do
      step = Pushpop::Twitter.new do |last_response|
        unfavorite last_response
      end

      stub_request(:post, "https://api.twitter.com/1.1/favorites/destroy.json").
        with(:body => {:id => '449660889793581056'}).
        to_return(body: File.read("spec/fixtures/status.json"))

      stub_request(:post, "https://api.twitter.com/oauth2/token").
        with(:body => "grant_type=client_credentials")

      result = step.run(example_tweet)
      expect(result.first.id).to eq(449660889793581056)
    end
  end

  describe 'favorites' do
    it 'gets a list of favorites' do
      step = Pushpop::Twitter.new do |last_response|
        favorites
      end

      stub_request(:post, "https://api.twitter.com/oauth2/token").
        with(:body => "grant_type=client_credentials")

      stub_request(:get, "https://api.twitter.com/1.1/favorites/list.json").
        to_return(body: File.read("spec/fixtures/statuses.json"))

      result = step.run
      expect(result.first.id).to eq(449660889793581056)
    end
  end

  describe 'user' do
    it 'gets a user' do
      step = Pushpop::Twitter.new do |last_response|
        user "dzello"
      end

      stub_request(:post, "https://api.twitter.com/oauth2/token").
        with(:body => "grant_type=client_credentials")

      stub_request(:get, "https://api.twitter.com/1.1/users/show.json?screen_name=dzello").
        to_return(body: File.read("spec/fixtures/user.json"))

      result = step.run
      expect(result.id).to eq(45297280)
    end
  end

  describe 'user_timeline' do
    it 'gets a user_timeline' do
      step = Pushpop::Twitter.new do |last_response|
        user_timeline "twitterapi", {count: 2}
      end

      stub_request(:post, "https://api.twitter.com/oauth2/token").
        with(:body => "grant_type=client_credentials")

      stub_request(:get, "https://api.twitter.com/1.1/statuses/user_timeline.json?count=2&screen_name=twitterapi").
        to_return(body: File.read("spec/fixtures/user_timeline.json"))

      result = step.run
      expect(result.first.id).to eq(240859602684612608)
    end
  end
end
