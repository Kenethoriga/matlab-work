function S = build_chamber3(ax, lite)
% BUILD_CHAMBER3  Chamber III: The Void (Optimized Cosmic Cavern, Swirling
%                 Purple Vortex, Heavenly Bodies, Rocky Floor & Astral Gate).

    if nargin < 2, lite = false; end
    S.lite = lite;

    set(ax, 'XLim', [-18 18], 'YLim', [-14 34], 'ZLim', [-2 18], ...
        'DataAspectRatio', [1 1 1], 'Projection', 'perspective', ...
        'Color', [0.015 0.008 0.030], 'Visible', 'off', ...
        'SortMethod', 'depth', 'Clipping', 'off');
    hold(ax, 'on');

    % 6 floating astral lantern positions lining the stone path
    TP = [-2.45  1.0 2.45;  2.45  1.0 2.45;
          -2.45  6.0 2.45;  2.45  6.0 2.45;
          -2.45 14.0 2.45;  2.45 14.0 2.45];
    S.TP = TP;

    % Cosmic Void Palette
    voidStone = [0.10 0.08 0.16];
    slate     = [0.15 0.11 0.24];
    amethyst  = [0.58 0.22 0.95];
    cyanGlow  = [0.32 0.92 1.00];
    gold      = [0.92 0.76 0.34];

    %% 1. Deep Starfield (Toned Down Count)
    ns = 130 - 50 * lite;
    sx = -26 + 52 * mod(sin((1:ns) * 12.9898) * 43758.5453, 1);
    sy =  14 + 20 * mod(sin((1:ns) * 78.233)  * 43758.5453, 1);
    sz =  -2 + 22 * mod(sin((1:ns) * 37.719)  * 43758.5453, 1);
    plot3(ax, sx(1:2:end), sy(1:2:end), sz(1:2:end), '.', ...
        'Color', [0.92 0.88 1.00], 'MarkerSize', 5.0);
    plot3(ax, sx(2:2:end), sy(2:2:end), sz(2:2:end), '.', ...
        'Color', [0.58 0.78 1.00], 'MarkerSize', 3.5);

    %% 2. Swirling Purple-Magenta Cosmic Vortex Backdrop (Lighter Grid)
    vo = [0, 26.5, 6.8];
    S.void.origin = vo;

    nr = 12 - 3 * lite;
    nt = 24 - 6 * lite;
    [R, Th] = meshgrid(linspace(0.08, 13.5, nr), linspace(0, 2*pi, nt));
    Vx = vo(1) + R .* cos(Th);
    Vz = vo(3) + R .* sin(Th);
    Vy = vo(2) + 0.14 * (R.^1.35);

    rn     = R / 13.5;
    spiral = 0.5 + 0.5 * sin(3 * Th + 2.2 * R - 0.6 * cos(2 * Th));
    core   = exp(-((R / 2.3).^2));
    halo   = exp(-((R / 7.8).^1.5));

    Cv = zeros([size(R), 3]);
    Cv(:, :, 1) = min(1, 0.04 + 0.55 * halo .* (0.65 + 0.35 * spiral) + 0.92 * core);
    Cv(:, :, 2) = min(1, 0.01 + 0.16 * halo .* (0.55 + 0.45 * spiral) + 0.80 * core);
    Cv(:, :, 3) = min(1, 0.08 + 0.88 * halo .* (0.70 + 0.30 * spiral) + 0.96 * core);
    edgeFade = max(0, 1 - rn.^2.4);
    Cv = Cv .* edgeFade;

    S.vortex = surf(ax, Vx, Vy, Vz, Cv, 'FaceColor', 'interp', ...
        'EdgeColor', 'none', 'FaceLighting', 'none', 'Clipping', 'off');

    %% 3. Heavenly Bodies (Low-Poly, No Alpha-Sorting Lag)
    % (A) Ringed Violet-Gold Gas Giant (upper-left)
    [Vp, Fp] = prim_sphere(2.15, 14);
    tLat = (Vp(:, 3) + 2.15) / 4.30;
    band = 0.5 + 0.5 * sin(tLat * 18);
    Cp = [0.34 0.18 0.56] .* (1 - band) + [0.76 0.48 0.92] .* band;
    patch('Parent', ax, 'Vertices', mtx_apply(mtx_translate(-8.2, 22.0, 10.6), Vp), ...
        'Faces', Fp, 'FaceVertexCData', Cp, 'FaceColor', 'interp', ...
        'EdgeColor', 'none', 'FaceLighting', 'flat');

    % Planetary Ring around the Gas Giant (Opaque for FPS)
    [Vr, Fr] = prim_revolve([2.85 -0.05; 4.25 -0.02; 4.25 0.02; 2.85 0.05], 18);
    Mring = mtx_translate(-8.2, 22.0, 10.6) * mtx_rotx(0.45) * mtx_roty(-0.35);
    patch('Parent', ax, 'Vertices', mtx_apply(Mring, Vr), 'Faces', Fr, ...
        'FaceColor', [0.68 0.52 0.86], 'EdgeColor', 'none', 'FaceLighting', 'none');

    % (B) Luminous Ice-Cyan Moon (upper-right)
    [Vm, Fm] = prim_sphere(1.35, 12);
    tM = (Vm(:, 1) + 1.35) / 2.70;
    Cm = [0.16 0.20 0.40] .* tM + [0.68 0.92 1.00] .* (1 - tM);
    patch('Parent', ax, 'Vertices', mtx_apply(mtx_translate(7.6, 21.5, 10.2), Vm), ...
        'Faces', Fm, 'FaceVertexCData', Cm, 'FaceColor', 'interp', ...
        'EdgeColor', 'none', 'FaceLighting', 'none');

    % (C) Distant Crimson-Amethyst Dwarf Planet (mid-left)
    [Vd, Fd] = prim_sphere(0.75, 10);
    patch('Parent', ax, 'Vertices', mtx_apply(mtx_translate(-5.2, 24.5, 7.2), Vd), ...
        'Faces', Fd, 'FaceColor', [0.72 0.26 0.68], 'EdgeColor', 'none', ...
        'FaceLighting', 'flat');

    %% 4. Jagged Purple-Lit Cosmic Cavern Arch (Lighter Grid, No EdgeColor)
    nu = 18 - 4 * lite;
    nv = 16 - 4 * lite;
    [U, W] = meshgrid(linspace(-0.22*pi, 1.22*pi, nu), linspace(-10, 21, nv));
    jag = 1.15 * sin(U * 5 + W * 0.45) + 0.65 * cos(U * 9 - W * 0.75);
    rx  = 11.2 + 0.12 * (W + 10) + jag;
    rz  =  9.4 + 0.14 * (W + 10) + 0.85 * jag;

    Cx = rx .* cos(U);
    Cy = W;
    Cz = max(-1.2, 2.2 + rz .* sin(U));

    distV = sqrt((Cx - vo(1)).^2 + (Cy - vo(2)).^2 + (Cz - vo(3)).^2);
    glowV = max(0, min(1, 1.35 - distV / 28));
    ridge = 0.72 + 0.28 * (jag - min(jag(:))) / max(1e-6, max(jag(:)) - min(jag(:)));

    Ccav = zeros([size(Cx), 3]);
    Ccav(:, :, 1) = min(1, (0.05 + 0.34 * glowV) .* ridge);
    Ccav(:, :, 2) = min(1, (0.03 + 0.14 * glowV) .* ridge);
    Ccav(:, :, 3) = min(1, (0.09 + 0.54 * glowV) .* ridge);

    S.ceil  = surf(ax, Cx, Cy, Cz, Ccav, 'FaceColor', 'flat', ...
        'EdgeColor', 'none', 'FaceLighting', 'none');
    S.wallL = gobjects(0);
    S.wallR = gobjects(0);

    %% 4b. Full Immersive Rocky Cavern Floor (Lighter Grid, No EdgeColor)
    tile = 1.8 + 0.6 * lite;
    [Xf, Yf] = meshgrid(-15:tile:15, -12:tile:24);
    sideDist = max(0, abs(Xf) - 2.1);
    rockH    = 0.35 * sin(Xf * 0.85 + Yf * 0.55) + 0.22 * cos(Xf * 1.6 - Yf * 0.9);
    Zf       = -0.35 + 0.14 * (sideDist.^1.25) + rockH .* min(1, sideDist / 2.0);
    Zf(abs(Xf) < 2.2) = -0.32;

    distF = sqrt((Xf - vo(1)).^2 + (Yf - vo(2)).^2 + (Zf - vo(3)).^2);
    glowF = max(0, min(1, 1.25 - distF / 30));
    rHash = mod(sin(Xf * 12.9898 + Yf * 78.233) * 43758.5453, 1);
    crack = rHash > 0.88 & abs(Xf) > 2.3;

    Cf = zeros([size(Xf), 3]);
    Cf(:, :, 1) = min(1, 0.06 + 0.28 * glowF + 0.35 * crack);
    Cf(:, :, 2) = min(1, 0.03 + 0.11 * glowF + 0.12 * crack);
    Cf(:, :, 3) = min(1, 0.11 + 0.48 * glowF + 0.50 * crack);

    S.floor = surf(ax, Xf, Yf, Zf, Cf, 'FaceColor', 'flat', ...
        'EdgeColor', 'none', 'FaceLighting', 'none');

    %% 5. Spinning 3-Ring Singularity (Lighter Segments, Opaque for FPS)
    ringCols = {[0.78 0.38 1.00], [0.42 0.92 1.00], [0.96 0.55 0.92]};
    ringRads = [3.6, 5.2, 6.8];
    for k = 1:3
        r0 = ringRads(k);
        [V, F] = prim_revolve([r0-0.14 -0.08; r0+0.14 -0.08; r0+0.14 0.08; r0-0.14 0.08], 18);
        S.void.rings(k).V0 = V;
        S.void.rings(k).h  = patch('Parent', ax, 'Vertices', V, 'Faces', F, ...
            'FaceColor', ringCols{k}, 'EdgeColor', 'none', ...
            'FaceLighting', 'none', 'Clipping', 'off');
    end
    S.void.light = light('Parent', ax, 'Position', vo, 'Style', 'local', 'Color', [0.65 0.35 1.00]);

    %% 6. Floating Cosmic Stone Walkway (Combined Rails, Flat-Shaded)
    St = empty_mesh();
    St = add_box(St, [0 5.0 -0.10],    [4.25 26.5 0.20], voidStone);
    St = add_box(St, [0 5.0  0.02],    [4.05 26.5 0.06], slate);
    St = add_box(St, [-2.05 5.0 0.05], [0.10 26.5 0.08], gold * 0.9);
    St = add_box(St, [ 2.05 5.0 0.05], [0.10 26.5 0.08], gold * 0.9);
    for ys = -6.5:2.2:17.5
        St = add_box(St, [0 ys 0.04], [3.60 0.08 0.04], cyanGlow * 0.85);
    end
    S.statics = mesh_patch(ax, St, 'flat', 0.18);

    %% 7. Floating Monolith Ruins (Zero-G Bobbing, Flat-Shaded)
    ruinPos = [-6.4 -1.0 2.5;  6.4 -0.5 2.8;
               -7.2  5.5 3.6;  7.2  6.0 3.2;
               -6.0 13.5 3.0;  6.0 13.0 3.5];
    for k = 1:size(ruinPos, 1)
        Rm = empty_mesh();
        Rm = add_box(Rm, [0 0 0],     [1.25 1.25 4.20], slate);
        Rm = add_box(Rm, [0 0 2.20],  [1.42 1.42 0.22], gold * 0.88);
        Rm = add_box(Rm, [0 -0.64 0], [0.16 0.06 3.00], amethyst);
        S.void.ruins(k).V0  = Rm.V;
        S.void.ruins(k).pos = ruinPos(k, :);
        S.void.ruins(k).ph  = k * 1.15;
        S.void.ruins(k).h   = mesh_patch(ax, Rm, 'flat', 0.16);
    end

    %% 8. Floating Astral Lantern Flames
    [Vfl, Ffl] = prim_crystal(0.24, 0.24, 0.44);
    nf = size(TP, 1); nv = size(Vfl, 1); nF = size(Ffl, 1);
    Vall = zeros(nf * nv, 3); Fall = zeros(nf * nF, size(Ffl, 2));
    for k = 1:nf
        Vall((k-1)*nv + (1:nv), :) = Vfl;
        Fall((k-1)*nF + (1:nF), :) = Ffl + (k-1) * nv;
    end
    S.flame.V0 = Vfl; S.flame.n = nf; S.flame.nv = nv;
    S.flame.h  = patch('Parent', ax, 'Vertices', Vall, 'Faces', Fall, ...
        'FaceColor', [0.68 0.45 1.00], 'EdgeColor', [0.85 0.96 1.00], ...
        'FaceLighting', 'none', 'Clipping', 'off');

    %% 9. Dynamic Lights (Streamlined for FPS + Crisp Amani)
    light('Parent', ax, 'Position', [0 -6 10], 'Style', 'infinite', 'Color', [0.54 0.58 0.80]);
    S.torchLights  = light('Parent', ax, 'Position', [0 4 4], 'Style', 'local', 'Color', [0.60 0.42 1.00]);
    S.gateLight    = light('Parent', ax, 'Position', [0 13.5 2.6], 'Style', 'local', 'Color', [0 0 0]);
    S.crystalLight = light('Parent', ax, 'Position', [-2.6 6.5 2.0], 'Style', 'local', 'Color', [0.35 0.85 1.00]);

    %% 10. Glowing Portal Beyond the Gate
    [V, F] = prim_sphere(0.95, 12);
    S.portal = patch('Parent', ax, 'Vertices', mtx_apply(mtx_translate(0, 18.5, 2.4), V), ...
        'Faces', F, 'FaceColor', [0.78 0.55 1.00], 'EdgeColor', 'none', ...
        'FaceLighting', 'none', 'Clipping', 'off');

    %% 11. The Astral Gate (3-Level Hierarchy: Frame -> Leaf -> Bolt)
    Fr = empty_mesh();
    for sd = [-1 1]
        Fr = add_box(Fr, [sd*2.96 0 2.65],    [0.95 1.05 5.30], voidStone);
        Fr = add_box(Fr, [sd*2.48 -0.54 2.65], [0.10 0.10 4.90], cyanGlow);
        Fr = add_box(Fr, [sd*2.96 -0.56 2.65], [0.14 0.08 4.40], amethyst);
    end
    Fr = add_box(Fr, [0 0 5.36],     [7.2 1.15 0.88], voidStone * 1.15);
    Fr = add_box(Fr, [0 -0.60 4.96], [7.0 0.12 0.12], gold);
    S.gate.frame.V0 = Fr.V;
    S.gate.frame.h  = mesh_patch(ax, struct('V', mtx_apply(mtx_translate(0,10,0), Fr.V), ...
        'F', Fr.F, 'C', Fr.C), 'flat', 0.22);

    % Glowing Rune Core
    [V, F] = prim_cylinder(0.40, 0.10, 14);
    V = mtx_apply(mtx_translate(0, -0.72, 5.34) * mtx_rotx(pi/2), V);
    S.rune = patch('Parent', ax, 'Vertices', mtx_apply(mtx_translate(0,10,0), V), 'Faces', F, ...
        'FaceColor', [0.75 0.25 1.00], 'EdgeColor', cyanGlow, 'LineWidth', 1.2, ...
        'FaceLighting', 'none', 'Clipping', 'off');

    for side = {'L', 'R'}
        sd = 1; if side{1} == 'L', sd = -1; end
        Lf = empty_mesh();
        Lf = add_box(Lf, [sd*1.25 0 2.45],     [2.44 0.28 4.80], slate);
        Lf = add_box(Lf, [sd*1.25 -0.18 3.55], [1.90 0.08 0.12], amethyst);
        Lf = add_box(Lf, [sd*1.25 -0.18 1.35], [1.90 0.08 0.12], cyanGlow);
        S.gate.(['leaf' side{1}]).V0 = Lf.V;
        S.gate.(['leaf' side{1}]).h  = mesh_patch(ax, Lf, 'flat', 0.24);

        Bt = empty_mesh();
        Bt = add_box(Bt, [sd*0.38 -0.32 2.45], [0.90 0.16 0.16], gold);
        S.gate.(['bolt' side{1}]).V0 = Bt.V;
        S.gate.(['bolt' side{1}]).h  = mesh_patch(ax, Bt, 'flat', 0.50);
    end

    %% 12. Hidden Panel Compatibility & Floating Cyan Crystal
    S.panelText = gobjects(1, 4);
    for k = 1:4
        S.panelText(k) = text(ax, 2.55, 4.28, 2.70, '', 'Visible', 'off');
    end

    [V, F] = prim_crystal(0.45, 0.45, 0.86);
    S.crystal.V0 = V;
    S.crystal.h  = patch('Parent', ax, 'Vertices', V, 'Faces', F, 'FaceColor', cyanGlow, ...
        'EdgeColor', [0.90 1.00 1.00], 'LineWidth', 1.0, 'FaceLighting', 'none', 'Clipping', 'off');

    %% 13. Explorer Character (Amani)
    S = build_explorer(ax, S);

    %% 14. Lightweight Cosmic Embers & Hidden Halos (No Alpha-Sorting Lag)
    ne = 35;
    S.ember.x0 = -6 + 12 * mod(sin((1:ne) * 12.9898) * 43758.5453, 1);
    S.ember.y0 = -8 + 30 * mod(sin((1:ne) * 78.233)  * 43758.5453, 1);
    S.ember.z0 =  7      * mod(sin((1:ne) * 37.719)  * 43758.5453, 1);
    S.ember.ph = 6.28    * mod(sin((1:ne) * 4.1414)  * 43758.5453, 1);
    S.ember.h  = plot3(ax, S.ember.x0, S.ember.y0, S.ember.z0, '.', ...
        'Color', [0.76 0.62 1.00], 'MarkerSize', 6.5);

    % Kept for update_scene.m compatibility, hidden to avoid OpenGL alpha lag
    [V, F] = prim_sphere(0.1, 4);
    S.halo.V0 = V; S.halo.nv = size(V, 1);
    S.halo.h  = patch('Parent', ax, 'Vertices', repmat(V, nf, 1), 'Faces', F, ...
        'Visible', 'off');

    if lite
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