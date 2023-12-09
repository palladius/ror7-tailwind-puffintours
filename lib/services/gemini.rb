# https://stackoverflow.com/questions/47119729/rails-loading-custom-class-from-lib-folder-in-controller
module Services

  # service = Services::Gemini.new
  # or just use:
  # *  `Services::Gemini.new.random_api_call`
  class Gemini
    # ...
    puts "Prova Gemini in-clas"

    require 'net/http'
    require 'json'

    def gemini_call()
      # TODO
    end

    # todo gemini
    def random_api_call()
      # https://reqres.in/ wow!
      rand_1_12 = rand(1..12)
      url = "https://reqres.in/api/products/#{rand_1_12}"
      spotify_url = 'https://api.spotify.com/v1/search?type=artist&q=tycho'
      uri = URI(url)
      response = Net::HTTP.get(uri)
      if response.code.to_i == 200
        puts "All good - continuing"
      else
        #raise StandardError, "API request failed with code: #{response.code}"
        puts $stderr."API request failed with code: #{response.code}"
        return "API request to #{url} failed with code: #{response.code}"
      end
      response = JSON.parse(response)
#       {"data"=>
#   {"id"=>3,
#    "name"=>"true red",
#    "year"=>2002,
#    "color"=>"#BF1932",
#    "pantone_value"=>"19-1664"},
#  "support"=>
#   {"url"=>"https://reqres.in/#support-heading",
#    "text"=>"To keep ReqRes free, contributions towards server costs are appreciated!"}}
      textual_value =  response['data']['name'] rescue "[Some error: #{$!}]" # response.inspect
      return "This is a real remote API response from #{url}, returning: "" (#{textual_value})"
    end

  end
end


#var xhr = new XMLHttpRequest();
# xhr.open("GET", "https://reqres.in/api/products/3", true);
# xhr.onload = function(){
#     console.log(xhr.responseText);
# };
# xhr.send();

puts "Prova Gemini out-of-class"
