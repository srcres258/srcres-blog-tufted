#import "../index.typ": template, tufted
#import "@preview/cmarker:0.1.8"
#import "@preview/mitex:0.2.6": mitex
#show: template.with(title: "Vim 常见快捷键收集")

= Vim 常见快捷键收集

#let md-content = read("post.md")

#let def-dict = (
  image: (source, alt: none, format: auto) => figure(image(
    source,
    alt: alt,
    format: format,
  )),
)

#cmarker.render(md-content, math: mitex, scope: def-dict)
