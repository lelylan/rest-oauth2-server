class Scope
  include Mongoid::Document
  include Mongoid::Timestamps
  include Lelylan::Document::Base
  include Lelylan::Array::Normalize

  before_save :normalize_values

  field :name
  field :uri
  field :host
  field :values, type: Array

  attr_accessible :name

  validates :name, presence: true
  validates :host, presence: true
  validates :uri, url: true
end
