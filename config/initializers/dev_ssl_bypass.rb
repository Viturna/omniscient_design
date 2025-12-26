if Rails.env.development?
  require 'openssl'

  OpenSSL::SSL.send(:remove_const, :VERIFY_PEER) if OpenSSL::SSL.const_defined?(:VERIFY_PEER)
  
  OpenSSL::SSL.const_set(:VERIFY_PEER, OpenSSL::SSL::VERIFY_NONE)
end