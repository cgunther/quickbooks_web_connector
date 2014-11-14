xml.instruct!
xml.QBWCXML do
  xml.AppName "#{QuickbooksWebConnector.config.app_name} (#{@user.username})"
  xml.AppID
  xml.AppURL quickbooks_web_connector.soap_url
  xml.AppDescription QuickbooksWebConnector.config.app_description
  xml.AppSupport main_app.root_url
  xml.UserName @user.username
  xml.OwnerID "{#{@user.owner_id}}"
  xml.FileID "{#{@user.file_id}}"
  xml.QBType 'QBFS'
end
