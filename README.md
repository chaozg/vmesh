<img src="assets/demo_typst.png" width="100" title="demo typst" alt="demo typst"/>

`mesh` is a [Typst](https://github.com/typst/typst) package for rendering [Gmsh](https://gmsh.info/) files.

## Usage

Export your mesh from Gmsh using the version 2.2 format:
```bash
gmsh typst.geo -3 -format msh2 -o typst.msh2
```

Then, import the package and render it in your document:

```typst
#import "../src/lib.typ": draw-mesh

#let mesh-data = read("assets/typst.msh2")

#figure(
  draw-mesh(
    mesh-data,
    width: 1.5cm,
  ),
)
```

## Examples
<img src="assets/demo_2d_details.png" width="200" title="demo 2d" alt="demo 2d"/>

<img src="assets/demo_3d.png" width="400" title="3d mesh" alt="3d mesh"/>

## Dependencies
- [CeTZ](https://github.com/cetz-package/cetz)