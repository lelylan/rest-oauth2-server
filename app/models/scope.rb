class Scope
  include Mongoid::Document
  include Mongoid::Timestamps
  include Lelylan::Array::Normalize
  include Lelylan::Document::Base

  field :name
  field :uri
  field :host
  field :values, type: Array

  attr_accessible :name

  before_save :normalize_values

  validates :name, presence: true
  validates :host, presence: true
  validates :uri, url: true
end
