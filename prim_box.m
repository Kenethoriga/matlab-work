function [V, F] = prim_box(w, d, h)
% PRIM_BOX  Box centred on the origin. Each face has its own 4 vertices, so
% the lighting stays crisp on the edges.
% Authors: <add group member names>
c = [-1 -1 -1; 1 -1 -1; 1 1 -1; -1 1 -1; -1 -1 1; 1 -1 1; 1 1 1; -1 1 1] / 2;
c = c .* repmat([w d h], 8, 1);
idx = [1 4 3 2; 5 6 7 8; 1 2 6 5; 3 4 8 7; 1 5 8 4; 2 3 7 6];
V = c(reshape(idx.', 1, []), :);
F = reshape(1:24, 4, 6).';
end
