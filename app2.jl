using Dash,DashCoreComponents, DashHtmlComponents

app = dash()

app.layout = html_div() do
    html_h1("Hello Dash + success!")
end

run_server(app,"127.0.0.1",8080)
#run_server(app,")
