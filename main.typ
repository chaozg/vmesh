#import "lib.typ": draw-mesh

// = Gmsh mesh drawing with Typst and CeTZ

// Ensure you have generated the \`.msh\` file using MSH 2.2 format:
// \`gmsh t1.geo -2 -format msh2 -o t1.msh\`

#align(center)[
  #let mesh-data = read("t4.msh2")
  #let my-colors = ("24": black.lighten(80%), "22": purple, "3": blue)
  #draw-mesh(mesh-data,
             scale-factor: 50.0,
             mesh-stroke: 0.2pt + black,
             color-map: my-colors
             )
]
