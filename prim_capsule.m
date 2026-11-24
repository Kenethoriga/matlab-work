function [V, F] = prim_capsule(r, len, n)
% PRIM_CAPSULE  Rounded limb: a cylinder of length len with a half sphere on each end.
% Total height is len + 2r. Centred on the origin, along z.
% Authors: <add group member names>
p = linspace(-pi/2, 0, 5);
q = linspace(0, pi/2, 5);
rz = [r * cos(p(:)), -len/2 + r * sin(p(:)); r * cos(q(:)),  len/2 + r * sin(q(:))];
[V, F] = prim_revolve(rz, n);
end
