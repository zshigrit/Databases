using Dash,DashCoreComponents, DashHtmlComponents

using DataFrames, PlotlyJS, UrlDownload

df2 = DataFrame(urldownload("https://raw.githubusercontent.com/zshigrit/understandingecosys/main/ANPP.csv?token=GHSAT0AAAAAABSI3DRLEWTVE7QXN3MIPA2QY4IUCMA"))

dropmissing!(df2)

rename!(df2, Dict(:"Year" => "year"))
rename!(df2, Dict(:"Biomass" => "Value"))

available_indicators = unique(df2[!, "Warming"])
years = unique(df2[!, "year"])

app = dash()

app.layout = html_div() do
    html_div(
        children = [
            dcc_dropdown(
                id = "xaxis-column",
                options = [
                    (label = i, value = i) for i in available_indicators
                ],
                value = "ANPP(g/m2)",
            ),
            dcc_radioitems(
                id = "xaxis-type",
                options = [(label = i, value = i) for i in ["linear", "log"]],
                value = "linear",
            ),
        ],
        style = (width = "48%", display = "inline-block"),
    ),
    dcc_graph(id = "indicator-graphic"),
    dcc_slider(
        id = "year-slider-2",
        min = minimum(years),
        max = maximum(years),
        marks = Dict([Symbol(v) => Symbol(v) for v in years]),
        value = minimum(years),
        step = nothing,
    )
end

callback!(
    app,
    Output("indicator-graphic", "figure"),
    Input("xaxis-column", "value"),
    Input("yaxis-column", "value"),
    Input("xaxis-type", "value"),
    Input("yaxis-type", "value"),
    Input("year-slider-2", "value"),
) do xaxis_column_name, yaxis_column_name, xaxis_type, yaxis_type, year_value
    df2f = df2[df2.year .== year_value, :]
    return Plot(
        df2f[df2f[!, Symbol("Indicator Name")] .== xaxis_column_name, :Value],
        df2f[df2f[!, Symbol("Indicator Name")] .== yaxis_column_name, :Value],
        Layout(
            xaxis_type = xaxis_type == "Linear" ? "linear" : "log",
            xaxis_title = xaxis_column_name,
            yaxis_title = yaxis_column_name,
            yaxis_type = yaxis_type == "Linear" ? "linear" : "log",
            hovermode = "closest",
        ),
        kind = "scatter",
        text = df2f[
            df2f[!, Symbol("Indicator Name")] .== yaxis_column_name,
            Symbol("PlotID"),
        ],
        mode = "markers",
        marker_size = 15,
        marker_opacity = 0.5,
        marker_line_width = 0.5,
        marker_line_color = "white"
    )
end


run_server(app, "127.0.0.1", 8080)
