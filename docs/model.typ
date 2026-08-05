// Explanatory figure for the README: the linear sizing model documented at
// the top of `src/layout.typ` (the "Model" section), with each symbol
// (a, c_h, c_w, gap) drawn as an annotated length on a concrete example
// instead of left abstract. Regenerate with:
//
//   cd packages/mosaic && typst compile --root . docs/model.typ docs/model.png --format png --ppi 300

#set page(width: 26cm, height: auto, margin: 1cm, fill: white)
#set text(size: 11pt)

#let blue = rgb("#3b82f6")
#let orange = rgb("#f97316")
#let dim-color = rgb("#334155")
#let tick = 4pt

// ── Dimension-line annotations ──────────────────────────────────────────────
// Plain-Typst ruler brackets (tick, connecting line, tick) with a centered
// label -- these are purely presentational (no `cetz`/external package, and
// nothing here is package logic), unlike the leaf/group boxes they measure,
// whose *sizes* are always the exact `a`/`c_h`/`c_w`/gap numbers used below.

#let hdim(w, label) = box(width: w, height: 1.5em)[
  #place(top + left, line(end: (0pt, tick), stroke: 0.6pt + dim-color))
  #place(top + right, line(end: (0pt, tick), stroke: 0.6pt + dim-color))
  #place(top + left, dy: tick / 2, line(end: (w, 0pt), stroke: 0.6pt + dim-color))
  #place(top + center, dy: tick + 2pt, text(size: 8pt, fill: dim-color, style: "italic", label))
]

#let vdim(h, label) = box(width: 1.7em, height: h)[
  #place(top + left, line(end: (tick, 0pt), stroke: 0.6pt + dim-color))
  #place(bottom + left, line(end: (tick, 0pt), stroke: 0.6pt + dim-color))
  #place(top + left, dx: tick / 2, line(end: (0pt, h), stroke: 0.6pt + dim-color))
  #place(left + horizon, dx: -1pt, rotate(-90deg, reflow: true, text(
    size: 8pt, fill: dim-color, style: "italic", label,
  )))
]

#let swatch(w, h, color) = box(width: w, height: h, fill: color, radius: 3pt)

#let panel(title, formula, note, diagram, caption) = box(width: 100%)[
  #box(height: 2.6em, width: 100%)[
    #align(center + bottom, text(weight: "bold", size: 12.5pt, title))
  ]
  #v(0.3em)
  #box(height: 3.1cm, width: 100%)[
    #align(bottom, block(width: 100%)[
      #align(center, formula)
      #v(0.2em)
      #align(center, text(size: 8.7pt, fill: dim-color, note))
    ])
  ]
  #v(0.5em)
  #box(
    width: 100%,
    height: 6.6cm,
    stroke: (paint: rgb("#cccccc"), thickness: 0.6pt),
    radius: 6pt,
    inset: 0.9em,
    fill: rgb("#fafafa"),
  )[#align(center + horizon, diagram)]
  #v(0.55em)
  #align(center, text(size: 9.3pt, fill: rgb("#555555"), caption))
]

// ── Panel data ───────────────────────────────────────────────────────────────
// Concrete numbers, not derived from any `layout.typ` call -- but chosen so
// the arithmetic in each caption is exactly `A * shared-dimension + C`, the
// same relation `resolve-aspect` computes for these cases.

#let leaf-w = 3cm
#let leaf-h = 2cm // a = 1.5

#let h-shared = 2.2cm
#let a1 = 1.4
#let a2 = 0.9
#let h-gap = 0.6cm
#let w1 = a1 * h-shared
#let w2 = a2 * h-shared
#let w-total = w1 + w2 + h-gap

#let w-shared = 2.2cm
#let b1 = 1.1
#let b2 = 0.55
#let v-gap = 0.9cm
#let h1 = w-shared / b1
#let h2 = w-shared / b2
#let h-total = h1 + h2 + v-gap

#grid(
  columns: (1fr, 1fr, 1fr),
  gutter: 1.4cm,
  panel(
    [1. A leaf: the base relation],
    $ w = a (h - c_h) + c_w $,
    [a leaf has $c_h = c_w = 0$, so this is just $a = w\/h$],
    grid(
      columns: (auto, auto),
      rows: (auto, auto),
      gutter: 4pt,
      vdim(leaf-h, $h$), swatch(leaf-w, leaf-h, blue),
      [], hdim(leaf-w, $w$),
    ),
    [$a$ is the box's own aspect ratio -- the only number a leaf carries.],
  ),
  panel(
    [2. Horizontal group: widths add],
    $ A = sum_i a_i, quad C_w = "gap" dot (n - 1) $,
    [for leaf children ($c_(h_i) = c_(w_i) = 0$); the general sum also has $sum_i (c_(w_i) - a_i c_(h_i))$],
    grid(
      columns: (auto, auto),
      rows: (auto, auto, auto),
      gutter: 4pt,
      vdim(h-shared, $h$), stack(
        dir: ltr,
        spacing: h-gap,
        swatch(w1, h-shared, blue),
        swatch(w2, h-shared, orange),
      ),
      [], stack(
        dir: ltr,
        spacing: 0pt,
        hdim(w1, $w_1 = a_1 h$),
        hdim(h-gap, $"gap"$),
        hdim(w2, $w_2 = a_2 h$),
      ),
      [], hdim(w-total, $W = A h + C_w$),
    ),
    [All children share the row's height $h$; the gap becomes the group's constant offset $C_w$.],
  ),
  panel(
    [3. Vertical group: heights add reciprocally],
    $ A = 1 / (sum_i 1\/a_i), quad C_h = "gap" dot (n - 1) $,
    [for leaf children ($c_(h_i) = c_(w_i) = 0$); the general sum also has $sum_i (c_(h_i) - c_(w_i)\/a_i)$],
    grid(
      columns: (auto, auto, auto),
      rows: (auto, auto),
      gutter: 4pt,
      vdim(h-total, $H = A w + C_h$),
      stack(
        dir: ttb,
        spacing: 0pt,
        vdim(h1, $h_1 = w\/a_1$),
        vdim(v-gap, $"gap"$),
        vdim(h2, $h_2 = w\/a_2$),
      ),
      stack(
        dir: ttb,
        spacing: v-gap,
        swatch(w-shared, h1, blue),
        swatch(w-shared, h2, orange),
      ),
      [], [], hdim(w-shared, $w$),
    ),
    [All children share the column's width $w$; the harmonic sum is what makes narrow (large-$a$) children barely add height.],
  ),
)
