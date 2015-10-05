require "mongo_helper/model"
require "mongo_helper/storable"
require "mongo_helper/user_state"
require "mongo_helper/assignment"
require "mongo_helper/associations_cache"
require "mongo_helper/stateable"

module MongoHelper

  def self.options
    @options ||= {}
  end

  def self.included(base)
    raise "Don't include this. Include MongoHelper::Model instead."
  end

end
