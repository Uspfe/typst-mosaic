# mosaic

Aspect-ratio-preserving grid layouts for photo mosaics.

Lays out grids of images (or arbitrary content) that fill an available box while
preserving every element's aspect ratio and keeping uniform gaps, and lets you either
build the layout tree yourself or have one searched for automatically.

## How it works

![Three panels: leaves keep their own aspect ratio at a shared row height; a horizontal group's children stack vertically inside it (and vice versa) with a uniform gap at every level; display-auto-layout searches recursive splits for the one whose areas best match given weights.](docs/how-it-works.png)

This figure is itself rendered with `display-content-tree` (panels 1–2) and
`display-auto-layout` (panel 3) — see `docs/figure.typ`, regenerate it with:

```bash
cd packages/mosaic && typst compile --root . docs/figure.typ docs/how-it-works.png --format png --ppi 300
```

### The sizing model

![Three panels annotated with dimension lines: a leaf's w = a(h - c_h) + c_w relation with a and h/w labeled; a horizontal group where widths add (A = sum of a_i) and the gap becomes the group's constant width offset C_w; a vertical group where heights add reciprocally (A = 1 / sum of 1/a_i) and the gap becomes the constant height offset C_h.](docs/model.png)

This is the "Model" section documented at the top of `src/layout.typ`, with each
symbol (`a`, `c_h`, `c_w`, `gap`) drawn as an actual measured length instead of left
abstract. See `docs/model.typ`, regenerate it with:

```bash
cd packages/mosaic && typst compile --root . docs/model.typ docs/model.png --format png --ppi 300
```

## Usage

```typ
#import "@local/mosaic:0.1.0": *

#context box(width: 100%, height: 6cm)[
  #display-content-tree(
    (image("a.jpg"), image("b.jpg")),
    axis: "horizontal",
    gap: 0.5em,
  )
]
```

### Manual layout: `display-content-tree`

Give it a nested array describing the tree; the axis (`"horizontal"`/`"vertical"`)
alternates automatically at every nesting level starting from the `axis` you pass in.
Each item in the array is one of:

- `content` — a leaf with its aspect ratio auto-measured (e.g. `image("a.jpg")`)
- `(body: ..., aspect: float)` — a leaf with an explicit aspect ratio
- `(body: ..., aspect: 0, constant-size: length)` — a fixed-size leaf; `constant-size`
  becomes the width in a horizontal row or the height in a vertical stack
- `(body: ..., stretchable_: true)` — a leaf that absorbs any leftover space along its
  parent's axis (combinable with `constant-size` for a minimum size)
- a nested `array` — a sub-group, whose axis is the opposite of its parent's

For finer control than the array shorthand gives you — different gaps per level, or
assembling a tree piecemeal — build content-dicts directly with `make-content-dict` /
`add-body-to-content-dict`, then call `resolve-aspect`, `resolve-stretchable`, and
`fit-content-dict` yourself. See `test/layout.typ` for worked examples of every case
above, including constant-size and stretchable elements in nested layouts.

### Automatic layout: `display-auto-layout`

Give it a *flat* list of items (same per-item dict format as above, plus an optional
`weight: float`, default `1`) and it enumerates every way to recursively split them into
an alternating horizontal/vertical tree, scores each one by how closely each item's
rendered area matches its weight (plus a reward for filling the available box), and
renders the best-scoring tree:

```typ
#context box(width: 100%, height: 5cm)[
  #display-auto-layout(
    (
      (body: image("a.jpg"), weight: 2),
      image("b.jpg"),
      image("c.jpg"),
    ),
    gap: 0.5em,
    selector: "1",
  )
]
```

`selector` picks which ranked tree to render — `"1"` is the best-scoring, `"2"` the
second-best, and so on; trailing dots (`"1."`, `"1.."`) step through equal-cost
reorderings of the same tree (e.g. mirroring which side the odd-one-out sits on).
`fill-weight` controls how strongly page-fill is rewarded relative to matching the given
weights, and `max-items` (default `8`) caps the item count, since the number of possible
trees grows very fast. See `test/auto-layout.typ` for examples of weights, ranking, and
stepping through symmetric variants.

## Local installation

This package isn't published to the Typst registry. To resolve it as `@local/mosaic:0.1.0`
(e.g. for editor/LSP support), symlink it into your local package directory:

```bash
mkdir -p "${XDG_DATA_HOME:-$HOME/.local/share}/typst/packages/local/mosaic"
ln -s "$(pwd)/packages/mosaic" "${XDG_DATA_HOME:-$HOME/.local/share}/typst/packages/local/mosaic/0.1.0"
```

Within this repo, `main.typ` imports it by relative path instead, so this step is optional
and only needed for editor tooling.
