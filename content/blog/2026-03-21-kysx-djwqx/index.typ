#import "../index.typ": template, tufted
#import "@preview/cmarker:0.1.8"
#show: template.with(title: "常用等价无穷小收集")

= 常用等价无穷小收集

#let md-content = read("post.md")

#cmarker.render(md-content)
