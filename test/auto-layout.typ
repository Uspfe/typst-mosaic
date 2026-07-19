#import "../src/auto-layout.typ": *

#let img = "../assets/20250811_092332_v1.jpg"

#set box(stroke: red)

= Simple: flat list, equal weights

== 3 images, best layout (selector "1")
// All weights default to 1, so the search just looks for the tree that best
// fills the box while keeping all three areas as equal as possible. The
// top-level axis (horizontal vs. vertical) is not given by the caller —
// the search tries both and picks whichever scores better.
#context {
  box(width: 100%, height: 5cm, stroke: black)[
    #display-auto-layout(
      (image(img), image(img), image(img)),
      gap: 0.5em,
      selector: "1",
    )
  ]
}

== 4 images, best layout
#context {
  box(width: 100%, height: 5cm, stroke: black)[
    #display-auto-layout(
      (image(img), image(img), image(img), image(img)),
      gap: 0.5em,
      selector: "1",
    )
  ]
}

== A tall, narrow box naturally leads to a vertical-rooted tree
// Same 3 images as above, only the box shape changes — since the axis isn't
// fixed, a tall/narrow box makes the vertical-rooted search win on its own.
#context {
  box(width: 4cm, height: 12cm, stroke: black)[
    #display-auto-layout(
      (image(img), image(img), image(img)),
      gap: 0.5em,
      selector: "1",
    )
  ]
}

= Weights: steering how much area each item gets

== One item weighted much higher than the others
// The weight-3 image should end up noticeably larger than the two weight-1
// images. It's placed at an edge on purpose: contiguous partitioning keeps
// photos in their given order, so a *middle* item can never be isolated as
// the sole "big" occupant without breaking that order — only edge items can.
#context {
  box(width: 100%, height: 5cm, stroke: black)[
    #display-auto-layout(
      (
        (body: image(img), weight: 3),
        image(img),
        image(img),
      ),
      gap: 0.5em,
      selector: "1",
      fill-weight: 1.0,
    )
  ]
}

== All weights different (1, 2, 4)
#context {
  box(width: 100%, height: 5cm, stroke: black)[
    #display-auto-layout(
      (
        image(img),
        (body: image(img), weight: 2),
        (body: image(img), weight: 4),
      ),
      gap: 0.5em,
      selector: "1",
    )
  ]
}

= Ranking: stepping through different tree shapes

== Rank 1 vs. rank 2 vs. rank 3 for the same 4 items
// Later ranks are worse fits (either less area-matched or less page-filling)
// but still valid layout trees.
#context {
  box(width: 100%, height: 5cm, stroke: black)[
    #display-auto-layout(
      (image(img), image(img), image(img), image(img)),
      gap: 0.5em,
      selector: "1",
    )
  ]
}
#context {
  box(width: 100%, height: 5cm, stroke: black)[
    #display-auto-layout(
      (image(img), image(img), image(img), image(img)),
      gap: 0.5em,
      selector: "2",
    )
  ]
}
#context {
  box(width: 100%, height: 5cm, stroke: black)[
    #display-auto-layout(
      (image(img), image(img), image(img), image(img)),
      gap: 0.5em,
      selector: "3",
    )
  ]
}

== Out-of-range rank clamps to the worst available tree
#context {
  box(width: 100%, height: 5cm, stroke: black)[
    #display-auto-layout(
      (image(img), image(img), image(img), image(img)),
      gap: 0.5em,
      selector: "9999",
    )
  ]
}

= Symmetries: same rank, different mirrored variants

== Rank 1 and its reflection variants ("1", "1.", "1..")
// Each variant has exactly the same cost (same areas per item) as rank 1 —
// only the left-right/top-bottom order of the mirrored subtrees changes.
#context {
  box(width: 100%, height: 5cm, stroke: black)[
    #display-auto-layout(
      (
        (body: image(img), weight: 2),
        image(img),
        image(img),
        image(img),
      ),
      gap: 0.5em,
      selector: "1",
    )
  ]
}
#context {
  box(width: 100%, height: 5cm, stroke: black)[
    #display-auto-layout(
      (
        (body: image(img), weight: 2),
        image(img),
        image(img),
        image(img),
      ),
      gap: 0.5em,
      selector: "1.",
    )
  ]
}
#context {
  box(width: 100%, height: 5cm, stroke: black)[
    #display-auto-layout(
      (
        (body: image(img), weight: 2),
        image(img),
        image(img),
        image(img),
      ),
      gap: 0.5em,
      selector: "1..",
    )
  ]
}

== Extra dots wrap around instead of erroring
// If a tree only has few internal nodes, its variant count (2^m) is small;
// stepping past it just cycles back — this uses many dots on a small tree.
#context {
  box(width: 100%, height: 5cm, stroke: black)[
    #display-auto-layout(
      (image(img), image(img)),
      gap: 0.5em,
      selector: "1........",
    )
  ]
}

= Constant-size elements

== Constant-width caption, wide box (horizontal root wins)
// The caption occupies exactly 2cm of *width* here; the remaining images
// share the rest per their weights. Which axis actually wins is up to the
// search — a wide box favors a horizontal root, where constant-size means a
// fixed width.
#context {
  box(width: 100%, height: 4cm, stroke: black)[
    #display-auto-layout(
      (
        image(img),
        (body: align(horizon)[2cm caption], aspect: 0, constant-size: 2cm),
        image(img),
      ),
      gap: 0.5em,
      selector: "1",
    )
  ]
}

== Same caption, tall box (vertical root wins, constant-size becomes height)
// Same input, only the box is tall/narrow now. `materialize-leaf` resolves
// constant-size against whichever axis the *chosen* tree actually puts the
// caption's parent group in — here that's vertical, so it becomes a fixed
// height instead of a fixed width.
#context {
  box(width: 5cm, height: 10cm, stroke: black)[
    #display-auto-layout(
      (
        image(img),
        (body: align(horizon)[2cm caption], aspect: 0, constant-size: 2cm),
        image(img),
      ),
      gap: 0.5em,
      selector: "1",
    )
  ]
}

= Stretchable elements

== Stretchable caption absorbs leftover space
// Stretch budgets aren't modeled during the search itself (search only
// scores the base, no-budget layout) but the final chosen tree still goes
// through the real resolve-stretchable/fit-content-dict, so the caption
// visibly grows to fill leftover space here.
#context {
  box(width: 100%, height: 5cm, stroke: black)[
    #display-auto-layout(
      (
        image(img),
        (body: align(horizon)[Stretchable caption], aspect: 0.0, stretchable_: true),
        image(img),
      ),
      gap: 0.5em,
      selector: "1",
    )
  ]
}

= Everything combined

== Weights + constant-size + stretchable, stepping through rank and symmetry
#let combined-items = (
  (body: image(img), weight: 3),
  image(img),
  (body: align(horizon)[Fixed 2cm], aspect: 0, constant-size: 2cm),
  (body: align(horizon)[Stretches], aspect: 0.0, stretchable_: true),
  image(img),
)
#context {
  box(width: 100%, height: 6cm, stroke: black)[
    #display-auto-layout(combined-items, gap: 0.5em, selector: "1")
  ]
}
#context {
  box(width: 100%, height: 6cm, stroke: black)[
    #display-auto-layout(combined-items, gap: 0.5em, selector: "1.")
  ]
}
#context {
  box(width: 100%, height: 6cm, stroke: black)[
    #display-auto-layout(combined-items, gap: 0.5em, selector: "2")
  ]
}
