#import "lib.typ": draw-mesh

#set page(
  paper: "a5",
  // width: auto,
  // height: auto,
)

Make sure you have generated the `.msh` file using Gmsh's `.msh` 2.2 format with
\`gmsh t1.geo -2 -format msh2 -o t1.msh\`.

The Mesh package allows one to read a `.msh` file and draw it as a Typst figure through CeTZ, with options for customizing the appearance of the mesh.

#let mesh-data = read("t4.msh2")
#let my-colors = ("24": blue.lighten(20%), "22": red.lighten(20%), "3": blue)

#figure(
  draw-mesh(
    mesh-data,
    width: 4.5cm,
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

As we can clearly see in @my-mesh-plot, the mesh has been successfully loaded and rendered. As shown in @my-mesh-plot-2, we can also turn on the display of node and element numbers.

#let mesh-data-2 = read("m1.msh2")

#figure(
  draw-mesh(
    mesh-data-2,
    width: 5.5cm,
    height: auto,
    // mesh-stroke: 0.05pt + white,
    // color-map: my-colors,
    show-node-numbers: true,
    show-element-numbers: true,
    number-size: 7pt,
    // show-axes: true,
  ),
  caption: [A demo `.msh` file (`m1.msh2`).],
) <my-mesh-plot-2>
