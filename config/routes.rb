QuickbooksWebConnector::Engine.routes.draw do

  get 'qwc' => 'qwc#download', default: { format: :xml }

end
