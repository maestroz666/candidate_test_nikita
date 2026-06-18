ELEMENTS = {
  '/ru/' => {
    default: "//div[@id='page']//div//section//div[@data-hero-layer]//a[contains(text(), 'Скачать')]",
  },
  '/ru/downloads/' => {
    default: "//li[strong[contains(text(), 'Стабильные релизы:')]]//ul//li[1]//a",
  }
}

def wait_loading_page(element_key: :default, timeout:15)
  current_path = page.current_path
  page_config = ELEMENTS[current_path]

  if page_config.nil?
    $logger.warn("Страница #{current_path} не добавлена в список для проверок")
    wait_for_body
    return
  end

  xpath = page_config[element_key]
  if xpath.nil?
    raise("Элемент #{element_key} не найден на странице #{current_path}")
  end
  expect(page).to have_xpath(xpath, wait: timeout)
  $logger.info("Страница #{current_path} загружена, элемент #{element_key} найден")
end
def wait_for_body(timeout: 15)
  expect(page).to have_xpath("//div[@id='page']", wait: timeout)
end