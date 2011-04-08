class Scope
  include Mongoid::Document
  include Mongoid::Timestamps
  include Lelylan::Array::Normalize
  include Lelylan::Document::Base

  field :name
  field :uri
  field :values, type: Array

  attr_accessible :name

  before_create :stringify_values

  validates :name, presence: true
  validates :uri, url: true

  def normalize(values)
    values.split(" ")
  end

end
