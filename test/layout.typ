#import "../src/layout.typ": *

#let img = "../assets/placeholder-landscape.jpg"

#set box(stroke: red)

= Simple Grouping

== Horizontal group (2 images)
#context {
  let cd = make-content-dict(
    image(img), image(img),
    layout-axis: "horizontal",
    gap: 0.5em,
  )
  let cd = resolve-aspect(cd)
  box(width: 100%, height: 5cm, stroke: black)[
    #layout(size => fit-content-dict(cd, size))
  ]
}

// 2. Simple vertical group (2 images)
== Vertical group (2 images)
#context {
  let cd = make-content-dict(
    image(img), image(img),
    layout-axis: "vertical",
    gap: 0.5em,
  )
  let cd = resolve-aspect(cd)
  box(width: 100%, height: 5cm, stroke: black)[
    #layout(size => fit-content-dict(cd, size))
  ]
}

// 3. Nested: horizontal top-level containing [leaf, leaf, vertical-sub → [leaf, leaf, horizontal-sub → [leaf, leaf]]]
= Nested Grouping

== Nested (horizontal top)
#context {
  let sub-h = make-content-dict(
    image(img), image(img),
    layout-axis: "horizontal",
    gap: 0.5em,
  )
  let sub-v = make-content-dict(
    image(img), image(img),
    layout-axis: "vertical",
    gap: 0.5em,
  )
  sub-v = add-body-to-content-dict(sub-v, sub-h)

  let cd = make-content-dict(
    image(img), image(img),
    layout-axis: "horizontal",
    gap: 0.5em,
  )
  cd = add-body-to-content-dict(cd, make-content-dict(image(img, width: 100%, height: 100%), aspect: 1.0))
  cd = add-body-to-content-dict(cd, sub-v)

  let cd = resolve-aspect(cd)
  box(width: 100%, height: 5cm, stroke: black)[
    #layout(size => fit-content-dict(cd, size))
  ]
}

== Nested (vertical top)
#context {
  let sub-v = make-content-dict(
    image(img), image(img),
    layout-axis: "vertical",
    gap: 0.5em,
  )
  let sub-h = make-content-dict(
    image(img), image(img),
    layout-axis: "horizontal",
    gap: 0.5em,
  )
  sub-h = add-body-to-content-dict(sub-h, sub-v)

  let cd = make-content-dict(
    image(img), image(img),
    layout-axis: "vertical",
    gap: 0.5em,
  )
  cd = add-body-to-content-dict(cd, make-content-dict(image(img, width: 100%, height: 100%), aspect: 1.0))
  cd = add-body-to-content-dict(cd, sub-h)

  let cd = resolve-aspect(cd)
  box(width: 100%, height: 5cm, stroke: black)[
    #layout(size => fit-content-dict(cd, size))
  ]
}

= Specify Layout with Tree Structure

== Manual tree construction

#context {
  let axis = "horizontal"
  let cd = parse-content-tree(
    (
      image(img),
      image(img),
      (
        image(img),
        (body: [Hello], aspect: 1.0),
      ),
      (body: image(img, width: 100%, height: 100%), aspect: 1.0),
    ),
    axis: axis,
    gap: 0.5em,
  )
  cd = resolve-aspect(cd)
  cd = resolve-stretchable(cd, axis) // can also be left out if no stretchable_ elements are used
  box(width: 100%, height: 5cm, stroke: black)[
    #layout(size => fit-content-dict(cd, size))
  ]
}

== `display-content-tree` helper function

#context {
  box(width: 100%, height: 2cm, stroke: black)[
    #display-content-tree(
      (
      image(img),
      image(img),
      (
        image(img),
        (body: [Hello], aspect: 1.0),
      ),
      (body: image(img, width: 100%, height: 100%), aspect: 1.0),
    ),
    )
  ]
}

= Constant-size Elements

== Constant-width in horizontal row (a=0, constant-size=1cm)
// Caption box takes exactly 1cm; both images share the remaining width.
#context {
  box(width: 100%, height: 4cm, stroke: black)[
    #display-content-tree(
      (
        image(img),
        (body: align(horizon)[1cm wide], aspect: 0, constant-size: 1cm),
        image(img),
      ),
      axis: "horizontal",
      gap: 0.5em,
    )
  ]
}

== Constant-height in vertical stack (a=0, constant-size=2cm)
// Label row takes exactly 2cm; both images share the remaining height.
#context {
  box(width: 100%, height: 6cm, stroke: black)[
    #display-content-tree(
      (
        image(img),
        (body: align(horizon)[2cm height], aspect: 0, constant-size: 2cm),
        image(img),
      ),
      axis: "vertical",
      gap: 0.5em,
    )
  ]
}

== Multiple constant-width elements in horizontal row
// Two caption boxes (3cm and 5cm) flanking an image.
#context {
  box(width: 100%, height: 4cm, stroke: black)[
    #display-content-tree(
      (
        (body: align(horizon)[3cm wide], aspect: 0, constant-size: 3cm),
        image(img),
        (body: align(horizon)[2cm wide], aspect: 0.0, constant-size: 2cm),
      ),
      axis: "horizontal",
      gap: 0.5em,
    )
  ]
}

== Image with constant offset
// Two caption boxes (3cm and 5cm) flanking an image.
#context {
  box(width: 100%, height: 4cm, stroke: black)[
    #display-content-tree(
      (
        (body: align(horizon)[3cm wide], aspect: 0, constant-size: 3cm),
        (body: image(img, width: auto, height: auto), constant-size: 1cm),
        (body: align(horizon)[2cm wide], aspect: 0.0, constant-size: 2cm),
      ),
      axis: "horizontal",
      gap: 0.5em,
    )
  ]
}


= Stretchable Elements

= H-stretchable: text absorbs leftover width in horizontal row
#context {
  box(width: 100%, height: 4cm, stroke: black)[
    #display-content-tree(
      (
        image(img),
        (body: align(horizon)[Stretchable element in _horizontal_ row takes up leftover _width_], aspect: 0.0, stretchable_: true),
      ),
      axis: "horizontal",
      gap: 0.5em,
    )
  ]
}

== V-stretchable: text absorbs leftover height in vertical stack
#context {
  box(width: 100%, height: 8cm, stroke: black)[
    #display-content-tree(
      (
        image(img),
        (body: align(horizon)[Stretchable element in _vertical_ stack takes up leftover _height_], aspect: 1.0, stretchable_: true),
      ),
      axis: "vertical",
      gap: 0.5em,
    )
  ]
}

== Two stretchable elements share leftover width equally
#context {
  box(width: 100%, height: 4cm, stroke: black)[
    #display-content-tree(
      (
        (body: align(horizon)[A], aspect: 0.0, stretchable_: true),
        image(img),
        (body: align(horizon)[B], aspect: 0.0, stretchable_: true),
      ),
      axis: "horizontal",
      gap: 0.5em,
    )
  ]
}

= Stretchables in a nested layout

== Streching along the horizontal/vertical direction only works if ALL elements in the row/column are stretchable.
// The second row contains only images (no stretchable_), so the ALL-predicate
// fails and the extra 10cm height is not distributed — content renders smaller.
#context {
  box(width: 100%, height: 10cm, stroke: black)[
    #display-content-tree(
      (
        (
          image(img),
          (body: align(horizon)[Stretchable element], aspect: 0.0, constant-size: 2cm, stretchable_: true),
        ),
        (
          image(img),
          (body: align(horizon)[Stretchable element], aspect: 0.0, constant-size: 2cm, stretchable_: true),
          image(img),
        ),
      ),
      axis: "vertical",
      gap: 0.5em,
    )
  ]
}

== No horizontal stretching is applied as the first row is not stretchable
// The second row contains only images (no stretchable_), so the ALL-predicate
// fails and the extra 10cm height is not distributed — content renders smaller.
#context {
  box(width: 100%, height: 10cm, stroke: black)[
    #display-content-tree(
      (
        (
          image(img),
          (body: align(horizon)[Not stretchable element], aspect: 0.0, constant-size: 2cm, stretchable_: false),
        ),
        (
          image(img),
          (body: align(horizon)[Stretchable element], aspect: 0.0, constant-size: 2cm, stretchable_: true),
          image(img),
        ),
      ),
      axis: "vertical",
      gap: 0.5em,
    )
  ]
}

= Same rules apply for vertical stretching
// The second row contains only images (no stretchable_), so the ALL-predicate
// fails and the extra 10cm height is not distributed — content renders smaller.
#context {
  box(width: 7cm, height: 10cm, stroke: black)[
    #display-content-tree(
      (
        (
          image(img),
          (body: align(horizon)[Stretchable], aspect: 0.0, constant-size: 1cm, stretchable_: true),
          image(img),
        ),
        (
          image(img),
          image(img),
          (body: align(horizon)[Stretchable], aspect: 0.0, constant-size: 1cm, stretchable_: true),
        ),
      ),
      axis: "horizontal",
      gap: 0.5em,
    )
  ]
}