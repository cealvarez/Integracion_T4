require 'uri'
require 'net/http'
require 'slack-ruby-client'

class ApisController < ApplicationController

  # GET /apis
  # GET /apis.json
  def index
    @apis = Api.all
  end

  def consultar(city)
      @city = city
      weathertok = ENV["WEATHER_TOKEN"]
      url = URI("http://api.openweathermap.org/data/2.5/weather?q="+@city+"&APPID="+weathertok)
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
      texto = "El clima en "+@city+": "+@datos
      return texto
  end

  def juegos(game)
    url = URI("https://videogamesrating.p.mashape.com/get.php?count=5&game="+game)
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    request = Net::HTTP::Get.new(url)
    gamestok = ENV["GAMES_TOKEN"].to_s
    request["x-mashape-key"] = gamestok
    request["accept"] = 'application/json'
    request["cache-control"] = 'no-cache'
    request["postman-token"] = '88bc0b58-c8ce-a7ca-db7c-932eaa70cbc9'
    response = http.request(request)
    puts response.read_body
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
    return texto
  end

  def show
    Slack.configure do |config|
      config.token = ENV["BOT_TOKEN"]
    end

    client = Slack::RealTime::Client.new

    client.on :hello do
      puts 'Successfully connected.'
    end

    client.on :message do |data|
      case data['text']
      when '/hola|hi/' then
        client.message channel: data['channel'], text: "Hola <@#{data['user']}>!"

      when /(clima|tiempo)\s(en\s|).*/ then
        indice = data['text'].rindex('en ')
        if indice.nil?
          indice = 0
          client.message channel: data['channel'], text: "<@#{data['user']}> quieres el clima de alguna ciudad en particular?"
        else
          ciudad = data['text'][indice + 3, data['text'].length]
          client.message channel: data['channel'], text: "<@#{data['user']}>, " + consultar(ciudad)
        end

      when /(((Información|Info|Informacion|info|informacion|información|detalles|calificación|calificacion|saber)(|.*juego)))/ then
        indice = data['text'].rindex('juego ')
        if indice.nil?
          indice = data['text'].index('de ')
          if indice.nil?
            client.message channel: data['channel'], text: "<@#{data['user']}> quieres información de algún JUEGO en particular?"
          else
            j = data['text'][indice + 3, data['text'].length]
            client.message channel: data['channel'], text: "<@#{data['user']}>, aquí te presento una lista de juegos:\n" + juegos(j)
          end
        else
          j = data['text'][indice + 6, data['text'].length]
          client.message channel: data['channel'], text: "<@#{data['user']}>, aquí te presento una lista de juegos:\n" + juegos(j)
        end

      when /(juego)/ then
        client.message channel: data['channel'], text: "<@#{data['user']}> quieres información de algún JUEGO en particular?"
        
      when /^bot.([j][i]){2,}/ then
        client.message channel: data['channel'], text: "hahaha <@#{data['user']}>"
      when /^bot/ then
        client.message channel: data['channel'], text: "Lo siento <@#{data['user']}>, no te entiendo"
      when /(adios|chao|hasta pronto)/ then
        client.message channel: data['channel'], text: "Gracias por preferirme"
        client.stop!
      end
    end
    client.start!
    #client.stop!
  end

  def close
     Slack.configure do |config|
      config.token = ENV["BOT_TOKEN"]
    end
    client = Slack::RealTime::Client.web_client
    if client.started?
      client.stop!
    end
  end

  # GET /apis/new
  def new
    @api = Api.new
  end

  # GET /apis/1/edit
  def edit
  end

  # POST /apis
  # POST /apis.json
  def create
    @api = Api.new(api_params)

    respond_to do |format|
      if @api.save
        format.html { redirect_to @api, notice: 'Api was successfully created.' }
        format.json { render :show, status: :created, location: @api }
      else
        format.html { render :new }
        format.json { render json: @api.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /apis/1
  # PATCH/PUT /apis/1.json
  def update
    respond_to do |format|
      if @api.update(api_params)
        format.html { redirect_to @api, notice: 'Api was successfully updated.' }
        format.json { render :show, status: :ok, location: @api }
      else
        format.html { render :edit }
        format.json { render json: @api.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /apis/1
  # DELETE /apis/1.json
  def destroy
    @api.destroy
    respond_to do |format|
      format.html { redirect_to apis_url, notice: 'Api was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_api
      @api = Api.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def api_params
      params.require(:api).permit(:consultar)
    end
end
