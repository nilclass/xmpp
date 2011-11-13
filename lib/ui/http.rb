
class UI::HTTP < Sinatra::Base
  COFFEE_ROOT = File.expand_path("../../../ui/", __FILE__)
  STYLE_ROOT = File.expand_path("../../../style/stylesheets", __FILE__)

  get '/' do
    <<-EOF
      <!DOCTYPE html>
      <html>
        <head>
          <link rel="stylesheet" href="/screen.css" type="text/css" />
          <script src="/jquery.js" type="text/javascript"></script>
          <script src="/main.js" type="text/javascript"></script>
        </head>
        <body data-socket-url="#{socket_url}"></body>
      </html>
    EOF
  end

  get '/:file.js' do |file|
    content_type 'application/javascript'
    js_file = File.join(COFFEE_ROOT, "#{file}.js")
    if File.exist?(js_file)
      File.read(js_file)
    elsif File.exist?(min_js_file = js_file.sub(/\.js$/, '.min.js'))
      File.read(min_js_file)
    else
      coffee_file = File.join(COFFEE_ROOT, "#{file}.coffee")
      CoffeeScript.compile(File.read(coffee_file))
    end
  end

  get '/:file.css' do |file|
    content_type 'text/css'
    File.read(File.join(STYLE_ROOT, "#{file}.css"))
  end

  helpers do
    def socket_url
      "ws://#{request.host}:#{request.port}/socket"
    end
  end
end
