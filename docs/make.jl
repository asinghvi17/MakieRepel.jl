using MakieRepel
using Documenter

DocMeta.setdocmeta!(MakieRepel, :DocTestSetup, :(using MakieRepel); recursive=true)

makedocs(;
    modules=[MakieRepel],
    authors="Anshul Singhvi <anshulsinghvi@gmail.com> and contributors",
    repo="https://github.com/asinghvi17/MakieRepel.jl/blob/{commit}{path}#{line}",
    sitename="MakieRepel.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://asinghvi17.github.io/MakieRepel.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
        "Finding good parameters" => "manipulation.md",
        "API" => "api.md"
    ],
)

deploydocs(;
    repo="github.com/asinghvi17/MakieRepel.jl",
    devbranch="main",
    push_preview = true,
)
