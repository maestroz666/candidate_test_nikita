require 'capybara/cucumber'
require 'selenium-webdriver'
# require 'webdrivers'
require 'yaml'
require 'rest-client'
require 'active_support/all'
require_relative 'helpers/rest_wrapper'
require_relative 'helpers/logger'
require_relative 'helpers/class_extentions'
require_relative 'helpers/download_helper'
require 'fileutils'

# Webdrivers::Chromedriver.required_version = '138.0.7204.0'

# Настройка Chrome драйвера
Capybara.register_driver :chrome do |app|
  options = Selenium::WebDriver::Chrome::Options.new

  options.add_argument('--window-size=1920,1080')
  options.add_argument('--no-sandbox')
  options.add_argument('--disable-dev-shm-usage')
  options.add_argument('--disable-gpu')

  # Настройки загрузки
  options.add_preference('download.default_directory', "#{Dir.pwd}/features/tmp/")
  options.add_preference('download.prompt_for_download', false)
  options.add_preference('plugins.plugins_disabled', ['Chrome PDF Viewer'])

  Capybara::Selenium::Driver.new(app, browser: :chrome, options: options)
end

Capybara.default_driver = :chrome
Capybara.default_selector = :xpath
Capybara.default_max_wait_time = 15

# Загрузка конфигурации для API
configuration = YAML.load_file 'configuration/default.yml'
logger_initialize

# Инициализация RestWrapper
$rest_wrap = RestWrapper.new(
  url: 'https://testing4qa.ediweb.ru/api',
  **configuration[:credentials]
)

puts "✓ RestWrapper initialized with login: #{configuration[:credentials][:login]}"