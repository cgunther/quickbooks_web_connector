QuickbooksWebConnector::Engine.routes.draw do

  get 'qwc' => 'qwc#download', defaults: { format: :xml }

end
