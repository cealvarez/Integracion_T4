require 'uri'
require 'net/http'

class ApisController < ApplicationController

  # GET /apis
  # GET /apis.json
  def index
    @apis = Api.all
  end

  # GET /apis/1
  # GET /apis/1.json
  def show
    @city = params[:city]
    puts 'Empieza el request'
    @city = params[:text]
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

    url = URI("https://hooks.slack.com/services/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")
    texto = "El tiempo en "+@city+": "+@datos
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    request = Net::HTTP::Post.new(url)
    request["cache-control"] = 'no-cache'
    request["postman-token"] = 'a987c720-123a-a9ec-5dcd-af828ab7d192'
    request.body = "{\n    \"username\": \"mi primer bot\",\n    \"response_type\": \"ephemeral\",\n    \"text\": \""+ texto +"\"\n}\n"
    response = http.request(request)
    #puts response.read_body

    respond_to do |format|
      format.html {}
      format.json { render :json => my_hash}
      format.js
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
