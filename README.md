# Typst Mesh Package

This package allows you to seamlessly parse and render 2D and 3D finite element meshes exported from Gmsh directly in Typst!

It features an intelligent surface extraction algorithm for large 3D volume meshes, directional shading for depth perception, and a native painter's algorithm for proper depth occlusion!

## Usage

Export your mesh from Gmsh using the `.msh` version 2.2 format:
```bash
gmsh my_mesh.geo -3 -format msh2 -o my_mesh.msh2
```

Then, import the package and render it in your document:

```typst
#import "@preview/mesh:0.1.0": draw-mesh

#let mesh-data = read("my_mesh.msh2")

#figure(
  draw-mesh(
    mesh-data,
    pitch: -45deg,
    yaw: 45deg,
    light-direction: (-0.5, 0.5, 0.707),
    show-axes: true,
    show-domain-ids: true,
    show-node-ids: false,
    show-element-ids: false,
    id-size: 7pt,
    mesh-stroke: 0.1pt + black,
  ),
  caption: [My awesome 3D Mesh!],
)
```

## Features

- **2D & 3D Parsing:** Native parser for Gmsh MSH 2.2 files.
- **Surface Extraction:** Automatically strips internal volumes to render complex 3D meshes without crashing your compiler.
- **Directional Lighting:** Applies simulated lighting with `light-direction` to calculate normals and shading.
- **Depth Sorting:** Elements and axes are rendered using a Z-depth sorted Painter's Algorithm.
- **Physical Groups:** Fully supports coloring and labeling Gmsh Physical Groups.

## Configuration Parameters

- `width`, `height`: Base sizing (defaults to auto).
- `pitch`, `yaw`: Camera rotation angles.
- `light-direction`: A 3-element array `(x, y, z)` defining the directional light vector.
- `show-axes`: Boolean to display the 3D coordinate triad (X/Y/Z).
- `show-domain-ids`: Boolean to render floating text labels at the 3D center of mass for each physical group.
- `show-element-ids`, `show-node-ids`: Render IDs for individual geometric primitives.
- `id-size`: Text size for the IDs.
- `edge-stroke-map`: Dictionary mapping Domain ID to a custom stroke line style.
- `color-map`: Dictionary mapping Domain ID to a custom face fill color.
