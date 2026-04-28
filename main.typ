#import "lib.typ": draw-mesh

// = Gmsh mesh drawing with Typst and CeTZ

// Ensure you have generated the \`.msh\` file using MSH 2.2 format:
// \`gmsh t1.geo -2 -format msh2 -o t1.msh\`

#set page(
  paper: "a5",
  // width: auto,
  // height: auto,
)

The Mesh package allows one to read a `.msh` file and draw it as a Typst figure through CeTZ, with options for customizing the appearance of the mesh.

#let mesh-data = read("t4.msh2")
#let my-colors = ("24": blue.lighten(20%), "22": red.lighten(20%), "3": blue)

#figure(
  draw-mesh(
    mesh-data,
    width: 5cm,
    height: auto,
    // mesh-stroke: 0.05pt + white,
    // color-map: my-colors,
    // show-node-numbers: true,
    // show-element-numbers: true,
    number-size: 5pt,
    // show-axes: true,
  ),
  caption: [A demo `.msh` file (`t4.msh2`) from Gmsh.],
) <my-mesh-plot>

As we can clearly see in @my-mesh-plot, the mesh has been successfully loaded and rendered.
