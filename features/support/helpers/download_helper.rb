  def download_path
    File.join(Dir.pwd, 'features', 'tmp')
  end
  def data_file
    Dir.glob(download_path + '/*')
  end
  def file_path
    data_file.last
  end
  def file_name
    File.basename(file_path)
  end
  def file_without_extname
    File.basename(file_path, ".tar.gz")
  end