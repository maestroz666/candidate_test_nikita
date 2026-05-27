# frozen_string_literal: true

Before do |_scenario|
  @scenario_data = ScenarioData.new
end

Before do |scenario|
  if scenario.name == 'Работа с web-страницей'
  clear_tmp
  $logger.info('Папка для временных файлов очищена')
  end
end