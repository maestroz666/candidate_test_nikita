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
  $logger.info("Скачивание файла началось")
  sleep 7
end
# страница загрузки, проверка что файл начал скичаваться, и она закончилась
When(/^проверяю что скаченный файл находится в нужной директории$/) do
  data_file.length < 1? raise("Папка загрузки пуста"): $logger.info("Папка загрузки не пуста")
  if File.exist?("#{download_path}")
    $logger.info("Файл находится по пути #{download_path}")
  else
    message = "Файл не найден"
    raise message
  end
end
# проверять что скачался именно тот. и пропало расширение .crdownload
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