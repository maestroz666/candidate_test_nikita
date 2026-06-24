def success_response(response, request_info = {})
  method = request_info[:method].upcase
  if response.code == 200
    $logger.info("Сервис #{method} вернул status: #{response.code}")
  else
    raise("Код ответа1111 #{response.code}")
  end
end