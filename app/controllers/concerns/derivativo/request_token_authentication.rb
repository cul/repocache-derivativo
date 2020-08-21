module Derivativo::RequestTokenAuthentication
  extend ActiveSupport::Concern
  
  def authenticate_request_token
    status = :unauthorized
    authenticate_with_http_token do |token, other_options|
      status = (DERIVATIVO['remote_request_api_key'] == token) ? :ok : :forbidden
    end
    status
  end
  
end