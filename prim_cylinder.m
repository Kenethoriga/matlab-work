function [V, F] = prim_cylinder(r, h, n)
% PRIM_CYLINDER  Cylinder along z, centred on the origin, with flat ends.
% Authors: <add group member names>
[V, F] = prim_revolve([0 -h/2; r -h/2; r -h/2; r h/2; r h/2; 0 h/2], n);
end
