function S = build_chamber2(ax, lite)
% BUILD_CHAMBER2  Chamber II: The Inferno (Fast, Immersive Magma Cavern).
%                 Built on the same high-FPS cavern architecture as Chamber III:
%                 jagged fiery rock arch, blazing molten vortex core, full rocky
%                 magma-cracked floor, obsidian monoliths, and the Inferno Gate.

    if nargin < 2, lite = false; end
    S.lite = lite;

    set(ax, 'XLim', [-18 18], 'YLim', [-14 34], 'ZLim', [-2 18], ...
        'DataAspectRatio', [1 1 1], 'Projection', 'perspective', ...
        'Color', [0.06 0.01 0.015], 'Visible', 'off', ...
        'SortMethod', 'depth', 'Clipping', 'off');
    hold(ax, 'on');

    % 6 brazier positions lining the obsidian path
    TP = [-2.25  1.0 2.50;  2.25  1.0 2.50;
          -2.25  6.0 2.50;  2.25  6.0 2.50;
          -2.25 14.0 2.50;  2.25 14.0 2.50];
    S.TP = TP;

    % Inferno Cavern Palette
    obsidian  = [0.09 0.06 0.08];
    basalt    = [0.16 0.07 0.08];
    iron      = [0.16 0.13 0.14];
    bronze    = [0.58 0.36 0.16];
    gold      = [0.98 0.78 0.26];
    magmaHot  = [1.00 0.86 0.24];
    magmaOrg  = [1.00 0.36 0.04];

    %% 1. Blazing Molten Core Backdrop (Fast Single Surface, No Sky Cylinder)
    vo = [0, 26.0, 6.2];
    nr = 18 - 6 * lite;
    nt = 32 - 10 * lite;
    [R, Th] = meshgrid(linspace(0.05, 13.5, nr), linspace(0, 2*pi, nt));
    Vx = vo(1) + R .* cos(Th);
    Vz = vo(3) + R .* sin(Th);
    Vy = vo(2) + 0.12 * (R.^1.35);

    rn     = R / 13.5;
    swirl  = 0.5 + 0.5 * sin(3 * Th + 2.0 * R - 0.5 * cos(2 * Th));
    core   = exp(-((R / 2.6).^2));
    halo   = exp(-((R / 8.2).^1.5));
    fade   = max(0, 1 - rn.^2.2);

    Cv = zeros([size(R), 3]);
    Cv(:, :, 1) = min(1, (0.10 + 0.86 * halo .* (0.65 + 0.35 * swirl) + 0.95 * core)) .* fade;
    Cv(:, :, 2) = min(1, (0.02 + 0.34 * halo .* (0.55 + 0.45 * swirl) + 0.82 * core)) .* fade;
    Cv(:, :, 3) = min(1, (0.01 + 0.05 * halo + 0.35 * core)) .* fade;

    S.vortex = surf(ax, Vx, Vy, Vz, Cv, 'FaceColor', 'interp', ...
        'EdgeColor', 'none', 'FaceLighting', 'none', 'Clipping', 'off');

    %% 2. Jagged Magma-Lit Cavern Arch (Same Fast Architecture as Chamber III)
    nu = 26 - 8 * lite;
    nv = 24 - 8 * lite;
    [U, W] = meshgrid(linspace(-0.22*pi, 1.22*pi, nu), linspace(-10, 21, nv));
    jag = 1.10 * sin(U * 5 + W * 0.45) + 0.60 * cos(U * 9 - W * 0.75) + ...
          0.40 * sin(U * 13 + W * 1.0);
    rx  = 11.0 + 0.12 * (W + 10) + jag;
    rz  =  9.2 + 0.14 * (W + 10) + 0.85 * jag;

    Cx = rx .* cos(U);
    Cy = W;
    Cz = max(-1.2, 2.0 + rz .* sin(U));

    distV = sqrt((Cx - vo(1)).^2 + (Cy - vo(2)).^2 + (Cz - vo(3)).^2);
    glowV = max(0, min(1, 1.35 - distV / 27));
    ridge = 0.72 + 0.28 * (jag - min(jag(:))) / max(1e-6, max(jag(:)) - min(jag(:)));
    vein  = mod(sin(Cx * 2.1 + Cy * 1.7 + Cz * 1.3) * 43758.5453, 1) > 0.93;

    Ccav = zeros([size(Cx), 3]);
    Ccav(:, :, 1) = min(1, (0.09 + 0.48 * glowV) .* ridge + 0.55 * vein);
    Ccav(:, :, 2) = min(1, (0.02 + 0.14 * glowV) .* ridge + 0.32 * vein);
    Ccav(:, :, 3) = min(1, (0.04 + 0.06 * glowV) .* ridge + 0.04 * vein);

    S.ceil  = surf(ax, Cx, Cy, Cz, Ccav, 'FaceColor', 'flat', ...
        'EdgeColor', [0.10 0.02 0.03], 'LineWidth', 0.25, 'FaceLighting', 'none');
    S.wallL = gobjects(0);
    S.wallR = gobjects(0);

    %% 3. Full Immersive Rocky Magma Floor (Zero Per-Frame Updates)
    tile = 1.2 + 0.5 * lite;
    [Xf, Yf] = meshgrid(-15:tile:15, -12:tile:24);
    sideDist = max(0, abs(Xf) - 2.0);
    rockH    = 0.35 * sin(Xf * 0.85 + Yf * 0.55) + 0.22 * cos(Xf * 1.5 - Yf * 0.85);
    Zf       = -0.32 + 0.15 * (sideDist.^1.25) + rockH .* min(1, sideDist / 2.0);
    Zf(abs(Xf) < 2.0) = -0.30;

    distF = sqrt((Xf - vo(1)).^2 + (Yf - vo(2)).^2 + (Zf - vo(3)).^2);
    glowF = max(0, min(1, 1.25 - distF / 29));
    rHash = mod(sin(Xf * 12.9898 + Yf * 78.233) * 43758.5453, 1);
    crack = rHash > 0.82 & abs(Xf) > 2.1;

    Cf = zeros([size(Xf), 3]);
    Cf(:, :, 1) = min(1, 0.10 + 0.36 * glowF + 0.65 * crack);
    Cf(:, :, 2) = min(1, 0.03 + 0.10 * glowF + 0.42 * crack);
    Cf(:, :, 3) = min(1, 0.04 + 0.03 * glowF + 0.05 * crack);

    S.floor = surf(ax, Xf, Yf, Zf, Cf, 'FaceColor', 'flat', ...
        'EdgeColor', [0.10 0.02 0.02], 'LineWidth', 0.25, 'FaceLighting', 'none');

    %% 4. Obsidian Walkway, Pedestal Braziers & Flanking Magma Monoliths
    St = empty_mesh();
    for ys = -7.5:1.65:17.5
        St = add_box(St, [0 ys -0.08], [3.70 1.48 0.18], obsidian);
        St = add_box(St, [0 ys  0.03], [3.48 1.36 0.06], basalt);
        St = add_box(St, [-1.78 ys 0.06], [0.10 1.32 0.08], gold * 0.88);
        St = add_box(St, [ 1.78 ys 0.06], [0.10 1.32 0.08], gold * 0.88);
        St = add_box(St, [0 ys + 0.72 0.04], [3.10 0.07 0.04], magmaOrg);
    end

    % 6 Tall Iron & Bronze Pedestal Braziers
    for k = 1:size(TP, 1)
        bx = TP(k, 1); by = TP(k, 2);
        St = add_box(St, [bx by 0.14], [0.56 0.56 0.28], obsidian);
        [V, F] = prim_cylinder(0.08, 1.90, 8);
        St = mesh_add(St, V, F, iron, mtx_translate(bx, by, 1.25));
        [V, F] = prim_revolve([0 -0.14; 0.34 0.16; 0.38 0.24; 0 0.14], 8);
        St = mesh_add(St, V, F, bronze, mtx_translate(bx, by, 2.24));
    end

    % 6 Towering Obsidian & Magma-Veined Monoliths (like Chamber III's ruins)
    monoPos = [-6.2 -1.0 2.0;   6.2 -0.5 2.2;
               -7.0  5.5 2.8;   7.0  6.0 2.6;
               -5.8 13.5 2.4;   5.8 13.0 2.7];
    for k = 1:size(monoPos, 1)
        mp = monoPos(k, :);
        St = add_box(St, mp,                  [1.20 1.20 4.60], basalt);
        St = add_box(St, mp + [0 0 2.40],     [1.38 1.38 0.20], gold * 0.88);
        St = add_box(St, mp + [0 -0.62 0],    [0.16 0.06 3.40], magmaOrg);
        St = add_box(St, mp + [0 -0.64 0],    [0.07 0.06 2.80], magmaHot);
    end
    S.statics = mesh_patch(ax, St, 'gouraud', 0.22);

    %% 5. Brazier Flames (Low-Poly Combined Patch)
    [Vflame, Fflame] = prim_revolve([0 -0.06; 0.19 0.06; 0.12 0.28; 0 0.54], 7);
    t = (Vflame(:, 3) - min(Vflame(:, 3))) / max(1e-6, max(Vflame(:, 3)) - min(Vflame(:, 3)));
    Cflame = magmaOrg .* (1 - t) + magmaHot .* t;

    nf = size(TP, 1); nv = size(Vflame, 1); nF = size(Fflame, 1);
    Vall = zeros(nf * nv, 3); Fall = zeros(nf * nF, 4); Call = zeros(nf * nv, 3);
    for k = 1:nf
        Vall((k-1)*nv + (1:nv), :) = Vflame;
        Fall((k-1)*nF + (1:nF), :) = Fflame + (k-1) * nv;
        Call((k-1)*nv + (1:nv), :) = Cflame;
    end
    S.flame.V0 = Vflame; S.flame.n = nf; S.flame.nv = nv;
    S.flame.h = patch('Parent', ax, 'Vertices', Vall, 'Faces', Fall, 'FaceVertexCData', Call, ...
        'FaceColor', 'interp', 'EdgeColor', 'none', 'FaceLighting', 'none', 'Clipping', 'off');

    %% 6. Lightweight Dynamic Lights (Crisp Amani + Warm Firelight)
    light('Parent', ax, 'Position', [0 -6 10], 'Style', 'infinite', 'Color', [0.50 0.50 0.62]);
    S.torchLights = gobjects(1, 2);
    for k = 1:2
        S.torchLights(k) = light('Parent', ax, 'Position', TP(k, :) + [0 0 0.4], ...
            'Style', 'local', 'Color', [1.0 0.48 0.16]);
    end
    S.gateLight    = light('Parent', ax, 'Position', [0 13.5 2.6], 'Style', 'local', 'Color', [0 0 0]);
    S.crystalLight = light('Parent', ax, 'Position', [-2.6 6.5 2.0], 'Style', 'local', 'Color', [1.0 0.45 0.12]);

    %% 7. Glowing Portal Beyond the Gate
    [V, F] = prim_sphere(0.90, 12);
    S.portal = patch('Parent', ax, 'Vertices', mtx_apply(mtx_translate(0, 18.5, 2.3), V), ...
        'Faces', F, 'FaceColor', magmaHot, 'EdgeColor', 'none', ...
        'FaceLighting', 'none', 'Clipping', 'off');

    %% 8. Ornate Inferno Gate (3-Level Hierarchy: Frame -> Leaf -> Bolt)
    Fr = empty_mesh();
    for sd = [-1 1]
        Fr = add_box(Fr, [sd*2.96 0 2.65],    [0.98 1.08 5.30], obsidian);
        Fr = add_box(Fr, [sd*2.46 -0.54 2.65], [0.10 0.10 4.80], gold);
        Fr = add_box(Fr, [sd*2.96 -0.56 2.65], [0.16 0.08 4.40], magmaOrg);
    end
    Fr = add_box(Fr, [0 0 5.36],     [7.4 1.18 0.90], obsidian * 1.15);
    Fr = add_box(Fr, [0 -0.60 4.94], [7.2 0.12 0.12], gold);
    Fr = add_box(Fr, [0 -0.62 5.74], [7.6 0.10 0.08], magmaHot);
    S.gate.frame.V0 = Fr.V;
    S.gate.frame.h  = mesh_patch(ax, struct('V', mtx_apply(mtx_translate(0,10,0), Fr.V), ...
        'F', Fr.F, 'C', Fr.C), 'flat', 0.22);

    [V, F] = prim_cylinder(0.40, 0.10, 16);
    V = mtx_apply(mtx_translate(0, -0.74, 5.34) * mtx_rotx(pi/2), V);
    S.rune = patch('Parent', ax, 'Vertices', mtx_apply(mtx_translate(0,10,0), V), 'Faces', F, ...
        'FaceColor', magmaOrg, 'EdgeColor', magmaHot, 'LineWidth', 1.2, ...
        'FaceLighting', 'none', 'Clipping', 'off');

    for side = {'L', 'R'}
        sd = 1; if side{1} == 'L', sd = -1; end
        Lf = empty_mesh();
        Lf = add_box(Lf, [sd*1.25 0 2.45],     [2.44 0.30 4.80], iron);
        Lf = add_box(Lf, [sd*1.25 -0.17 3.60], [1.90 0.08 1.50], magmaOrg);
        Lf = add_box(Lf, [sd*1.25 -0.19 3.60], [1.72 0.08 1.34], obsidian);
        Lf = add_box(Lf, [sd*1.25 -0.17 1.30], [1.90 0.08 1.45], magmaOrg);
        Lf = add_box(Lf, [sd*1.25 -0.19 1.30], [1.72 0.08 1.28], obsidian);
        Lf = add_box(Lf, [sd*0.08 -0.22 2.45], [0.12 0.10 4.70], bronze);
        for zb = [0.95 2.45 3.95]
            Lf = add_box(Lf, [sd*1.25 -0.23 zb], [2.44 0.10 0.20], basalt);
        end
        S.gate.(['leaf' side{1}]).V0 = Lf.V;
        S.gate.(['leaf' side{1}]).h  = mesh_patch(ax, Lf, 'flat', 0.26);

        Bt = empty_mesh();
        [V, F] = prim_cylinder(0.095, 0.90, 10);
        Bt = mesh_add(Bt, V, F, gold, mtx_translate(sd*0.38, -0.34, 2.45) * mtx_roty(pi/2));
        S.gate.(['bolt' side{1}]).V0 = Bt.V;
        S.gate.(['bolt' side{1}]).h  = mesh_patch(ax, Bt, 'gouraud', 0.80);
    end

    %% 9. Hidden Panel Compatibility & Floating Fiery Crystal
    S.panelText = gobjects(1, 4);
    for k = 1:4
        S.panelText(k) = text(ax, 2.55, 4.28, 2.70, '', 'Visible', 'off');
    end

    [V, F] = prim_crystal(0.44, 0.44, 0.84);
    S.crystal.V0 = V;
    S.crystal.h  = patch('Parent', ax, 'Vertices', V, 'Faces', F, 'FaceColor', magmaOrg, ...
        'EdgeColor', magmaHot, 'LineWidth', 1.0, 'FaceLighting', 'none', 'Clipping', 'off');

    %% 10. Explorer Character (Amani)
    S = build_explorer(ax, S);

    %% 11. Lightweight Drifting Embers & Low-Poly Halos
    ne = 45;
    S.ember.x0 = -6 + 12 * mod(sin((1:ne) * 12.9898) * 43758.5453, 1);
    S.ember.y0 = -8 + 28 * mod(sin((1:ne) * 78.233)  * 43758.5453, 1);
    S.ember.z0 =  7      * mod(sin((1:ne) * 37.719)  * 43758.5453, 1);
    S.ember.ph = 6.28    * mod(sin((1:ne) * 4.1414)  * 43758.5453, 1);
    S.ember.h  = plot3(ax, S.ember.x0, S.ember.y0, S.ember.z0, '.', 'Color', magmaHot, 'MarkerSize', 7.0);

    [V, F] = prim_sphere(0.55, 6);
    nv = size(V, 1); nF = size(F, 1);
    Vh = zeros(nf * nv, 3); Fh = zeros(nf * nF, 4);
    for k = 1:nf
        Vh((k-1)*nv + (1:nv), :) = V;
        Fh((k-1)*nF + (1:nF), :) = F + (k-1) * nv;
    end
    S.halo.V0 = V; S.halo.nv = nv;
    S.halo.h  = patch('Parent', ax, 'Vertices', Vh, 'Faces', Fh, 'FaceColor', magmaOrg, ...
        'EdgeColor', 'none', 'FaceAlpha', 0.14, 'FaceLighting', 'none', 'Clipping', 'off');

    if lite
        set(S.halo.h,  'Visible', 'off');
        set(S.ember.h, 'Visible', 'off');
    end
end

%% Local Helpers
function M = empty_mesh()
    M = struct('V', [], 'F', [], 'C', []);
end

function M = add_box(M, c, sz, col)
    [V, F] = prim_box(sz(1), sz(2), sz(3));
    M = mesh_add(M, V, F, col, mtx_translate(c(1), c(2), c(3)));
end