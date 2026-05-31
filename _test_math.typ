#import "@preview/cmarker:0.1.8"

= Test Math No MiTeX

#let md = "Inline: $sin x = x - 1/6 x^3 + o(x^3)$

Block:
$$ sin x = x - 1/6 x^3 + o(x^3) $$

LaTeX inline: $\\sin x = x - \\frac{1}{6}x^3 + o(x^3)$"

#cmarker.render(md)
