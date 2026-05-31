#import "../index.typ": template, tufted
#import "@preview/cmarker:0.1.8"
#show: template.with(title: "数学每日背诵内容")

= 数学每日背诵内容

#let md-content = read("post.md")

#cmarker.render(md-content)
