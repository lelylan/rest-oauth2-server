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
    val = val.split(" ")
  end

end
