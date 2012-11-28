Rails.application.routes.draw do

  mount QuickbooksWebConnector::Engine => "/quickbooks_web_connector"
end
