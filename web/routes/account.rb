# Should approve account login
post '/api/account/approve/?' do
  BotWorker.approve(params[:account]).to_json
end

# Should check global variable with worker
post '/api/account/check_session/?' do
  BotWorker.check_session(params[:account]).to_json
end