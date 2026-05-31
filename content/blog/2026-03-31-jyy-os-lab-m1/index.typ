#import "../index.typ": template, tufted
#import "@preview/cmarker:0.1.8"
#import "@preview/mitex:0.2.6": mitex
#show: template.with(title: "JYY OS 2026 Lab M1 - 迷宫游戏 (labyrinth)")

= JYY OS 2026 Lab M1 - 迷宫游戏 (labyrinth)

#let md-content = read("post.md")

#cmarker.render(md-content, math: mitex)
