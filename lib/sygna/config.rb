module Sygna
  class Config
    class << self
      attr_writer :instance

      def instance
        @instance ||= new
      end
    end

    attr_accessor :api_domain_base
    attr_accessor :api_key
    attr_accessor :premission_request_callback_url
    attr_accessor :public_key
    attr_accessor :private_key
    attr_accessor :vasp_code

    def initialize(config = {})
      self.api_domain_base = config[:api_domain_base]
      self.api_key = config[:api_key]
      self.premission_request_callback_url = config[:premission_request_callback_url]
      self.public_key = config[:public_key]
      self.private_key = config[:private_key]
      self.vasp_code = config[:vasp_code]
    end

    def valid?
      !self.api_domain_base.empty? && !self.api_key.empty? && !self.premission_request_callback_url.empty? && !self.public_key.empty? && !self.private_key.empty? && !self.vasp_code.empty?
    rescue false
    end
  end
end