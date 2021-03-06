IcestoneSL
==========

A library to extends [IceSL](http://webloria.loria.fr/~slefebvr/icesl/) with higher-level primitives.

[IceSL](http://webloria.loria.fr/~slefebvr/icesl/) is a modeler *à la* [OpenSCAD](http://www.openscad.org/) but the programming language is [Lua](http://www.lua.org/). But it is also a slicer with advanced features such as dual colors hiding defaults.

[IcestoneSL](https://github.com/loic-fejoz/IcestoneSL) provides same primitives as [Shapes.inc](http://www.povray.org/documentation/view/3.7.0/468/) from [POVRay](http://www.povray.org/).

It will provide more in the future. Stay tune!

Examples
--------

![Samples shapes provided by IcestoneSL](doc/images/shapes.png "IcestoneSL/povray primitive shapes")

All those shapes are generated by calling a unique primitive (really lua function) build upon IceSL's one.

Installation
------------

TODO

Usage
-----

Simply add `require "povray";` on top of your file.

See [Luadoc Documentation](http://htmlpreview.github.io?https://github.com/loic-fejoz/IcestoneSL/blob/master/doc/luadoc/files/src/main/lua/povray.html) for details.

Here is the code producing the image above :

	emit(povray_box(v(5,5,0), v(10,10,5)));
	emit(povray_cone(v(20,20,0),3,v(20,20,10),1));
	emit(povray_cylinder(v(-10,20,0),v(-10,20,10),3));
	emit(povray_round_cylinder(v(10,20,0),v(10,20,10),3,1));
	emit(povray_wire_box(v(20,10,0), v(25,15,10), 0.5));
	emit(povray_round_box(v(-5,-5,0), v(0,0,5), 1));
	emit(translate(-5, -10, 1) * torus(4,1));
	emit(povray_round_cone2(v(5,5,10),3,v(0,0,0),0));
