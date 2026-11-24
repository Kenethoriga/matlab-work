function [V, F] = prim_crystal(rx, ry, rz)
% PRIM_CRYSTAL  Octahedron (diamond) with separate vertices per face.
% Authors: <add group member names>
B = [1 0 0; -1 0 0; 0 1 0; 0 -1 0; 0 0 1; 0 0 -1] .* repmat([rx ry rz], 6, 1);
T = [5 1 3; 5 3 2; 5 2 4; 5 4 1; 6 3 1; 6 2 3; 6 4 2; 6 1 4];
V = B(reshape(T.', 1, []), :);
F = reshape(1:24, 3, 8).';
end
