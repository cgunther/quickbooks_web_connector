QuickbooksWebConnector::Engine.routes.draw do

  get 'qwc' => 'qwc#download', defaults: { format: :xml }
  post 'soap' => 'soap#endpoint'

  # QWC will perform a GET request to verify the SSL certificate
  get 'soap' => 'soap#endpoint'

end
