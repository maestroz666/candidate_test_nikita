# frozen_string_literal: true

When(/^захожу на страницу "(.+?)"$/) do |url|
  visit url
  $logger.info("Страница #{url} открыта")
  sleep 1
end

When(/^кликаю по кнопке с текстом "(.*?)"$/) do |button|
  link_first = find("//div[@id='page']//div//section//div[@data-hero-layer]//a['#{button}']")
  link_first.click
  current_url = page.current_url
  $logger.info("Переход на страницу #{current_url} осуществлен")
  sleep 1
end

When(/^скачиваю последний стабильный релиз$/) do
  link_first = find("//li[strong[contains(text(), 'Стабильные релизы:')]]//ul//li[1]//a")
  link_first.click
  sleep 1
  $logger.info("Скачивание файла началось")
  timeout = 0
  max_timeout = 20
  while timeout < max_timeout
    if file_name == file_without_extname
      $logger.info("Файл скачивается...")
      timeout +=1
      sleep 1
    elsif  file_name != file_without_extname
      $logger.info("Скачивание завершено")
      break
    end
  end
  if timeout >= max_timeout
  raise("Ошибка при скачивании файла")
  end
end

When(/^проверяю что скаченный файл находится в нужной директории$/) do
  data_file.length < 1? raise("Папка загрузки пуста"): $logger.info("Папка загрузки не пуста")
  if File.exist?("#{download_path}")
    $logger.info("Файл находится по пути #{download_path}")
  else
    message = "Файл не найден"
    raise message
  end
end

When(/^проверяю что имя скаченного файла совпадает с именем файла-установщика указанного на сайте$/) do
  download_link = find("//li[strong[contains(text(), 'Стабильные релизы:')]]//ul//li[1]//a")
  href = download_link['href']
  name_release = File.basename(href, '.tar.gz')
  if name_release == file_without_extname
    $logger.info("Имя скаченного файла совпадает с именем на сайте")
  else
    raise "Имя скаченного файла не совпадает с именем на сайте"
  end
end