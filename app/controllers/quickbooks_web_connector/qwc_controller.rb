module QuickbooksWebConnector
  class QwcController < QuickbooksWebConnectorController

    def download
      @user = QuickbooksWebConnector.config.users[params[:username]]

      if !@user
        head :not_found
      else
        send_data render_to_string(:qwc),
                  disposition: 'attachment',
                  filename: "#{@user.username}.qwc",
                  type: :xml
      end
    end

  end
end
