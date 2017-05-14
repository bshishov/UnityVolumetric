# UnityVolumetric
Set of shaders and tools for volumetric rendering. Most of the shaders implemented with distance field raymarching. Shaders wew designed to do all computations inside itself, so no additional post processing, cameras, scripts are required. New shaders with custom functions, textures, lightning and blending could be easely designed by overriding some #defines inside the shader.

[Sample (GIF)](https://gfycat.com/ifr/PointlessDependableFieldspaniel)

For now, this is just an attempt of implementation of volumetric rendering techniques. I will not recommend to use it (in the current state) in your projects. However, I will appreciate any help with this.

### Features
 * Isosurface and translucent volumes
 *  All computation logic is inside object shaders (materials). No additional scripts or cameras required. You can create as many volumetric objects as you wish. Scale and rotate them as a standard geometry object.
 * Performs proper depth testing on basic geometry. So your tranclucent clouds will interact properly with objects overlapping them.
 * Basic lighthning (for now specular only). Which can also be used in translucent volumes.
 
### TODO
 * Implement ShadowCaster pass for shadow casting
 * Proper ZWriting for overlapping volumes
 * More ways to construct the volume, from 3d texture, from rotating 2d textures and so on
 * Reduce "ladder" artifacts even on SDF isosurfaces
 * Create unitypackage
 * Make configuration with shader compile features

# References
Here presented most of the resources used for implementations.

## General
 * [RTVG (real-time-volume-graphics.org) (slides)](http://www.real-time-volume-graphics.org/?page_id=28)
 * [RTVG Theory (slides)](http://www.cg.informatik.uni-siegen.de/data/Tutorials/EG2006/RTVG01_Theory.pdf)
 * [GPU Ray Marching of Distance Fields](http://www2.compute.dtu.dk/pubdb/views/edoc_download.php/6392/pdf/imm6392.pdf)
 * [Rendering worlds with two triangles (slides)](http://www.iquilezles.org/www/material/nvscene2008/rwwtt.pdf)
 * [GDC 2005. Volume rendering for games (slides)](http://http.download.nvidia.com/developer/presentations/2005/GDC/Sponsored_Day/GDC_2005_VolumeRenderingForGames.pdf)

## Complete shaders
 * [Shadertoy. Volumetric cloud](https://www.shadertoy.com/view/4ldGRf)
 * [Shadertoy. Alien Beacon](https://www.shadertoy.com/view/ld2SzK)

## Tutorials
 * [REALTIME VOLUMETRIC CLOUDS IN UNITY](http://www.blog.sirenix.net/blog/realtime-volumetric-clouds-in-unity)

## Raycasting and raytracing
 * [RTVG GPU Raycasting (slides)](http://www.cg.informatik.uni-siegen.de/data/Tutorials/EG2006/RTVG04_GPU_Raycasting.pdf)
 * [Ray Tracing Deterministic 3-D Fractals](http://graphics.cs.illinois.edu/sites/default/files/rtqjs.pdf)

## Illumination
 * [RTVG Local Illumination (slides)](http://www.cg.informatik.uni-siegen.de/data/Tutorials/EG2006/RTVG06_LocalIllumination.pdf)
 * [RTVG Global Illumination (slides)](http://www.cg.informatik.uni-siegen.de/data/Tutorials/EG2006/RTVG07_GlobalIllumination.pdf)

## Quality and performance
 * [RTVG Improving quality (slides)](http://www.cg.informatik.uni-siegen.de/data/Tutorials/EG2006/RTVG09_ImprovingQuality.pdf)
 * [RTVG Improving performace (slides)](http://www.cg.informatik.uni-siegen.de/data/Tutorials/EG2006/RTVG08_ImprovingPerformance.pdf)

## Application
 * [Instant Animated Grass (using volumetric approach)](https://www.cg.tuwien.ac.at/research/publications/2007/Habel_2007_IAG/Habel_2007_IAG-Preprint.pdf)

## Unity
 * [Blending](https://docs.unity3d.com/Manual/SL-Blend.html)
 * [3D Texture Example](https://forum.unity3d.com/threads/unity-4-3d-textures-volumes.148605/)
 * [PostProcessing Shader to read depth texture](http://williamchyr.com/2013/11/unity-shaders-depth-and-normal-textures/)
 * [(Catlikecoding) Custom materials and editors](http://catlikecoding.com/unity/tutorials/rendering/part-9/)
 * [(Catlikecoding) Semitransparent shadows](http://catlikecoding.com/unity/tutorials/rendering/part-12/)
 * [Raymarching Distance Fields: Concepts and Implementation in Unity](http://flafla2.github.io/2016/10/01/raymarching.html)
