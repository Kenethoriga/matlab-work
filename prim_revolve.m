function [V, F] = prim_revolve(rz, n)
% PRIM_REVOLVE  Spin a profile around the z axis to make a smooth round solid.
% rz is an M x 2 list of [radius z] points going from bottom to top. Repeating
% a profile point makes a sharp edge (used for the rim of a cylinder).
% Returns vertices V and quad faces F (4 columns).
% Authors: <add group member names>
M = size(rz, 1);
t = linspace(0, 2*pi, n + 1); t(end) = [];
V = zeros(M * n, 3);
for i = 1:M
    V((i-1)*n + (1:n), :) = [rz(i,1) * cos(t(:)), rz(i,1) * sin(t(:)), rz(i,2) * ones(n, 1)];
end
F = zeros((M - 1) * n, 4);
k = 0;
for i = 1:M-1
    for j = 1:n
        j2 = mod(j, n) + 1;
        k = k + 1;
        F(k, :) = [(i-1)*n + j, (i-1)*n + j2, i*n + j2, i*n + j];
    end
end
end
