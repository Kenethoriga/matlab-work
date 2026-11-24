function M = mtx_translate(tx, ty, tz)
% MTX_TRANSLATE  4x4 translation matrix.
% Authors: <add group member names>
M = [1 0 0 tx; 0 1 0 ty; 0 0 1 tz; 0 0 0 1];
end
