# frozen_string_literal: true

When(/^получаю информацию о пользователях$/) do
  users_full_information = $rest_wrap.get('/users')
  $logger.info('Информация о пользователях получена')
  @scenario_data.users_full_info = users_full_information
end

When(/^проверяю (наличие|отсутствие) логина ([^.]+(?:\.[^.]+)?) в списке пользователей$/) do |presence, login|
  step %(получаю информацию о пользователях)
  search_login_in_list = presence == 'отсутствие' ? false : true
  logins_from_site = @scenario_data.users_full_info.map { |f| f.try(:[], 'login') }
  login_presents = logins_from_site.include?(login)

  if login_presents
    message = "Логин #{login} присутствует в списке пользователей"
    search_login_in_list ? $logger.info(message) : raise(message)
  else
    message = "Логин #{login} отсутствует в списке пользователей"
    search_login_in_list ? raise(message) : $logger.info(message)
  end
end

When(/^добавляю пользователя c логином ([^.]+(?:\.[^.]+)?) именем (\w+) фамилией (\w+) паролем ([\d\w@!#]+) статус active (-?\d+)$/) do
|login, name, surname, password, active|

  response = $rest_wrap.post('/users', login: login,
                                       name: name,
                                       surname: surname,
                                       password: password,
                                       active: active)
  $logger.info(response.inspect)
rescue => e
  if e
    $logger.info("Пользователь не создан")
  else
    raise("Пользователь добавлен")
  end
end

When(/^проверяю что пользователь c логином ([^.]+(?:\.[^.]+)?) именем (\w+) фамилией (\w+) статус active (-?[\d\w@!#]+) добавлен$/) do
|login, name, surname, active|
  step %(получаю информацию о пользователях)
  user_data = @scenario_data.users_full_info.find { |user| user['login'] == login }
  login_presents = user_data.value?(login)
  name_presents = user_data.value?(name)
  surname_presents = user_data.value?(surname)
  active_value = user_data["active"].to_s
  active_presents = active == active_value
  if login_presents && name_presents && surname_presents && active_presents
    $logger.info("Пользователь с логин: #{login} имя: #{name} фамилия: #{surname} active: #{active} присутствует в списке пользователей")
  else
    raise("Пользователь не добавлен")
  end
end



 When(/^добавляю пользователя с параметрами:$/) do |data_table|
  user_data = data_table.raw

  login = user_data[0][1]
  name = user_data[1][1]
  surname = user_data[2][1]
  password = user_data[3][1]

  step "добавляю пользователя c логином #{login} именем #{name} фамилией #{surname} паролем #{password}"
end

When(/^нахожу пользователя с логином (\w+\.\w+)$/) do |login|
  step %(получаю информацию о пользователях)
  if @scenario_data.users_id[login].nil?
    @scenario_data.users_id[login] = find_user_id(users_information: @scenario_data
                                                                         .users_full_info,
                                                  user_login: login)
  end

  $logger.info("Найден пользователь #{login} с id:#{@scenario_data.users_id[login]}")
end

When(/^удаляю пользователя с логином (\w+(?:\.\w+)?) из списка пользователей$/) do |login|
  step %(получаю информацию о пользователях)
    user_data = @scenario_data.users_full_info.find { |user| user['login'] == login }
    user_id = user_data['id']
    response = $rest_wrap.delete("/users/#{user_id}")
    $logger.info(response.inspect)
  end

When(/^изменяю у пользователя с логином (\w+\.\w+) имя фамилию пароль логин$/) do |login|
  user_data = @scenario_data.users_full_info.find { |user| user['login'] == login }
  user_id = user_data['id']
  response = $rest_wrap.put("/users/#{user_id}", login: "QA.testing",
                            name: 'leon',
                            surname: 'kennedy',
                            password: 'Qwerty123123',
                            active: 0)
  $logger.info(response.inspect)
end

When(/^добавляю пользователя c логином (\w+(?:\.\w+)?) паролем ([\d\w@!#]+) без дополнительных полей$/) do |login, password|
  response = $rest_wrap.post('/users', login: login,
                             password: password)
  $logger.info(response.inspect)
rescue => e
  if e
    $logger.info("Пользователь не создан")
  else
    raise("Пользователь добавлен")
  end
end

When(/^добавляю пользователя c логином (\w+(?:\.\w+)?) паролем ([\d\w@!#]+) с именем (\w+(?:\.\w+)?)$/) do |login, name, password|
  response = $rest_wrap.post('/users', login: login,
                             password: password,
                             name: name)
  $logger.info(response.inspect)
rescue => e
  if e
    $logger.info("Пользователь не создан")
  else
    raise("Пользователь добавлен")
  end
end

When(/^добавляю пользователя c логином (\w+(?:\.\w+)?) паролем ([\d\w@!#]+) с именем (\w+(?:\.\w+)?) с фамилией (\w+(?:\.\w+)?)$/) do
|login, name, password, surname|
  response = $rest_wrap.post('/users', login: login,
                             password: password,
                             name: name,
                             surname: surname)
  $logger.info(response.inspect)
rescue => e
  if e
    $logger.info("Пользователь не создан")
  else
    raise("Пользователь добавлен")
  end
end

When(/^добавляю пользователя c логином (\w+(?:\.\w+)?) паролем ([\d\w@!#]+) с фамилией (\w+(?:\.\w+)?) статус active ([\d\w@!#]+)$/) do
|login, name, password, active|
  response = $rest_wrap.post('/users', login: login,
                             password: password,
                             name: name,
                             active: active)
  $logger.info(response.inspect)
rescue => e
  if e
    $logger.info("Пользователь не создан")
  else
    raise("Пользователь добавлен")
  end
end

When(/^добавляю пользователя c логином (\w+(?:\.\w+)?) паролем ([\d\w@!#]+) с именем (\w+(?:\.\w+)?) статус active ([\d\w@!#]+)$/) do
|login, name, password, active|
  response = $rest_wrap.post('/users', login: login,
                             password: password,
                             name: name,
                             active: active)
  $logger.info(response.inspect)
rescue => e
  if e
    $logger.info("Пользователь не создан")
  else
    raise("Пользователь добавлен")
  end
end

When(/^добавляю пользователя c логином (\w+(?:\.\w+)?) паролем ([\d\w@!#]+) с фамилией (\w+(?:\.\w+)?)$/) do
|login, surname, password|
  response = $rest_wrap.post('/users', login: login,
                             password: password,
                             surname: surname)
  $logger.info(response.inspect)
rescue => e
  if e
    $logger.info("Пользователь не создан")
  else
    raise("Пользователь добавлен")
  end
end

When(/^добавляю пользователя c логином (\w+(?:\.\w+)?) паролем ([\d\w@!#]+) статус active ([\d\w@!#]+)$/) do
|login, password, active|
  response = $rest_wrap.post('/users', login: login,
                             password: password,
                             active: active)
  $logger.info(response.inspect)
rescue => e
  if e
    $logger.info("Пользователь не создан")
  else
    raise("Пользователь добавлен")
  end
end

When(/^добавляю пользователя (.+?) с (\d+) символами$/) do |variable, count|
  login = "123456789012345678901234567890123456789012345"
  login_error = "123456789012345678901234567890123456789012345"
  name = "123456789012345678901234567890123456789012345"
  name_error = "1234567890123456789012345678901234567890123456"
  surname = "123456789012345678901234567890123456789012345"
  surname_error = "1234567890123456789012345678901234567890123456"
  password = "123456789012345678901234567890123456789012345"
  password_error = "1234567890123456789012345678901234567890123456"
  active = 127
  if count == 56
  case variable
  when 'логин'
    response = $rest_wrap.post('/users', login: login_error,
                               password: password,
                               name: name,
                               surname: surname,
                               active: active)
    $logger.info(response.inspect)
    $logger.error("Пользователь добавлен")
  when 'имя'
      response = $rest_wrap.post('/users', login: login,
                                 password: password,
                                 name: name_error,
                                 surname: surname,
                                 active: active)
      $logger.info(response.inspect)
      $logger.error("Пользователь добавлен")
  when 'фамилия'
      response = $rest_wrap.post('/users', login: login,
                                password: password,
                                name: name,
                                surname: surname_error,
                                active: active)
      $logger.info(response.inspect)
      $logger.error("Пользователь добавлен")
  when 'пароль'
      response = $rest_wrap.post('/users', login: login,
                                password: password_error,
                                name: name,
                                surname: surname,
                                active: active)
      $logger.info(response.inspect)
      $logger.error("Пользователь добавлен")
  end
  else
    response = $rest_wrap.post('/users', login: login,
                               password: password,
                               name: name,
                               surname: surname,
                               active: active)
    $logger.info(response.inspect)
    $logger.info("Пользователь добавлен")
end
rescue => e
  if e.message.include?('400')
    $logger.info("Пользователь не создан")
  else
    raise e
  end
end

When(/^проверяю (отсутствие|наличие) пользователя с (.+?) (\d+) символов в списке пользователей$/) do |present, variable, count|
  login = "123456789012345678901234567890123456789012345"
  login_error = "1234567890123456789012345678901234567890123456"
step %(получаю информацию о пользователях)
  if variable == 'логин' && count == 56
    logins_from_site = @scenario_data.users_full_info.map { |f| f.try(:[], 'login') }
    login_presents = logins_from_site.include?(login_error)
    if login_presents
      raise("Логин #{login_error} присутствует в списке пользователей")
    else
      $logger.info("Логин #{login_error} отсутствует в списке пользователей")
    end
  elsif variable != 'логин' && count == 56
    logins_from_site = @scenario_data.users_full_info.map { |f| f.try(:[], 'login') }
    login_presents = logins_from_site.include?(login)
    if login_presents
      raise("Логин #{login} присутствует в списке пользователей")
    else
      $logger.info("Логин #{login} отсутствует в списке пользователей")
    end
  else
    logins_from_site = @scenario_data.users_full_info.map { |f| f.try(:[], 'login') }
    login_presents = logins_from_site.include?(login)
    if login_presents
      $logger.info("Логин #{login} присутствует в списке пользователей")
    else
      raise("Логин #{login} отсутствует в списке пользователей")
    end
  end
end

When(/^удаляю созданного пользователя$/) do
step %(получаю информацию о пользователях)
login = "123456789012345678901234567890123456789012345"
user_data = @scenario_data.users_full_info.find { |user| user['login'] == login }
user_id = user_data['id']
response = $rest_wrap.delete("/users/#{user_id}")
$logger.info(response.inspect)
end

When(/^проверяю что пользователь (\w+\.\w+) содержит active = (-?\d+)$/) do |login, active|
  step %(получаю информацию о пользователях)
  user_data = @scenario_data.users_full_info.find { |user| user['login'] == login }
  user_active = user_data['active']
  if user_active == active
    $logger.info('Данные совпадают')
  else
    $logger.error('Данные не совпадают')
  end
end

When(/^удаляю созданных пользователей (\w+\.\w+) (\w+\.\w+) (\w+\.\w+) (\w+\.\w+) (\w+\.\w+)$/) do |login1, login2, login3, login4, login5|
  login_item = [login1, login2, login3, login4, login5]
  step %(получаю информацию о пользователях)
  login_item.each { |login|
    user_data = @scenario_data.users_full_info.find { |user| user['login'] == login }
    user_id = user_data['id']
    response = $rest_wrap.delete("/users/#{user_id}")
    $logger.info(response.inspect)
  } #можно из списка логинов делать массив и потом можно удалять любое количество пользователей
end

When(/^изменяю у пользователя с логином (\w+(?:\.\w+)?) имя на (\w+(?:\.\w+)?) фамилию на (\w+) логин на (\w+(?:\.\w+)?) active на (-?\d+)$/) do
|login, name, surname, login_edit, active|
  step %(получаю информацию о пользователях)
  user_data = @scenario_data.users_full_info.find { |user| user['login'] == login }
  user_id = user_data['id']
  puts user_id
  response = $rest_wrap.put("/users/#{user_id}", login: login_edit,
                            name: name,
                            surname:  surname,
                            active: active)
  $logger.info(response.inspect)
end