module QuickbooksWebConnector
  class QwcController < ApplicationController

    def download
      send_data render_to_string(:qwc),
                disposition: 'attachment',
                filename: 'qbwc.qwc',
                type: :xml
    end

  end
end
