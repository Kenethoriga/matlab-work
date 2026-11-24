function M = mtx_roty(a)
% MTX_ROTY  4x4 rotation about the y axis, angle a in radians.
% Authors: <add group member names>
c = cos(a); s = sin(a);
M = [c 0 s 0; 0 1 0 0; -s 0 c 0; 0 0 0 1];
end
