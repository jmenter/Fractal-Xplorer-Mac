# Fractal-Xplorer-Mac
Explore Mandelbrot and Julia fractals with OpenCL on your Mac

Drag and zoom both the Mandelbrot Set and corresponding Julia Set. Hold the command key down while mousing over the Mandelbrot Set to configure the Julia Set that corresponds to that location.

Uses OpenCL and your Mac's GPU to do the calculations if possible (fallback to CPU) so it's pretty fast.

Take a look at Fractal.cl, there are a few different colorization options. Some use the orbit count for added zaniness.

Example:
![example image](https://raw.githubusercontent.com/jmenter/Fractal-Xplorer-Mac/develop/example.png "example")
