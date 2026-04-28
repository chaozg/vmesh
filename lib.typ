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

#let project-3d(pt, pitch, yaw) = {
  let (x, y, z) = pt
  
  let x1 = x * calc.cos(yaw) - y * calc.sin(yaw)
  let y1 = x * calc.sin(yaw) + y * calc.cos(yaw)
  let z1 = z
  
  let x2 = x1
  let y2 = y1 * calc.cos(pitch) - z1 * calc.sin(pitch)
  let z2 = y1 * calc.sin(pitch) + z1 * calc.cos(pitch)
  
  ((x2, y2), z2)
}

#let draw-mesh(
  msh-string,
  width: auto,
  height: auto,
  mesh-stroke: 0.5pt + white,
  fill-elements: true,
  color-map: default-color-map,
  edge-stroke-map: (:),
  pitch: 0deg,
  yaw: 0deg,
  show-node-numbers: false,
  show-element-numbers: false,
  show-axes: false,
  number-size: 6pt,
) = layout(size => {
  let mesh-data = parse-msh(msh-string)
  let nodes = mesh-data.nodes
  let elements = mesh-data.elements

  let projected-nodes = (:)
  for (n-id, n-data) in nodes.pairs() {
    let pt = (float(n-data.at(0)), float(n-data.at(1)), float(n-data.at(2)))
    projected-nodes.insert(n-id, project-3d(pt, pitch, yaw))
  }

  let x-vals = projected-nodes.values().map(p => p.at(0).at(0))
  let y-vals = projected-nodes.values().map(p => p.at(0).at(1))

  let min-x = if x-vals.len() > 0 { calc.min(..x-vals) } else { 0.0 }
  let max-x = if x-vals.len() > 0 { calc.max(..x-vals) } else { 1.0 }
  let min-y = if y-vals.len() > 0 { calc.min(..y-vals) } else { 0.0 }
  let max-y = if y-vals.len() > 0 { calc.max(..y-vals) } else { 1.0 }

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

    let render-elements = ()
    let all-faces = ()

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

      if elm-type in (1, 2, 3) {
         all-faces.push((nodes: elm-node-ids, type: elm-type, domain: domain-id, fill: elm-fill, id: elm.id, is-3d: false))
      } else if elm-type == 4 and elm-node-ids.len() == 4 { // Tetrahedron
         let n = elm-node-ids
         all-faces.push((nodes: (n.at(0), n.at(1), n.at(2)), type: 2, domain: domain-id, fill: elm-fill, id: elm.id, is-3d: true))
         all-faces.push((nodes: (n.at(0), n.at(2), n.at(3)), type: 2, domain: domain-id, fill: elm-fill, id: elm.id, is-3d: true))
         all-faces.push((nodes: (n.at(0), n.at(3), n.at(1)), type: 2, domain: domain-id, fill: elm-fill, id: elm.id, is-3d: true))
         all-faces.push((nodes: (n.at(1), n.at(3), n.at(2)), type: 2, domain: domain-id, fill: elm-fill, id: elm.id, is-3d: true))
      } else if elm-type == 5 and elm-node-ids.len() == 8 { // Hexahedron
         let n = elm-node-ids
         all-faces.push((nodes: (n.at(0), n.at(1), n.at(5), n.at(4)), type: 3, domain: domain-id, fill: elm-fill, id: elm.id, is-3d: true))
         all-faces.push((nodes: (n.at(1), n.at(2), n.at(6), n.at(5)), type: 3, domain: domain-id, fill: elm-fill, id: elm.id, is-3d: true))
         all-faces.push((nodes: (n.at(2), n.at(3), n.at(7), n.at(6)), type: 3, domain: domain-id, fill: elm-fill, id: elm.id, is-3d: true))
         all-faces.push((nodes: (n.at(3), n.at(0), n.at(4), n.at(7)), type: 3, domain: domain-id, fill: elm-fill, id: elm.id, is-3d: true))
         all-faces.push((nodes: (n.at(0), n.at(1), n.at(2), n.at(3)), type: 3, domain: domain-id, fill: elm-fill, id: elm.id, is-3d: true))
         all-faces.push((nodes: (n.at(4), n.at(5), n.at(6), n.at(7)), type: 3, domain: domain-id, fill: elm-fill, id: elm.id, is-3d: true))
      } else if elm-type == 6 and elm-node-ids.len() == 6 { // Prism
         let n = elm-node-ids
         all-faces.push((nodes: (n.at(0), n.at(1), n.at(2)), type: 2, domain: domain-id, fill: elm-fill, id: elm.id, is-3d: true))
         all-faces.push((nodes: (n.at(3), n.at(4), n.at(5)), type: 2, domain: domain-id, fill: elm-fill, id: elm.id, is-3d: true))
         all-faces.push((nodes: (n.at(0), n.at(1), n.at(4), n.at(3)), type: 3, domain: domain-id, fill: elm-fill, id: elm.id, is-3d: true))
         all-faces.push((nodes: (n.at(1), n.at(2), n.at(5), n.at(4)), type: 3, domain: domain-id, fill: elm-fill, id: elm.id, is-3d: true))
         all-faces.push((nodes: (n.at(2), n.at(0), n.at(3), n.at(5)), type: 3, domain: domain-id, fill: elm-fill, id: elm.id, is-3d: true))
      } else if elm-type == 7 and elm-node-ids.len() == 5 { // Pyramid
         let n = elm-node-ids
         all-faces.push((nodes: (n.at(0), n.at(1), n.at(2), n.at(3)), type: 3, domain: domain-id, fill: elm-fill, id: elm.id, is-3d: true))
         all-faces.push((nodes: (n.at(0), n.at(1), n.at(4)), type: 2, domain: domain-id, fill: elm-fill, id: elm.id, is-3d: true))
         all-faces.push((nodes: (n.at(1), n.at(2), n.at(4)), type: 2, domain: domain-id, fill: elm-fill, id: elm.id, is-3d: true))
         all-faces.push((nodes: (n.at(2), n.at(3), n.at(4)), type: 2, domain: domain-id, fill: elm-fill, id: elm.id, is-3d: true))
         all-faces.push((nodes: (n.at(3), n.at(0), n.at(4)), type: 2, domain: domain-id, fill: elm-fill, id: elm.id, is-3d: true))
      }
    }

    let face-meta = (:)
    let face-data = (:)

    for f in all-faces {
      let sorted-n = f.nodes.sorted()
      let key = sorted-n.join("-")
      
      let meta = face-meta.at(key, default: (count: 0, is-explicit: false))
      if f.is-3d {
        meta.count += 1
      } else {
        meta.is-explicit = true
      }
      face-meta.insert(key, meta)
      
      if (not f.is-3d) or (key not in face-data) {
        face-data.insert(key, (nodes: f.nodes, type: f.type, domain: f.domain, fill: f.fill, id: f.id))
      }
    }

    for (key, meta) in face-meta.pairs() {
      if meta.is-explicit or meta.count == 1 {
        let fd = face-data.at(key)
        let elm-nodes-proj = fd.nodes.map(id => projected-nodes.at(id, default: none)).filter(c => c != none)

        if elm-nodes-proj.len() == fd.nodes.len() and elm-nodes-proj.len() > 0 {
          let depth = elm-nodes-proj.map(c => c.at(1)).sum() / elm-nodes-proj.len()
          let pts = elm-nodes-proj.map(c => c.at(0))
          
          render-elements.push((
            depth: depth,
            pts: pts,
            elm-type: fd.type,
            domain-id: fd.domain,
            elm-fill: fd.fill,
            elm-id: fd.id
          ))
        }
      }
    }

    let sorted-elements = render-elements.sorted(key: e => e.depth)

    for re in sorted-elements {
      let pts = re.pts
      let elm-type = re.elm-type
      let domain-id = re.domain-id
      let elm-fill = re.elm-fill

      if elm-type == 1 and pts.len() == 2 {
        let e-stroke = edge-stroke-map.at(str(domain-id), default: mesh-stroke)
        line(..pts, stroke: e-stroke)
      } else if (elm-type == 2 and pts.len() == 3) or (elm-type == 3 and pts.len() == 4) {
        line(..pts, close: true, stroke: mesh-stroke, fill: elm-fill)
      }

      if show-element-numbers {
        let cx = pts.map(c => c.at(0)).sum() / pts.len()
        let cy = pts.map(c => c.at(1)).sum() / pts.len()
        content((cx, cy), text(size: number-size, fill: luma(80), style: "italic")[#re.elm-id])
      }
    }

    if show-node-numbers {
      for (n-id, n-data) in projected-nodes.pairs() {
        content(n-data.at(0), text(size: number-size, fill: black, weight: "bold")[#n-id])
      }
    }
  })
})
