Pod::Spec.new do |s|

  s.name             = "LMGraphView"
  s.version          = "1.0.0"
  s.summary          = "LMGraphView is a simple and customizable graph view for iOS."
  s.homepage         = "https://github.com/lminhtm/LMGraphView"
  s.license          = 'MIT'
  s.author           = { "LMinh" => "lminhtm@gmail.com" }
  s.source           = { :git => "https://github.com/lminhtm/LMGraphView.git", :tag => s.version.to_s }

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.source_files = 'LMGraphView/**/*.{h,m}'

end
