# Fractal-Xplorer-Mac
Explore Mandelbrot and Julia fractals with OpenCL from the comfort of your Mac

* Choose which OpenCL device to use from the popup (hint: your GPU will likely be way faster than your CPU)
* Choose a colorization method from the other popup.
* Drag the slider to affect orbital values for some colorization methods.
* Drag and zoom both the Mandelbrot Set and corresponding Julia Set with click/drag/scroll wheel.
* Hold the command key down while mousing over the Mandelbrot Set to configure the Julia Set that corresponds to that location.
* Hold the command key down while mousing over the Julia Set to warp the Mandelbrot Set in interesting ways.

Take a look at Fractal.cl, there are a few different colorization options. Some use the orbit count for added zaniness.

Also, there's a build you can download and run (you might have to allow it to run un-codesigned)

Example:
![example image](https://raw.githubusercontent.com/jmenter/Fractal-Xplorer-Mac/develop/example.png "example")
