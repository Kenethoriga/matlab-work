function M = mesh_add(M, V, F, col, M4)
% MESH_ADD  Add a shape to a mesh so many shapes can be drawn as ONE patch
% (much faster in MATLAB than hundreds of separate patches).
%   M    mesh struct (start with M = struct('V',[],'F',[],'C',[]))
%   V,F  vertices and quad faces of the shape, col its colour [r g b]
%   M4   optional 4x4 matrix applied to the shape first (our own mtx_* matrices)
% Authors: <add group member names>
if nargin > 4, V = mtx_apply(M4, V); end
off = size(M.V, 1);
M.V = [M.V; V];
M.F = [M.F; F + off];
M.C = [M.C; repmat(col, size(V, 1), 1)];
end
