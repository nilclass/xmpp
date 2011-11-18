# encoding:utf-8
module OTR
  module Version
    MAJOR = 0
    MINOR = 0
    PATCH = 0
    BUILD = 'beta0'

    STRING = [MAJOR, MINOR, PATCH, BUILD].compact.join('.')
  end
end
