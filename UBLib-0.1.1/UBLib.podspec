Pod::Spec.new do |s|
  s.name = "UBLib"
  s.version = "0.1.1"
  s.summary = "A short description of UBLib."
  s.license = {"type"=>"MIT", "file"=>"LICENSE"}
  s.authors = {"Uber"=>"youbo@xiandanjia.com"}
  s.homepage = "https://github.com/Crazysiri/UBLib"
  s.description = "TODO: Add long description of the pod here."
  s.source = { :path => '.' }

  s.ios.deployment_target    = '9.0'
  s.ios.vendored_framework   = 'ios/UBLib.framework'
end
