Dir.glob(Rails.root.join('test','initializers','*.rb')).each do |initializer|
  require initializer
end if Rails.env.test?
