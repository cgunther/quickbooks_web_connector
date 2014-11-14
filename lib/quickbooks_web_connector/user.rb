module QuickbooksWebConnector
  class User

    attr_reader :username, :company_file_path, :owner_id, :file_id

    def initialize(username, password, company_file_path, owner_id = nil, file_id = nil)
      @username = username
      @password = password
      @company_file_path = company_file_path

      @owner_id = owner_id || 'd69682e6-4436-44bc-bd19-d6bfbd11778d'
      @file_id = file_id || '916222f3-c574-4c70-8c9d-e3cec2634e49'
    end

    def valid_password?(provided_password)
      provided_password == password
    end

    private

    attr_reader :password

  end
end
