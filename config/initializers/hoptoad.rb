unless Rails.env.acceptance?
  HoptoadNotifier.configure do |config|
    config.api_key = '670155d8819071244378479137fb73bb'
  end
end
