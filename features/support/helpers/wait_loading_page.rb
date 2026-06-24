ELEMENTS = {
  '/ru/' => {
    default: "//div[@id='page']//div//section//div[@data-hero-layer]//a[contains(text(), 'Скачать')]",
  },
  '/ru/downloads/' => {
    default: "//li[strong[contains(text(), 'Стабильные релизы:')]]//ul//li[1]//a",
  }
}

def current_page
  current_page = page.current_url
end

def wait_loading_page(element_key: :default, timeout:5)
  current_path = page.current_path
  page_config = ELEMENTS[current_path]
  if page_config.nil?
    $logger.warn("Страница #{current_page} не добавлена в список для проверок, проверяю загрузку DOM")
    wait_for_dom_ready
    return
  end

  xpath = page_config[element_key]
  if xpath.nil?
    raise("Некорректный ключ #{element_key}")
  end
  expect(page).to have_xpath(xpath, wait: timeout)
  $logger.info("Страница #{current_page} загружена, элемент #{xpath} найден")
end
def wait_for_dom_ready(timeout: 15)
  start_time = Time.now
  while Time.now - start_time < timeout
    ready_state = page.evaluate_script('document.readyState')
    if ready_state == 'complete'
      $logger.info("DOM страницы #{current_page} загружен")
      return true
    end
    sleep 0.3
  end
  raise("DOM не загрузился за #{timeout} секунд")
end