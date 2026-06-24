# frozen_string_literal: true

When(/^захожу на страницу "(.+?)"$/) do |url|
  visit url
  wait_loading_page
end

When(/^кликаю по кнопке с текстом "(.*?)"$/) do |button|
  link_first = find("//div[@id='page']//div//section//div[@data-hero-layer]//a['#{button}']")
  link_first.click
  wait_loading_page
end

When(/^скачиваю последний стабильный релиз$/) do
  link_first = find("//li[strong[contains(text(), 'Стабильные релизы:')]]//ul//li[1]//a")
  link_first.click
  $logger.info("Ожидаю начало загрузки")
  timeout_first = 1
  max_timeout_first = 10
  while timeout_first < max_timeout_first
    if data_file.length < 1
      timeout_first +=1
      sleep 1
    else
      $logger.info("Загрузка началась")
      break
    end
  end
  $logger.info("Файл загружается...")
  timeout = 1
  max_timeout = 20
  while timeout < max_timeout
    if file_name == file_without_extname
      timeout +=1
      sleep 1
    elsif  file_name != file_without_extname
      $logger.info("Файл #{file_name} загружен")
      break
    end
  end
  if timeout >= max_timeout || timeout_first >= max_timeout_first
  raise("Ошибка при загрузке файла")
  end
end

When(/^проверяю что скаченный файл находится в нужной директории$/) do
  if File.exist?("#{download_path}")
    $logger.info("Файл находится по пути #{download_path}")
  else
    raise("Файл не найден")
  end
end

When(/^проверяю что имя скаченного файла совпадает с именем файла-установщика указанного на сайте$/) do
  download_link = find("//li[strong[contains(text(), 'Стабильные релизы:')]]//ul//li[1]//a")
  href = download_link['href']
  name_release = File.basename(href, '.tar.gz')
  if name_release == file_without_extname
    $logger.info("Имя загруженного файла #{file_without_extname} совпадает с именем на сайте #{name_release}")
  else
    raise("Имя загруженного файла #{file_without_extname} не совпадает с именем на сайте #{name_release}")
  end
end