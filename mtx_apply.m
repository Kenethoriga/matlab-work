function P = mtx_apply(M, V)
% MTX_APPLY  Apply a 4x4 homogeneous transform M to an N x 3 vertex list V.
    n = size(V, 1);
    H = [V, ones(n, 1)] * M.';
    P = H(:, 1:3) ./ H(:, 4);
end