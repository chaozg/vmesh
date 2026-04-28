#import "lib.typ": draw-mesh

// = Gmsh mesh drawing with Typst and CeTZ

// Ensure you have generated the \`.msh\` file using MSH 2.2 format:
// \`gmsh t1.geo -2 -format msh2 -o t1.msh\`

#set page(paper: "a5",
          // width: auto,
          // height: auto, 
)

#lorem(25)

#align(center)[
  #let mesh-data = read("t4.msh2")
  #let my-colors = ("24": green.lighten(20%), "22": blue.lighten(20%), "3": blue)
  #draw-mesh(mesh-data,
             width: 8cm,
             height: auto,
             mesh-stroke: 0.05pt + gray,
             color-map: my-colors,
             show-node-numbers: false,
             show-element-numbers: false,
             number-size: 8pt,
            //  show-axes: true,
             )
]

#lorem(50)