class Scope
  include Mongoid::Document
  include Mongoid::Timestamps
  include Lelylan::Document::Base

  field :name
  field :uri
  field :values, type: Array
  field :values_with_space

  attr_accessible :name, :values_with_space

  validates :name, presence: true
  validates :values, presence: true
  validates :uri, url: true

  def normalize(val)
    val = val.split(" ")
  end

end
