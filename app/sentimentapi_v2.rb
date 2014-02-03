require 'rubygems'
require 'grape'
require 'json'
require '3scale/client'
require "#{File.dirname(__FILE__)}/analyzer"

module JSendSuccessFormatter
  def self.call object, env
    { :status => 'success', :data => object}.to_json
  end
end

module JSendErrorFormatter
  def self.call message, backtrace, options, env
    # This uses convention that a error! with a Hash param is a jsend "fail", otherwise we present an "error"
    if message.is_a?(Hash)
      { :status => 'fail', :data => message }.to_json
    else
      { :status => 'error', :message => message }.to_json
    end
  end
end

class SentimentApiV2 < Grape::API
  version 'v2', :using => :path, :vendor => '3scale'
  #error_format :json
  formatter :json, JSendSuccessFormatter
  error_formatter :json, JSendErrorFormatter

  $client = ThreeScale::Client.new(:provider_key => "YOUR 3SCALE PROVIDER KEY")
  
  #Sentiment Logic component
  @@the_logic = Analyzer.new

  helpers do
    def authenticate!
      response = $client.authrep(:app_id => params[:app_id], :app_key => params[:app_key], :service_id => "2555417703952")
      error!('403 Unauthorized', 403) unless response.success?
    end

    def report!(method_name='hits', usage_value=1)      
      response = $client.report({:app_id => params[:app_id],  :usage => {method_name => usage_value}})
      error!('505 Reporting Error', 505) unless response.success?
    end
  end
  
  resource :words do
    get ':word' do
      authenticate!
      report!('word/get', 1)
      @@the_logic.word(params[:word])
    end
    
    post ':word' do
      authenticate!
      report!('word/post', 1)
      @@the_logic.add_word(params[:word],params[:value])
    end 
  end
  
  resource :sentences do
    get ':sentence' do
      authenticate!
      report!('sentence/get', 1)
      @@the_logic.sentence(params[:sentence])
    end
  end

end
