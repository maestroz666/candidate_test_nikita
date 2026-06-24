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

$rest_wrap.post('/users', login: login,
                                       name: name,
                                       surname: surname,
                                       password: password,
                                       active: active)
  $logger.info("Пользователь с логин: #{login} имя: #{name} фамилия: #{surname} active: #{active} успешно добавлен" )
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

When(/^удаляю пользователя с логином (\w+(?:\.\w+)?) из списка пользователей$/) do |login|
  step %(получаю информацию о пользователях)
    user_data = @scenario_data.users_full_info.find { |user| user['login'] == login }
    user_id = user_data['id']
    $rest_wrap.delete("/users/#{user_id}")
    $logger.info("Пользователь #{login} успешно удален")
  end

When(/^добавляю пользователя c логином (\w+(?:\.\w+)?) паролем ([\d\w@!#]+) без дополнительных полей$/) do |login, password|
  $rest_wrap.post('/users', login: login,
                             password: password)
rescue => e
  if e
    $logger.info("Пользователь #{login} не создан status:#{e.message}")
  else
    raise("Пользователь добавлен")
  end
end

When(/^добавляю пользователя c логином (\w+(?:\.\w+)?) паролем ([\d\w@!#]+) без поля (name|surname|active)$/) do |login, password, variable, data_table|
  user_data = data_table.raw.to_h
  user_data.delete(variable)
  $logger.info("Данные для создания пользователя (после удаления поля #{variable}): #{user_data.inspect}")
  $rest_wrap.post('/users', login: login,
                             password: password,
                             **user_data)
rescue => e
  if e
    $logger.info("Пользователь не создан")
  else
    raise("Пользователь добавлен")
  end
  end


When(/^добавляю пользователя (.+?) с (\d+) символами$/) do |variable, count|
  fields = generate_user_random_fields(variable, count)

  $rest_wrap.post('/users', login: fields[:login],
                               password: fields[:password],
                               name: fields[:name],
                               surname: fields[:surname],
                               active: fields[:active])
    $logger.info("Пользователь с логином #{fields [:login]} именем #{fields [:name]} фамилией #{fields [:surname]} паролем #{fields [:password]} добавлен")
rescue => e
    if e && variable == 'логин'
      $logger.info("Пользователь с логином #{fields [:login]} не создан")
      elsif e && variable == 'имя'
      $logger.info("Пользователь с именем #{fields [:name]} не создан")
      elsif e && variable == 'фамилия'
      $logger.info("Пользователь с фамилией #{fields [:surname]} не создан")
      elsif e && variable == 'пароль'
      $logger.info("Пользователь с паролем #{fields [:password]} не создан")
    else
      raise e
    end
  end

When(/^проверяю (отсутствие|наличие) пользователя с (.+?) (\d+) символов в списке пользователей$/) do |present, variable, count|
    login = @scenario_data.last_generated[:login]
    name = @scenario_data.last_generated[:name]
    surname = @scenario_data.last_generated[:surname]
    password = @scenario_data.last_generated[:password]

  step %(получаю информацию о пользователях)
  logins_from_site = @scenario_data.users_full_info.map { |f| f.try(:[], 'login') }
  login_presents = logins_from_site.include?(login)

    case variable
    when 'логин'
      if present == 'наличие'
               if login_presents
                 $logger.info("Логин #{login} присутствует в списке пользователей")
               else
                 raise("Логин #{login} отсутствует в списке пользователей")
               end
      else
      if login_presents
       raise("Логин #{login} присутствует в списке пользователей")
      else
       $logger.info("Логин #{login} отсутствует в списке пользователей")
      end
      end
    when 'имя'
      if present == 'наличие'
        if login_presents
          $logger.info("Логин #{login} с именем #{name} присутствует в списке пользователей")
        else
          raise("Логин #{login} с именем #{name} отсутствует в списке пользователей")
        end
      else
        if login_presents
          raise("Логин #{login} с именем #{name} присутствует в списке пользователей")
        else
          $logger.info("Логин #{login} с именем #{name} отсутствует в списке пользователей")
        end
      end
    when 'фамилия'
    if present == 'наличие'
      if login_presents
        $logger.info("Логин #{login} с фамилией #{surname} присутствует в списке пользователей")
      else
        raise("Логин #{login} с фамилией #{surname} отсутствует в списке пользователей")
      end
    else
      if login_presents
        raise("Логин #{login} с фамилией #{surname} присутствует в списке пользователей")
      else
        $logger.info("Логин #{login} с фамилией #{surname} отсутствует в списке пользователей")
      end
    end
    when 'пароль'
      if present == 'наличие'
        if login_presents
          $logger.info("Логин #{login} с паролем #{password} присутствует в списке пользователей")
        else
          raise("Логин #{login} с паролем #{password} отсутствует в списке пользователей")
        end
      else
        if login_presents
          raise("Логин #{login} с паролем #{password} присутствует в списке пользователей")
        else
          $logger.info("Логин #{login} с паролем #{password} отсутствует в списке пользователей")
        end
      end
    else
      if present == 'наличие'
        if login_presents
          $logger.info("Логин #{login} присутствует в списке пользователей")
        else
          raise("Логин #{login} отсутствует в списке пользователей")
        end
      else
        if login_presents
          raise("Логин #{login} присутствует в списке пользователей")
        else
          $logger.info("Логин #{login} отсутствует в списке пользователей")
        end
      end
    end
    end

When(/^удаляю созданного пользователя$/) do
step %(получаю информацию о пользователях)
login = @scenario_data.last_generated[:login]
user_data = @scenario_data.users_full_info.find { |user| user['login'] == login }
user_id = user_data['id']
$rest_wrap.delete("/users/#{user_id}")
$logger.info("Пользователь #{login} успешно удален")
end

When(/^проверяю что пользователь (\w+\.\w+) содержит active = (-?\d+)$/) do |login, active|
  step %(получаю информацию о пользователях)
  user_data = @scenario_data.users_full_info.find { |user| user['login'] == login }
  user_active = user_data['active']
  if user_active == active
    $logger.info("У пользователя #{login} active = #{user_active}")
  else
    $logger.error("У пользователя #{login} active = #{user_active}")
  end
end

When(/^удаляю созданных пользователей (\w+\.\w+)$/) do |login|
  login_item = [login]
  step %(получаю информацию о пользователях)
  login_item.each { |login|
    user_data = @scenario_data.users_full_info.find{ |user| user['login'] == login }
    user_id = user_data['id']
    $rest_wrap.delete("/users/#{user_id}")
    $logger.info("Пользователь #{login} успешно удален")
  }
end

When(/^изменяю у пользователя с логином (\w+(?:\.\w+)?) имя на (\w+(?:\.\w+)?) фамилию на (\w+) логин на (\w+(?:\.\w+)?) active на (-?\d+)$/) do
|login, name, surname, login_edit, active|
  step %(получаю информацию о пользователях)
  user_data = @scenario_data.users_full_info.find{ |user| user['login'] == login }
  user_id = user_data['id']
  $rest_wrap.put("/users/#{user_id}", login: login_edit,
                            name: name,
                            surname:  surname,
                            active: active)
  $logger.info("Пользователь с логином #{login} успешно изменен на логин #{login_edit}, имя на #{name}, фамилия на #{surname}, active на #{active}")
end