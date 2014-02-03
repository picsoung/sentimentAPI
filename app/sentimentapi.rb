require 'grape'
require 'json'

class SentimentApi < Grape::API
  version 'v1', :using => :header, :vendor => '3scale'
  error_format :json

  rescue_from ArgumentError do |e|
      Rack::Response.new([ "ArgumentError: #{e.message}" ], 500)
    end

  rescue_from NotImplementedError do |e|
      Rack::Response.new([ "NotImplementedError: #{e.message}" ], 500)
    end
  
  resource :words do
    get ':word' do
        {:word => params[:word], :sentiment => "unkown"}.to_json
    end
    
    post ':word' do
      {:word => params[:word], :result => "thinking"}.to_json
    end 
  end
  
  resource :sentences do
    get ':sentence' do
      {:sentence => params[:sentence], :result => "unkown"}.to_json
    end
  end

end
