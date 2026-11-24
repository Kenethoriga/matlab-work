function N = rock_noise(A, B, seed)
% ROCK_NOISE  Smooth bumpy noise in [-1,1] made from a few sine waves.
% Used to make the cave walls and ceiling look like rough rock.
% The "random" numbers come from a fixed formula, so the cave looks the
% same every run.
% Authors: <add group member names>
N = zeros(size(A));
for k = 1:6
    f1 = 0.4 + 1.6 * hash01(seed * 10 + k);
    f2 = 0.4 + 1.6 * hash01(seed * 10 + k + 50);
    ph = 2 * pi * hash01(seed * 10 + k + 99);
    N = N + sin(f1 * A + f2 * B + ph) / k;
end
N = max(-1, min(1, N / 1.8));
end

function r = hash01(x)
r = mod(sin(x * 12.9898) * 43758.5453, 1);
end
