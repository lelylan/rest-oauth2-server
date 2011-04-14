class Scope
  include Mongoid::Document
  include Mongoid::Timestamps
  include Lelylan::Document::Base

  field :name
  field :uri
  field :values, type: Array

  attr_accessible :name

  validates :name, presence: true
  validates :values, presence: true
  validates :uri, url: true

  def normalize(val)
    separator = Oauth.settings["scope_separator"]
    val = val.split(separator)
  end

  def values_pretty
    separator = Oauth.settings["scope_separator"]
    values.join(separator)
  end

end
