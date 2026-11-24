function C = bake_color(P, base, TP, amb)
% BAKE_COLOR  Compute warm torch-lit vertex colors with subtle cool shadow fill.
%   P    : N x 3 vertex positions
%   base : 1 x 3 base RGB color
%   TP   : K x 3 torch flame positions
%   amb  : scalar ambient intensity

    n = size(P, 1);
    I = zeros(n, 1);

    for k = 1:size(TP, 1)
        d  = P - TP(k, :);
        d2 = sum(d .* d, 2);
        I  = I + 1.05 ./ (1 + 0.26 * d2);
    end

    % Cinematic contrast: warm amber torchlight + cool slate ambient shadows
    warmLight = [1.00, 0.72, 0.42] .* I;
    coolAmb   = [0.45, 0.55, 0.75] .* amb;

    C = base .* (warmLight + coolAmb);
    C = min(max(C, 0), 1);
end