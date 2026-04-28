#import "lib.typ": draw-mesh

// = Gmsh mesh drawing with Typst and CeTZ

// Ensure you have generated the \`.msh\` file using MSH 2.2 format:
// \`gmsh t1.geo -2 -format msh2 -o t1.msh\`

#align(center)[
  #let mesh-data = read("m1.msh2")
  #let my-colors = ("1": black.lighten(80%), "22": purple, "3": blue)
  #draw-mesh(mesh-data,
             width: 15cm,
             height: auto,
             mesh-stroke: 0.2pt + black,
            //  color-map: my-colors,
             show-node-numbers: true,
             show-element-numbers: true,
             number-size: 8pt
             )
]
