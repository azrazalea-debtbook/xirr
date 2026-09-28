require_relative 'test_helper'
require 'open3'
require 'rbconfig'

describe 'Xirr.config' do
  it 'loads without any ActiveSupport deprecation' do
    # A fresh process, since test_helper has already loaded all of ActiveSupport.
    script = <<~RUBY
      require 'active_support'
      ActiveSupport.deprecator.behavior = :raise
      require 'xirr'
      # defined? is truthy for ActiveSupport's registered-but-unloaded autoloads.
      if $LOADED_FEATURES.any? { |f| f.end_with?('active_support/configurable.rb') }
        abort 'ActiveSupport::Configurable was loaded'
      end
    RUBY
    lib = File.expand_path('../lib', __dir__)
    _out, err, status = Open3.capture3(RbConfig.ruby, '-I', lib, '-e', script)

    assert status.success?, err
  end

  it 'exposes the defaults as settings and constants' do
    assert_equal 1.0e-6, Xirr.config.eps
    assert_equal :rtsafe, Xirr.config.default_method
    assert_equal 365.0, Xirr::PERIOD
  end

  it 'yields the config to configure' do
    Xirr.configure { |c| c.iteration_limit = 7 }

    assert_equal 7, Xirr.config.iteration_limit
    assert_equal 50, Xirr::ITERATION_LIMIT
  ensure
    Xirr.configure { |c| c.iteration_limit = Xirr::ITERATION_LIMIT }
  end
end
