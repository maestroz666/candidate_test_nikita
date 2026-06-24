def random_fields(length = 15)
  SecureRandom.alphanumeric(length)
end

def generate_user_random_fields(variable, count)
  if count == 46
    base_count = 45
  end

  case variable
  when 'логин'
    login = random_fields(count)
    name = random_fields(base_count)
    surname = random_fields(base_count)
    password = random_fields(base_count)
  when 'имя'
    login = random_fields(base_count)
    name = random_fields(count)
    surname = random_fields(base_count)
    password = random_fields(base_count)
  when 'фамилия'
    login = random_fields(base_count)
    name = random_fields(base_count)
    surname = random_fields(count)
    password = random_fields(base_count)
  when 'пароль'
    login = random_fields(base_count)
    name = random_fields(base_count)
    surname = random_fields(base_count)
    password = random_fields(count)
  else
    login = random_fields(count)
    name = random_fields(count)
    surname = random_fields(count)
    password = random_fields(count)
  end

  active = 127

  @scenario_data.last_generated ||= {}
  @scenario_data.last_generated.merge!(login: login,
                                       name: name,
                                       surname: surname,
                                       password: password,
                                       active: active)

  { login: login, name: name, surname: surname, password: password, active: active }
end
