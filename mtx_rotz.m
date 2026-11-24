function M = mtx_rotz(a)
% MTX_ROTZ  4x4 rotation about the z axis, angle a in radians.
% Authors: <add group member names>
c = cos(a); s = sin(a);
M = [c -s 0 0; s c 0 0; 0 0 1 0; 0 0 0 1];
end
