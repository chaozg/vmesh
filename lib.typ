// lib.typ
// Main entry point for the Gmsh Typst package using CeTZ

#import "gmsh-parser.typ": parse-msh
#import "@preview/cetz:0.5.0"

#let default-color-map = (
  "1": red.lighten(30%),
  "2": blue.lighten(30%),
  "3": green.lighten(30%),
  "4": orange.lighten(30%),
  "5": purple.lighten(30%),
)

#let draw-mesh(msh-string, scale-factor: 1.0, mesh-stroke: 0.5pt + black, fill-elements: true, color-map: default-color-map) = {
  let mesh-data = parse-msh(msh-string)
  let nodes = mesh-data.nodes
  let elements = mesh-data.elements
  
  cetz.canvas({
    import cetz.draw: *
    
    for elm in elements {
      let elm-type = elm.type
      let elm-node-ids = elm.nodes
      let domain-id = elm.physical-tag
      if domain-id == 0 {
        domain-id = elm.geometrical-tag
      }
      
      let elm-fill = none
      if fill-elements {
        elm-fill = color-map.at(str(domain-id), default: gray.lighten(50%))
      }
      
      // Type 1: 2-node line
      if elm-type == 1 and elm-node-ids.len() == 2 {
        let n1 = nodes.at(elm-node-ids.at(0), default: none)
        let n2 = nodes.at(elm-node-ids.at(1), default: none)
        
        if n1 != none and n2 != none {
          line((n1.at(0) * scale-factor, n1.at(1) * scale-factor), 
               (n2.at(0) * scale-factor, n2.at(1) * scale-factor),
               stroke: mesh-stroke)
        }
      }
      
      // Type 2: 3-node triangle
      else if elm-type == 2 and elm-node-ids.len() == 3 {
        let n1 = nodes.at(elm-node-ids.at(0), default: none)
        let n2 = nodes.at(elm-node-ids.at(1), default: none)
        let n3 = nodes.at(elm-node-ids.at(2), default: none)
        
        if n1 != none and n2 != none and n3 != none {
          line((n1.at(0) * scale-factor, n1.at(1) * scale-factor), 
               (n2.at(0) * scale-factor, n2.at(1) * scale-factor),
               (n3.at(0) * scale-factor, n3.at(1) * scale-factor),
               close: true,
               stroke: mesh-stroke,
               fill: elm-fill)
        }
      }
      
      // Type 3: 4-node quadrangle
      else if elm-type == 3 and elm-node-ids.len() == 4 {
        let n1 = nodes.at(elm-node-ids.at(0), default: none)
        let n2 = nodes.at(elm-node-ids.at(1), default: none)
        let n3 = nodes.at(elm-node-ids.at(2), default: none)
        let n4 = nodes.at(elm-node-ids.at(3), default: none)
        
        if n1 != none and n2 != none and n3 != none and n4 != none {
          line((n1.at(0) * scale-factor, n1.at(1) * scale-factor), 
               (n2.at(0) * scale-factor, n2.at(1) * scale-factor),
               (n3.at(0) * scale-factor, n3.at(1) * scale-factor),
               (n4.at(0) * scale-factor, n4.at(1) * scale-factor),
               close: true,
               stroke: mesh-stroke,
               fill: elm-fill)
        }
      }
    }
  })
}
