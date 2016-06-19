require 'slack-ruby-client'
require 'uri'
require 'net/http'

  def juegos(game)
    url = URI("https://videogamesrating.p.mashape.com/get.php?count=5&game="+game)
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    request = Net::HTTP::Get.new(url)
    request["x-mashape-key"] = 'zfEvpNOcb8mshz7Xeco6wIN9RPdBp160CByjsn6ct68ijin7So'
    request["accept"] = 'application/json'
    request["cache-control"] = 'no-cache'
    request["postman-token"] = '88bc0b58-c8ce-a7ca-db7c-932eaa70cbc9'
    response = http.request(request)
    @oc_array = JSON.parse(response.body)
    texto = ''
    @oc_array.each do |game|
    	indice = game['short_description'].index('-')
    	fecha = game['short_description'][0 , indice - 1]
    	texto += 'Título: ' + game['title'] + "\ncalificación: " + game['score'] + "\nfecha de lanzamiento: " + fecha + "\nDisponible en: "
    	game['platforms'].each do |key, value|
    		texto += value + ' '
    	end
    	texto += "\n\n"
    end
    puts texto
  end

juegos('Resident evil')