// lib.typ
// Main entry point for the Gmsh Typst package using CeTZ

#import "gmsh-parser.typ": parse-msh
#import "@preview/cetz:0.5.0"

#let default-color-map = (
  "1": blue.lighten(20%),
  "2": red.lighten(20%),
  "3": green.lighten(20%),
  "4": orange.lighten(20%),
  "5": purple.lighten(20%),
)

#let draw-mesh(
  msh-string,
  width: auto,
  height: auto,
  mesh-stroke: 0.5pt + white,
  fill-elements: true,
  color-map: default-color-map,
  show-node-numbers: false,
  show-element-numbers: false,
  show-axes: false,
  number-size: 6pt,
) = layout(size => {
  let mesh-data = parse-msh(msh-string)
  let nodes = mesh-data.nodes
  let elements = mesh-data.elements

  let min-x = 99999999.0
  let max-x = -99999999.0
  let min-y = 99999999.0
  let max-y = -99999999.0

  for (n-id, n-data) in nodes.pairs() {
    let x = float(n-data.at(0))
    let y = float(n-data.at(1))
    if x < min-x { min-x = x }
    if x > max-x { max-x = x }
    if y < min-y { min-y = y }
    if y > max-y { max-y = y }
  }

  let dx = max-x - min-x
  let dy = max-y - min-y
  if dx <= 0 { dx = 1.0 }
  if dy <= 0 { dy = 1.0 }

  let scale-len = 1cm

  // Convert relative ratios or fractions to absolute lengths based on container layout
  let resolve-len(l, ref-size) = {
    if type(l) == ratio { (l / 100%) * ref-size } else { l }
  }

  let final-width = if width == auto { resolve-len(100%, size.width) } else { resolve-len(width, size.width) }
  let final-height = if height != auto { resolve-len(height, size.height) } else { none }

  if height != auto and width != auto {
    scale-len = calc.min(final-width / dx, final-height / dy)
  } else if height != auto {
    scale-len = final-height / dy
  } else {
    // Default: Fit to width
    scale-len = final-width / dx
  }

  // To perfectly autogen boundaries relative to origin, we can also auto-center the grid
  // by calculating the bounding box offset. We'll wrap all drawing commands in a group
  // shifted by the center. But CetZ automatically tightens bounding boxes on compilation,
  // so just updating the coordinates directly using local lengths works!
  cetz.canvas(length: scale-len, {
    import cetz.draw: *

    if show-axes {
      // Background Grid
      let tick-count = 5
      let x-step = dx / tick-count
      let y-step = dy / tick-count

      // Draw grid lines
      for i in range(tick-count + 1) {
        let tx = min-x + i * x-step
        line((tx, min-y), (tx, max-y), stroke: 0.3pt + luma(200))
      }
      for i in range(tick-count + 1) {
        let ty = min-y + i * y-step
        line((min-x, ty), (max-x, ty), stroke: 0.3pt + luma(200))
      }

      // Bounding box
      rect((min-x, min-y), (max-x, max-y), stroke: 0.8pt + black)

      // Ticks and labels
      let tick-len-x = dx * 0.02
      let tick-len-y = dy * 0.02
      for i in range(tick-count + 1) {
        let tx = min-x + i * x-step
        line((tx, min-y), (tx, min-y - tick-len-y), stroke: 0.5pt + black)
        content((tx, min-y - tick-len-y * 2.5), text(size: 8pt)[#calc.round(tx, digits: 2)])
      }
      for i in range(tick-count + 1) {
        let ty = min-y + i * y-step
        line((min-x, ty), (min-x - tick-len-x, ty), stroke: 0.5pt + black)
        content((min-x - tick-len-x * 3.5, ty), text(size: 8pt)[#calc.round(ty, digits: 2)])
      }
    }

    for elm in elements {
      let elm-type = elm.type
      let elm-node-ids = elm.nodes
      let domain-id = elm.physical-tag
      if domain-id == 0 {
        domain-id = elm.geometrical-tag
      }

      let elm-fill = none
      if fill-elements {
        elm-fill = color-map.at(str(domain-id), default: blue.lighten(20%))
      }

      let cx = 0.0
      let cy = 0.0
      let valid-nodes = 0
      for n-id in elm-node-ids {
        let n-data = nodes.at(n-id, default: none)
        if n-data != none {
          cx += n-data.at(0)
          cy += n-data.at(1)
          valid-nodes += 1
        }
      }

      // Type 1: 2-node line
      if elm-type == 1 and elm-node-ids.len() == 2 {
        let n1 = nodes.at(elm-node-ids.at(0), default: none)
        let n2 = nodes.at(elm-node-ids.at(1), default: none)

        if n1 != none and n2 != none {
          line((n1.at(0), n1.at(1)), (n2.at(0), n2.at(1)), stroke: mesh-stroke)
        }
      } // Type 2: 3-node triangle
      else if elm-type == 2 and elm-node-ids.len() == 3 {
        let n1 = nodes.at(elm-node-ids.at(0), default: none)
        let n2 = nodes.at(elm-node-ids.at(1), default: none)
        let n3 = nodes.at(elm-node-ids.at(2), default: none)

        if n1 != none and n2 != none and n3 != none {
          line(
            (n1.at(0), n1.at(1)),
            (n2.at(0), n2.at(1)),
            (n3.at(0), n3.at(1)),
            close: true,
            stroke: mesh-stroke,
            fill: elm-fill,
          )
        }
      } // Type 3: 4-node quadrangle
      else if elm-type == 3 and elm-node-ids.len() == 4 {
        let n1 = nodes.at(elm-node-ids.at(0), default: none)
        let n2 = nodes.at(elm-node-ids.at(1), default: none)
        let n3 = nodes.at(elm-node-ids.at(2), default: none)
        let n4 = nodes.at(elm-node-ids.at(3), default: none)

        if n1 != none and n2 != none and n3 != none and n4 != none {
          line(
            (n1.at(0), n1.at(1)),
            (n2.at(0), n2.at(1)),
            (n3.at(0), n3.at(1)),
            (n4.at(0), n4.at(1)),
            close: true,
            stroke: mesh-stroke,
            fill: elm-fill,
          )
        }
      }

      if show-element-numbers and valid-nodes > 0 {
        content((cx / valid-nodes, cy / valid-nodes), text(size: number-size, fill: black)[#elm.id])
      }
    }

    if show-node-numbers {
      for (n-id, n-data) in nodes.pairs() {
        content((n-data.at(0), n-data.at(1)), text(size: number-size, fill: red, weight: "bold")[#n-id])
      }
    }
  })
})
