using Documenter, Indicators

makedocs(
    modules = [Indicators],
    sitename = "Indicators.jl",
    authors="Jacob Amos, Matthew Farrell",
    pages=["Home"=>"index.md",
           "Conventional" => ["Moving Averages" => "ma.md",
                              "Momentum Indicators" => "mom.md",
                              "Volatility Indicators" => "vol.md"],
           "Exotic" => ["Regressions"=>"reg.md",
                        "Trendlines" => "trendy.md",
                        "Chaos" => "chaos.md",
                        "Patterns" => "patterns.md"]],
    format = Documenter.HTML(
        canonical = "https://farrellm.github.io/Indicators.jl",
        edit_link = "master",
    ),
    doctest=false,
    checkdocs=:exports,
)

deploydocs(repo="github.com/farrellm/Indicators.jl",
           devbranch="master")
