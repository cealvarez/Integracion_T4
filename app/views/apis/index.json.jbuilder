json.array!(@apis) do |api|
  json.extract! api, :id, :consultar
  json.url api_url(api, format: :json)
end
