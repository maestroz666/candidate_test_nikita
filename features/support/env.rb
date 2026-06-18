require 'capybara/cucumber'
require 'selenium-webdriver'
require 'yaml'
require 'rest-client'
require 'active_support/all'
require_relative 'helpers/rest_wrapper'
require_relative 'helpers/logger'
require_relative 'helpers/class_extentions'
require_relative 'helpers/download_helper'
require_relative 'helpers/wait_loading_page'
require 'fileutils'

def browser_setup(browser = 'chrome')
  case browser
  when 'chrome'
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
  else
    Capybara.register_driver :firefox do |app|
      options = Selenium::WebDriver::Firefox::Options.new

      options.add_argument('--no-sandbox')
      options.add_argument('--disable-dev-shm-usage')
      options.add_argument('--disable-gpu')

      # Настройки загрузки
      options.add_preference('browser.download.dir', "#{Dir.pwd}/features/tmp/")
      options.add_preference('browser.download.folderList', 2)
      options.add_preference('browser.helperApps.neverAsk.saveToDisk','application/x-tar, application/octet-stream, application/x-gzip, application/gzip')

      Capybara::Selenium::Driver.new(app, browser: :firefox, options: options)
  end
    Capybara.default_driver = :firefox
    Capybara.default_selector = :xpath
    Capybara.page.driver.browser.manage.window.maximize
    Capybara.default_max_wait_time = 15
  end
end

browser_setup('chrome')

configuration = YAML.load_file 'configuration/default.yml'
logger_initialize
$rest_wrap = RestWrapper.new url: 'https://testing4qa.ediweb.ru/api',
                             **configuration[:credentials]
