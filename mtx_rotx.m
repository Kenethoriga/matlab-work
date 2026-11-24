function M = mtx_rotx(a)
% MTX_ROTX  4x4 rotation about the x axis, angle a in radians.
% Authors: <add group member names>
c = cos(a); s = sin(a);
M = [1 0 0 0; 0 c -s 0; 0 s c 0; 0 0 0 1];
end
