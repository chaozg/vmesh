#import "lib.typ": draw-mesh
#import "@preview/subpar:0.2.2"

#set page(
  paper: "a5",
  // width: auto,
  // height: auto,
)
#set par(justify: true)

Make sure you have generated the `.msh` file using Gmsh's `.msh` 2.2 format with
\`gmsh t1.geo -2 -format msh2 -o t1.msh\`.

The Mesh package allows one to read a `.msh` file and draw it as a Typst figure through CeTZ, with options for customizing the appearance of the mesh.

// #let mesh-data = read("t4.msh2")
#let mesh-data = read("triangleHole01.msh2")

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
    show-axes: true,
  ),
  caption: [A demo `.msh` file (`t4.msh2`) from Gmsh.],
) <my-mesh-plot>

As we can clearly see in @my-mesh-plot, the mesh has been successfully loaded and rendered. As shown in @my-mesh-plot-2, we can also turn on the display of node and element numbers.

#let mesh-data-2 = read("m1.msh2")
#let my-colors = ("1": blue.lighten(20%), "2": red.lighten(20%), "3": green.lighten(20%))
#let my-edges = ("4": 4pt + red, "5": 4pt + purple, "6": 4pt + green)

#figure(
  draw-mesh(
    mesh-data-2,
    width: 5.5cm,
    height: auto,
    edge-stroke-map: my-edges,
    mesh-stroke: 0.05pt + black,
    // color-map: my-colors,
    // show-domain-numbers: true,
    show-node-numbers: true,
    show-element-numbers: true,
    number-size: 7pt,
    show-axes: true,
  ),
  caption: [A demo `.msh` file (`m1.msh2`) with highlighted boundaries.],
) <my-mesh-plot-2>

As shown in @my-mesh-plot-3, the package also supports true 3D meshes using an automatic surface extraction algorithm!

#let mesh-data-3 = read("t14.msh2")
#let mesh-data-4 = read("t5.msh2")
#let mesh-data-5 = read("ball8.msh2")
#let mesh-data-6 = read("part_sphere.msh2")

#figure(
  draw-mesh(
    mesh-data-3,
    light-direction: (-0.5, 0.5, 0.7),
    width: 7cm,
    height: auto,
    pitch: -45deg,
    yaw: 45deg,
    mesh-stroke: 0.1pt + black,
    // show-axes: true,
    show-domain-numbers: false,
    show-node-numbers: false,
    show-element-numbers: false,
  ),
  caption: [A demo `.msh` file (`t3.msh`) projected in 3D with realistic lighting.],
) <my-mesh-plot-3>

#subpar.grid(
  figure(
    draw-mesh(
      mesh-data-4,
      light-direction: (-0.5, 0.5, 0.7),
      width: 3cm,
      height: auto,
      pitch: -45deg,
      yaw: 45deg,
      mesh-stroke: 0.1pt + black,
      // show-axes: true,
      show-domain-numbers: false,
      show-node-numbers: false,
      show-element-numbers: false,
    ),
    // caption: [
    //   An image of the andromeda galaxy.
    // ],
  ),
  <a>,

  figure(
    draw-mesh(
      mesh-data-5,
      light-direction: (-0.5, 0.5, 0.7),
      width: 3cm,
      height: auto,
      pitch: -45deg,
      yaw: 45deg,
      mesh-stroke: 0.1pt + black,
      // show-axes: true,
      show-domain-numbers: false,
      show-node-numbers: false,
      show-element-numbers: false,
    ),
    // caption: [
    //   A sunset illuminating the sky above a mountain range.
    // ],
  ),
  <b>,

  figure(
    draw-mesh(
      mesh-data-6,
      light-direction: (-0.5, -0.5, 0.7),
      width: 3cm,
      height: auto,
      pitch: -125deg,
      yaw: 45deg,
      mesh-stroke: 0.1pt + black,
      // show-axes: true,
      show-domain-numbers: false,
      show-node-numbers: false,
      show-element-numbers: false,
    ),
    // caption: [
    //   A sunset illuminating the sky above a mountain range.
    // ],
  ),
  <b>,

  columns: (1fr, 1fr, 1fr),
  caption: [A figure composed of two sub figures.],
  label: <full>,
)
