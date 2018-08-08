Dir[Rails.root.join("lib/exts/*.rb")].each {|f| require f}
Dir[Rails.root.join("lib/spree/*.rb")].each {|f| require f}
