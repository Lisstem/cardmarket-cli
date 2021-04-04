# frozen_string_literal: true

require 'logger'

module CardmarketCLI
  ##
  # Adds logging capabilities to classes
  module Logging
    ##
    # Wrapper for the default logger
    class << self
      def enable(logger = Logger.new($stdout))
        return if enabled?

        self.logger = logger
        self
      end

      def enabled?
        !!@logger
      end

      def disable
        self.logger = nil
        self
      end

      def logger=(logger)
        @logger = logger
        @level = logger&.level
      end

      attr_accessor :level

      %i[debug info warn error fatal unknown].each do |m|
        define_method m do |level = nil, name, &block|
          return unless @logger

          @logger.level = level || self.level
          r = @logger.send(m, name, &block)
          @logger.level = @level
          r
        end

        define_method "#{m}?" do |level = nil, &block|
          return unless @logger

          @logger.level = level || self.level
          r = @logger.send("#{m}?".to_sym, &block)
          @logger.level = @level
          r
        end
      end
    end

    protected

    attr_accessor :log_level

    %i[debug info warn error fatal unknown].each do |m|
      define_method "log_#{m}" do |&block|
        Logging.send(m, log_level, self.class.name, &block)
      end

      define_method "log_#{m}?" do
        Logging.send("#{m}?", log_level)
      end

      define_method "log_#{m}!" do
        self.log_level = m
      end

      protected "log_#{m}".to_sym, "log_#{m}?".to_sym, "log_#{m}!".to_sym
    end
  end
end
