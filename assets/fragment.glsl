/*
Title: 2D Spot Lighting
File Name: fragment.glsl
Copyright ? 2016
Author: David Erbelding
Written under the supervision of David I. Schwartz, Ph.D., and
supported by a professional development seed grant from the B. Thomas
Golisano College of Computing & Information Sciences
(https://www.rit.edu/gccis) at the Rochester Institute of Technology.

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or (at
your option) any later version.

This program is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/


#version 400 core

in vec3 position;
in vec2 uv;
in vec4 color;

uniform vec3 lightPosition;
uniform vec3 lightDirection;
uniform sampler2D tex;
uniform sampler2D norm;

void main(void)
{
	vec4 lightColor = vec4(1, 1, 1, 1);
	vec4 ambientLight = vec4(.1, .1, .1, 0);
	vec3 attenCoeff = vec3(4, 1, 0);
	float lightRadius = 500;
	float spotAngle = 1;
	float exponent = 8;
	
	// Get the normal direction from the normal texture and make sure it's normalized
	vec3 normal = normalize(vec3(texelFetch(norm, ivec2(uv), 0)) * 2 - 1);

	// Calculate direction of the surface to the light
	vec3 surfaceToLight = lightPosition - position;

	// Light strength is related to how close the object is to the light
	float d = length(surfaceToLight) / lightRadius;

	// Get the diffuse value using the light and normal vectors
	float diffuse = clamp(dot(normalize(surfaceToLight), normal), 0, 1);

	// Attenuation is calculated by dividing 1 by a quadratic function ax^2 + bx + c.
	// This makes a curve that falls off with distance.
	float attenuation = clamp(1 / (d * d * attenCoeff.x + d * attenCoeff.y + attenCoeff.z), 0, 1);

	// With a spot light the angle between the light and the object.
	float angle = -dot(normalize(surfaceToLight), normalize(lightDirection));
	// Here we shift that value to be between 0 and 1 (1 being closer to the center)
	float spotEffect = (angle - cos(spotAngle)) / (1- cos(spotAngle));
	// Raise the light to a power, so that it falls off near the edges
	spotEffect = pow(clamp(spotEffect, 0, 1), exponent);

	// Include the spot effect in the attenuation
	attenuation = clamp(attenuation * spotEffect, 0, 1);

	// Get the base pixel color and multiply in the light
	vec4 pixelColor = texelFetch(tex, ivec2(uv), 0) * color;
	gl_FragColor = pixelColor * (lightColor * diffuse * attenuation + ambientLight);
}