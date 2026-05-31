#import "../index.typ": template, tufted
#import "@preview/cmarker:0.1.8"
#import "@preview/mitex:0.2.6": mitex
#show: template.with(title: "JYY OS 2026 Lab M2 - 打印进程树 (pstree)")

= JYY OS 2026 Lab M2 - 打印进程树 (pstree)

#let md-content = read("post.md")

#let def-dict = (
  image: (source, alt: none, format: auto) => figure(image(
    source,
    alt: alt,
    format: format,
  )),
)

#cmarker.render(md-content, math: mitex, scope: def-dict)
