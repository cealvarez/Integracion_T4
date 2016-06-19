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

  def consultar(city)
      @city = city
      puts 'Empieza el request'
      url = URI("http://api.openweathermap.org/data/2.5/weather?q="+@city+"&APPID=6bdf634eaccfc5088a2d84376170d08b")
      http = Net::HTTP.new(url.host, url.port)
      request = Net::HTTP::Get.new(url)
      request["cache-control"] = 'no-cache'
      request["postman-token"] = '2a2e95da-ba53-61b6-5c6a-a6008d6b830b'
      response = http.request(request)
      @oc_array = JSON.parse(response.body)
      @oc_json = JSON.parse(@oc_array.to_json)
      @datos = @oc_json["weather"][0]["main"]
      resp_json = {:data => @datos, :city => @oc_json["name"]}.to_json
      my_hash = JSON.parse(resp_json)

      if @datos == "Clear"
        @datos = "Despejado"
      elsif @datos == "Clouds"
        @datos = "Nublado"
      elsif @datos == "Rain"
        @datos = "Lluvioso"
      end    
      texto = "El tiempo en "+@city+": "+@datos
      return texto
  end

Slack.configure do |config|
      config.token = 'xoxb-52218480496-tOzPH9igsQHioX08V2JTTqJ0'
    end

    client = Slack::RealTime::Client.new

    client.on :hello do
      puts 'Successfully connected.'
    end

    client.on :message do |data|
      case data['text']
      when 'bot hi' then
        client.message channel: data['channel'], text: "Hi <@#{data['user']}>!"
      when /(clima|tiempo)\s(en\s|).*/ then
        indice = data['text'].rindex('en ')
        if indice.nil?
          indice = 0
          client.message channel: data['channel'], text: "<@#{data['user']}> quieres el clima de alguna ciudad en particular?"
        else
          ciudad = data['text'][indice + 3, data['text'].length]
          client.message channel: data['channel'], text: "<@#{data['user']}>, " + consultar(ciudad)
        end
        
      when /^bot.([j][i]){2,}/ then
        client.message channel: data['channel'], text: "hahaha <@#{data['user']}>"
      when /^bot/ then
        client.message channel: data['channel'], text: "Lo siento <@#{data['user']}>, no te entiendo"
      when /(adios|chao|hasta pronto)/ then
        client.message channel: data['channel'], text: "Gracias por preferirme"
        client.stop!
      end
    end