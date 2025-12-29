# Picoterrain

Picoterrain is a small application that renders pseudorandom 3d terrain. It is written in the [psy programming language](https://github.com/harrand/psyc).

Only 64-bit windows is supported. Your graphics hardware + drivers must support Vulkan 1.3.

## How it works
- At application start, a gpu buffer is filled with terrain configuration data. Everytime you randomise the buffer is overwritten with new data.
- A hardcoded number of vertices is passed to gpuren to draw. The vertex shader will draw the vertices in the shape of a tessellated plane.
    - There is no vertex buffer, the positions of the vertices are fully shader-driven
    - The vertices are not indexed (this is bad)
- The height of each vertex is retrieved using simplex noise via [src/shaders/simplex.glsl](src/shaders/simplex.glsl). Sampling is also affected by the aforementioned terrain data.
- When you randomise the terrain again, new terrain data is generated randomly, and the gpu buffer is cosine-interpolated towards it over the next 5 seconds.

## Build Dependencies
- [psyc](https://github.com/harrand/psyc/releases/tag/1.4): you will need the psy compiler setup and ready to go to build the executable (specifically the 1.4 release)
- [gpuren](https://github.com/harrand/gpuren): my non-production-ready 3d graphics library. it uses vulkan under-the-hood.
    - so long as you clone recursively this is there by default.
- [psystdlib](https://github.com/harrand/psystdlib): a small runtime library that is not infact an official psy standard library.
    - so long as you clone recursively this is there by default.

## Build Instructions

Run the following command (current working directory **must** be the root directory of the clone):
```
psyc picoterrain.psy
```
(this uses the default build config, which is a debug build). the below command does the same thing:
```
psyc picoterrain.psy -b debug
```
and to create a release build (equivalent to -O3 and no debug information):
```
psyc picoterrain.psy -b release
```

If nothing goes wrong, `build/picoterrain.exe` should be spat out.

# Running
Run the generated `build/picoterrain.exe` executable. Working directory does not matter.

The application should open a fullscreen window. A random plane of terrain should be visible.

### Controls
- WASD moves the camera around.
- The camera rotation is controlled with your mouse. Not DPI aware so the user experience might be awful.
- Pressing 'r' will cause the terrain to randomise.
- Pressing 'esc' will close the application.
- Pressing '1' will change the terrain to Grassy Islands.
- Pressing '2' will change the terrain to Lava Landscape.
- Pressing '3' will change the terrain to Frosty Shelves.

### Passing in a seed

Running the executable like above will use a seed determined from some local machine timestamp, meaning the terrain will be different everytime.

You can however pass a seed directly to the executable:
```
./picoterrain 65530
```
This will run the executable using '65530' as a seed. It is intended for the same seed to produce identical results across different machines, so if you find a cool seed you can share it with someone else.

All other command-line arguments are ignored. The seed parameter is not sanity-checked either so if it doesn't parse cleanly as an integer/float the results may differ.
