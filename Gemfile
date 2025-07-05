source "https://rubygems.org"

# GitHub Pages에서 사용하는 전체 gem 버전 묶음 (Jekyll 3.9.x 포함)
gem "github-pages", group: :jekyll_plugins

# GitHub Pages는 자체적으로 jekyll-feed도 포함하므로 따로 명시하지 않아도 됨
# 필요시 추가적인 플러그인은 여기 group 안에 넣을 수 있음
group :jekyll_plugins do
  # 예시: gem "jekyll-sitemap"
end

# Windows 등 플랫폼 특화 설정
platforms :mingw, :x64_mingw, :mswin, :jruby do
  gem "tzinfo", ">= 1", "< 3"
  gem "tzinfo-data"
end

# 성능 향상 (Windows용)
gem "wdm", "~> 0.1", platforms: [:mingw, :x64_mingw, :mswin]

# JRuby 대응
gem "http_parser.rb", "~> 0.6.0", platforms: [:jruby]
