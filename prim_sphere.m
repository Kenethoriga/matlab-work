function [V, F] = prim_sphere(r, n)
% PRIM_SPHERE  Smooth sphere of radius r (n segments around, n/2 up).
% Authors: <add group member names>
m = max(4, round(n / 2));
p = linspace(-pi/2, pi/2, m + 1);
[V, F] = prim_revolve([r * cos(p(:)), r * sin(p(:))], n);
end
