--[[
The MIT License (MIT)

Copyright (c) 2014 Loïc Fejoz

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
]]

-- Library inspired from that of POVRAY shapes.inc
-- @see http://www.f-lohmueller.de/pov_tut/all_shapes/shapes000e.htm

----
-- The box shape is define by two opposite corners.
-- @return a box
-- @param p1 near lower left corner
-- @param p2 far upper right corner
-- @usage povray_box(v(-5,-5,-5), v(5,5,5))
-- > box(5) == povray_box(v(-5,-5,-5), v(5,5,5))
function povray_box(p1, p2)
	return translate(p1+(p2-p1)/2) * scale(p2 - p1) * box(1);
end

----
-- The cone shape is defined by the center and radius of each end.
-- @return a cone
-- @param c1 center of first end
-- @param r1 radius of first end
-- @param c2 center of other end
-- @param r2 radius of other end
-- @usage povray_cone(v(20,20,20),3,v(0,0,0),0)
-- > cone(20,5,30) == povray_cone(v(0,0,0), 20, v(0,0,30), 5)
function povray_cone(c1, r1, c2, r2)
	local direction = c2-c1;
	local height = math.sqrt(dot(direction, direction));
	local theta = acos(dot(Z,direction) / height);
	local r;
	if (theta == 0) then
		r = rotate(0,0,0);
	else
		r = rotate(theta, cross(Z, direction));
	end
	return translate(c1) * r * cone(r1, r2, height);
end

function povray_cone_referential(length)
	set_group_color(1, 1.0,0.3,0.3);
	set_group_color(2, 0.3,1.0,0.3);
	set_group_color(3, 0.3,0.3,1.0);
	emit(povray_cone(v(0,0,0),5,v(length,0,0),0), 1);
	emit(povray_cone(v(0,0,0),5,v(0,length,0),0), 2);
	emit(povray_cone(v(0,0,0),5,v(0,0,length),0), 3);
end

-- povray_cone_referential(30);

----
-- The cylinder shape is defined by the center of each end and the radius.
-- @return a cylinder
-- @param c1 center of first end
-- @param c2 center of other end
-- @param radius of the cylinder
-- @usage povray_cylinder(v(20,20,20),v(0,0,0),3)
-- > cylinder(5,20) == povray_cylinder(v(0,0,0), v(0,0,20), 5)
function povray_cylinder(c1, c2, radius)
	local direction = c2-c1;
	local height = math.sqrt(dot(direction, direction));
	local theta = acos(dot(Z,direction) / height);
	local r;
	if (theta == 0) then
		r = rotate(0,0,0);
	else
		r = rotate(theta, cross(Z, direction));
	end
	return translate(c1) * r * cylinder(radius, height);
end

function povray_cylinder_referential(length)
	set_group_color(1, 1.0,0.3,0.3);
	set_group_color(2, 0.3,1.0,0.3);
	set_group_color(3, 0.3,0.3,1.0);
	emit(povray_cylinder(v(0,0,0),v(length,0,0),5), 1);
	emit(povray_cylinder(v(0,0,0),v(0,length,0),5), 2);
	emit(povray_cylinder(v(0,0,0),v(0,0,length),5), 3);
end

-- povray_cylinder_referential(50);

-- TODO: Torus not yet possible without shaders nor polyhedron.

----
-- The wire box shape is  made of cylinders and spheres. It is defined by two opposite corners and radius of the wire.
-- @return a wire-frame box that will fit entirely within a box object with the same corner points
-- @param p1 near lower left corner
-- @param p2 far upper right corner
-- @param edge radius of the edges
-- @usage povray_wire_box(v(0,0,0), v(20,30,40), 2)
function povray_wire_box(p1, p2, edge)
	local v_length = p2 - p1;
	local two_times_edge = 2 * edge;
	local v_inner_length = v_length - v(two_times_edge, two_times_edge, two_times_edge);
	local cz = cylinder(edge, v_inner_length.z);
	local cy = rotate(90, 0, 0) * cylinder(edge, v_inner_length.y);
	local cx = rotate(0, 90, 0) * cylinder(edge, v_inner_length.x);
	return translate(p1 + v_length/2) * union{
		--
		translate(v_length.x/2 - edge, v_length.y/2 - edge, -v_length.z/2+edge) * cz,
		translate(v_length.x/2 - edge, -v_length.y/2 + edge, -v_length.z/2+edge) * cz,
		translate(-v_length.x/2 + edge, v_length.y/2 - edge, -v_length.z/2+edge) * cz,
		translate(-v_length.x/2 + edge, -v_length.y/2 + edge, -v_length.z/2+edge) * cz,
		translate(-v_length.x/2 +edge,v_length.y/2-edge,-v_length.z/2+edge) * cy,
		translate(-v_length.x/2 +edge,v_length.y/2-edge,v_length.z/2-edge) * cy,
		translate(v_length.x/2-edge,v_length.y/2-edge,-v_length.z/2+edge) * cy,
		translate(v_length.x/2-edge,v_length.y/2-edge,v_length.z/2-edge) * cy,
		translate(-v_length.x/2+edge,v_length.y/2-edge,-v_length.z/2+edge) * cx,
		translate(-v_length.x/2+edge,-v_length.y/2+edge,-v_length.z/2+edge) * cx,
		translate(-v_length.x/2+edge,v_length.y/2-edge,v_length.z/2-edge) * cx,
		translate(-v_length.x/2+edge,-v_length.y/2+edge,v_length.z/2-edge) * cx,
		translate(-v_length.x/2+edge,-v_length.y/2+edge,v_length.z/2-edge) * sphere(edge),
		translate(-v_length.x/2+edge,-v_length.y/2+edge,-v_length.z/2+edge) * sphere(edge),
		translate(-v_length.x/2+edge,v_length.y/2-edge,v_length.z/2-edge) * sphere(edge),
		translate(-v_length.x/2+edge,v_length.y/2-edge,-v_length.z/2+edge) * sphere(edge),
		translate(v_length.x/2-edge,-v_length.y/2+edge,v_length.z/2-edge) * sphere(edge),
		translate(v_length.x/2-edge,-v_length.y/2+edge,-v_length.z/2+edge) * sphere(edge),
		translate(v_length.x/2-edge,v_length.y/2-edge,v_length.z/2-edge) * sphere(edge),
		translate(v_length.x/2-edge,v_length.y/2-edge,-v_length.z/2+edge) * sphere(edge),
	}
end

----
-- The round box shape is defined by two opposite corners and radius of the edges.
-- @return a round box that will fit entirely within a box object with the same corner points
-- @param p1 near lower left corner
-- @param p2 far upper right corner
-- @param edge radius of the edges
-- @usage povray_round_box(v(0,0,0), v(20,30,40), 2)
function povray_round_box(p1, p2, edge)
	local v_length = p2 - p1;
	local v_small_length = v_length - v(2*edge, 2*edge, 2*edge);
	return union{
		povray_wire_box(p1, p2, edge),
		translate(p1+v_length/2) * union{
			scale(v_small_length) * box(1),
			translate(v_small_length.x/2, 0, 0) * scale(2*edge, v_small_length.y, v_small_length.z) * box(1),
			translate(-v_small_length.x/2, 0, 0) * scale(2*edge, v_small_length.y, v_small_length.z) * box(1),
			translate(0,v_small_length.y/2, 0) * scale(v_small_length.x, 2*edge, v_small_length.z) * box(1),
			translate(0,-v_small_length.y/2, 0) * scale(v_small_length.x, 2*edge, v_small_length.z) * box(1),
			translate(0,0,v_small_length.z/2) * scale(v_small_length.x, v_small_length.y, 2*edge) * box(1),
			translate(0,0,-v_small_length.z/2) * scale(v_small_length.x, v_small_length.y, 2*edge) * box(1),
		}
	}
end

-- TODO: round_cone1 need torus.

----
-- Creates a cone with rounded edges from a cone and two spheres. 
-- The returning object will not fit entirely within a cone object with the same end points and radii because of the spherical caps.
-- The end points are not used for the conical portion, but for the spheres, a suitable cone is then generated to smoothly join them.
-- @return a round cone 
-- @param c1 center of first end
-- @param r1 radius of first end
-- @param c2 center of other end
-- @param r2 radius of other end
-- @usage povray_round_cone2(v(20,20,20),3,v(0,0,0),0)
-- > cone(20,5,30) == povray_cone(v(0,0,0), 20, v(0,0,30), 5)
function povray_round_cone2(c1, r1, c2, r2)
	local direction = c2 - c1;
	local radius_diff = r1 - r2;
	local length = math.sqrt(dot(direction, direction));
	local d2 = length*length - radius_diff*radius_diff;
	print("d2:" .. d2);
	if (d2 < 0) then 
		return Void;
	end;
	d2 = math.sqrt(d2);
	return union{
		translate(c1) * sphere(r1),
		translate(c2) * sphere(r2),
		povray_cone(
			c1 + direction/length * radius_diff * r1 / length,
			r1 * d2 / length,
			c2 + direction/length * radius_diff * r2 / length,
			r2 * d2 / length)
	};
		
end

----
-- Creates a torus centered on v(0,0,0) with major radius and minor radius.
-- @return a torus
-- @param r_major the major radius
-- @param r_minor the minor radius
-- @usage emit(torus(20, 5));
function povray_torus(r_major, r_minor)
	local points = {};
	local indices = {};
	for angle_major = 0, 361, 1 do
		for angle_minor = 0, 361, 1 do
			points[(360 * angle_minor) + angle_major] = v(
				(r_major + r_minor*cos(angle_minor)) * cos(angle_major),
				(r_major + r_minor*cos(angle_minor)) * sin(angle_major),
				r_minor * sin(angle_minor));
		end
	end
	for angle_major = 0, 360, 1 do
		for angle_minor = 0, 360, 1 do
			table.insert(indices, v(
				(360*angle_minor) + angle_major,
				(360*angle_minor) + ((1+angle_major)%360),
				angle_major+(360*(angle_minor+1))));
			table.insert(indices, v(
				(360*angle_minor) + ((1+angle_major)%360),
				((angle_major+1)%360)+(360*(angle_minor+1)),
				angle_major+(360*(angle_minor+1))));
		end
	end
	
	return polyhedron(points, indices);
end

-- TODO: uncomment this when torus will be primitive in IceSL
torus = povray_torus;

----
-- Creates a cylinder with rounded edges from cylinders and tori.
-- The resulting object will fit entirely within a cylinder object with the same end points and radius.
-- @return a rounded cylinder
-- @param c1 center of first end
-- @param c2 center of other end
-- @param radius of the cylinder
-- @param edge_radius the radius of the edges of the cylinder
-- @usage povray_round_cylinder(v(20,20,20),v(0,0,0),3,1)
function povray_round_cylinder(c1, c2, radius, edge_radius)
	local direction = c2-c1;
	local height = math.sqrt(dot(direction, direction));
	local theta = acos(dot(Z,direction) / height);
	local r;
	if (theta == 0) then
		r = rotate(0,0,0);
	else
		r = rotate(theta, cross(Z, direction));
	end
	return translate(c1) * r * 
		union({
			translate(0, 0, edge_radius) * cylinder(radius, height - 2*edge_radius),
			translate(0, 0, edge_radius) * torus(radius-edge_radius, edge_radius),
			translate(0, 0, height - edge_radius) * torus(radius-edge_radius, edge_radius),
			cylinder(radius-edge_radius, edge_radius),
			translate(0, 0, height - edge_radius) * cylinder(radius-edge_radius, edge_radius)
		});
end

function samples()
	set_group_color(1, 1.0,0.3,0.3);
	set_group_color(2, 0.3,1.0,0.3);
	set_group_color(3, 0.3,0.3,1.0);
	set_group_color(4, 0.5,0.5,0.5);

	emit(povray_box(v(5,5,0), v(10,10,5)));
	emit(povray_cone(v(20,20,0),3,v(20,20,10),1));
	emit(povray_cylinder(v(-10,20,0),v(-10,20,10),3));
	emit(povray_round_cylinder(v(10,20,0),v(10,20,10),3,1));
	emit(povray_wire_box(v(20,10,0), v(25,15,10), 0.5));
	emit(povray_round_box(v(-5,-5,0), v(0,0,5), 1));
	emit(translate(-5, -10, 1) * torus(4,1));
	emit(povray_round_cone2(v(5,5,10),3,v(0,0,0),0));
	--TODO: emit(povray_round_cone1(v(5,5,10),3,v(0,0,0),0));
end

-- If used as main script then display samples
-- see http://stackoverflow.com/questions/4521085/main-function-in-lua
if not pcall(getfenv, 4) then 
	samples();
end