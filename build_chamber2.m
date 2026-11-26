function S = build_chamber2(ax, lite)
% BUILD_CHAMBER2  Chamber II: The Inferno (Full Immersive Gothic Horizon & Erupting Volcano).
%                 Open blood-red sky backdrop, sculpted volcanic terrain with winding
%                 lava rivers, red-hot erupting volcano peak, glowing cliff cascades,
%                 gnarled dead trees, gothic obelisks, and low-poly FPS optimization.

    if nargin < 2, lite = false; end
    S.lite = lite;

    set(ax, 'XLim', [-18 18], 'YLim', [-14 34], 'ZLim', [-2 18], ...
        'DataAspectRatio', [1 1 1], 'Projection', 'perspective', ...
        'Color', [0.06 0.008 0.008], 'Visible', 'off', ...
        'SortMethod', 'depth', 'Clipping', 'off');
    hold(ax, 'on');

    % 6 standing iron brazier positions lining the bridge
    TP = [-2.25  1.0 2.50;  2.25  1.0 2.50;
          -2.25  6.0 2.50;  2.25  6.0 2.50;
          -2.25 14.0 2.50;  2.25 14.0 2.50];
    S.TP = TP;

    % Dante's Inferno Gothic Palette
    pitchBlk  = [0.05 0.012 0.012];
    darkRock  = [0.14 0.025 0.022];
    obsidian  = [0.11 0.060 0.060];
    charcoal  = [0.16 0.045 0.040];
    iron      = [0.17 0.120 0.120];
    bronze    = [0.56 0.320 0.140];
    gold      = [0.96 0.740 0.240];
    bloodRed  = [0.90 0.120 0.025];
    lavaHot   = [1.00 0.540 0.070];

    %% 1. Wrapped Blood-Red Apocalyptic Sky Backdrop
    [sx, sz] = meshgrid(linspace(-28, 28, 16), linspace(-2, 19, 10));
    sy = 27.5 - 0.014 * (sx.^2);
    tZ = max(0, min(1, (sz + 2) / 21));
    glowH = exp(-((tZ - 0.24) / 0.34).^2);
    sideGlow = 0.78 + 0.22 * cos(sx * 0.14);

    Csky = zeros([size(sx), 3]);
    Csky(:, :, 1) = min(1, (0.12 + 0.86 * glowH) .* sideGlow);
    Csky(:, :, 2) = min(1, (0.01 + 0.26 * glowH.^1.5) .* sideGlow);
    Csky(:, :, 3) = min(1,  0.01 + 0.03 * glowH.^2.0);
    S.sky = surf(ax, sx, sy, sz, Csky, 'FaceColor', 'interp', ...
        'EdgeColor', 'none', 'FaceLighting', 'none', 'Clipping', 'off');

    S.ceil  = S.sky;
    S.wallL = gobjects(0);
    S.wallR = gobjects(0);

    %% 2. Full Immersive Sculpted Volcanic Ground & Winding Lava Rivers
    step = 1.8 + 0.6 * lite;
    [Xf, Yf] = meshgrid(-22:step:22, -12:step:26);
    sideDist = max(0, abs(Xf) - 2.0);
    hills    = 0.55 * sin(Xf * 0.48 + Yf * 0.32) + 0.35 * cos(Xf * 0.92 - Yf * 0.52);
    Zf       = -0.32 + 0.20 * (sideDist.^1.18) + hills .* min(1, sideDist / 2.2);
    Zf(abs(Xf) < 2.05) = -0.30;

    % Winding main lava rivers + glowing cross-fissures on both sides
    riverL = exp(-((Xf - (-5.8 + 2.6 * sin(Yf * 0.24))) / 2.3).^2);
    riverR = exp(-((Xf - ( 6.0 + 2.4 * cos(Yf * 0.21))) / 2.3).^2);
    fiss   = max(0, sin(Xf * 0.75 + 1.8 * sin(Yf * 0.38))).^6 .* (abs(Xf) > 2.2);
    lava   = min(1, max(max(riverL, riverR), 0.85 * fiss));
    rim    = 0.35 + 0.65 * max(0, min(1, (Yf + 12) / 36));

    Cf = zeros([size(Xf), 3]);
    Cf(:, :, 1) = min(1, (0.14 + 0.16 * rim) .* (1 - lava) + 0.98 * lava);
    Cf(:, :, 2) = min(1, (0.02 + 0.03 * rim) .* (1 - lava) + 0.42 * (lava.^1.6));
    Cf(:, :, 3) = min(1,  0.015 .* (1 - lava) + 0.05 * (lava.^2.0));

    S.floor = surf(ax, Xf, Yf, Zf, Cf, 'FaceColor', 'interp', ...
        'EdgeColor', 'none', 'FaceLighting', 'none');

    %% 3. Full Side Terrain, Red-Hot Erupting Volcano, Fire Banks & Trees
    Bg = empty_mesh();

    % (A) Backlit Glowing Fire Banks along the Mid-Horizon
    fireMounds = [-12.0 21.8 1.4 3.6;  -6.5 21.5 1.2 3.4;  -2.2 21.6 1.0 3.0;
                    2.4 21.6 1.0 3.0;   6.8 21.5 1.2 3.5;  12.2 21.8 1.4 3.6];
    for k = 1:size(fireMounds, 1)
        fm = fireMounds(k, :);
        [Vf, Ff] = prim_sphere(fm(4), 8);
        Mf = mtx_translate(fm(1), fm(2), fm(3)) * mtx_scale(1.4, 0.5, 0.75);
        Bg = mesh_add(Bg, Vf, Ff, bloodRed, Mf);
    end

    % (B) Jagged Black Horizon Mountain Ridge
    ridge = [-17.5 24.2 5.4 8.2;  -11.5 23.8 4.8 7.2;  -6.0 24.0 4.4 6.5;
               6.2 24.0 4.4 6.6;   11.6 23.8 4.8 7.4;  17.5 24.2 5.4 8.4];
    for k = 1:size(ridge, 1)
        [V, F] = prim_revolve([0 0; ridge(k,3) 0; ridge(k,3)*0.45 ridge(k,4)*0.55; 0 ridge(k,4)], 4);
        Bg = mesh_add(Bg, V, F, pitchBlk, mtx_translate(ridge(k,1), ridge(k,2), -0.4));
    end

    % (C) Red-Hot Erupting Volcano Peak Rising Dead-Center
    [Vb, Fb] = prim_revolve([0 0; 6.2 0; 3.8 5.8; 1.8 10.6; 0 10.2], 8);
    Bg = mesh_add(Bg, Vb, Fb, pitchBlk, mtx_translate(0, 24.2, -0.4));
    % Glowing crimson-orange molten crater rim & lava streaks (0 FPS cost)
    [Vr, Fr] = prim_revolve([0 10.1; 1.85 10.5; 1.35 11.2; 0 10.6], 8);
    Bg = mesh_add(Bg, Vr, Fr, bloodRed, mtx_translate(0, 24.2, -0.4));
    for ang = [-0.35, 0.0, 0.35]
        [Vl, Fl] = prim_box(0.32, 0.25, 6.8);
        Ml = mtx_translate(0, 24.2, -0.4) * mtx_rotz(ang) * mtx_translate(0, -2.5, 6.8) * mtx_rotx(-0.46);
        Bg = mesh_add(Bg, Vl, Fl, lavaHot, Ml);
    end

    % Lightweight Opaque Eruption (Hooks into update_scene.m with zero alpha/light lag)
    S.erupt.origin = [0, 24.2, 10.6];
    [Vj, Fj] = prim_revolve([0 0; 0.85 0; 0.60 1.6; 0.95 3.2; 0.35 4.8; 0 5.6], 6);
    S.erupt.jetV0 = Vj;
    S.erupt.jetH  = patch('Parent', ax, 'Vertices', Vj, 'Faces', Fj, ...
        'FaceColor', lavaHot, 'EdgeColor', bloodRed, 'LineWidth', 0.8, ...
        'FaceLighting', 'none', 'Clipping', 'off');

    nb = 25;
    ang = 2 * pi * mod(sin((1:nb) * 12.9898) * 43758.5453, 1);
    spd = 2.0 + 4.2 * mod(sin((1:nb) * 78.233)  * 43758.5453, 1);
    S.erupt.vx    = spd .* cos(ang);
    S.erupt.vy    = spd .* sin(ang);
    S.erupt.vz    = 7.5 + 5.5 * mod(sin((1:nb) * 37.719) * 43758.5453, 1);
    S.erupt.ph    = 3.0 * mod(sin((1:nb) * 4.1414) * 43758.5453, 1);
    S.erupt.bombs = plot3(ax, zeros(1, nb), 24.2 * ones(1, nb), 10.6 * ones(1, nb), ...
        '.', 'MarkerSize', 9, 'Color', lavaHot);
    S.erupt.light   = gobjects(0);
    S.erupt.smokeV0 = [];
    S.erupt.smoke   = gobjects(0);

    % (D) Flanking Volcanic Crags & Glowing Cliffside Lava Cascades (Left & Right)
    crags = [
        -10.2, -3.5, 3.6, 7.8;   10.2, -3.0, 3.6, 8.0;
        -11.5,  4.5, 4.2, 9.5;   11.5,  5.0, 4.2, 9.2;
        -10.8, 12.5, 4.0, 9.0;   10.8, 13.0, 4.0, 9.4;
         -9.5, 19.0, 3.8, 8.5;    9.5, 19.2, 3.8, 8.6;
    ];
    for k = 1:size(crags, 1)
        cx = crags(k,1); cy = crags(k,2); cr = crags(k,3); ch = crags(k,4);
        [Vc, Fc] = prim_revolve([0 0; cr 0; cr*0.52 ch*0.55; 0 ch], 5);
        Bg = mesh_add(Bg, Vc, Fc, darkRock, mtx_translate(cx, cy, 0.2) * mtx_rotz(k * 0.8));

        % Glowing molten lava stream cascading down the inner face of each crag
        inX = cx - sign(cx) * (cr * 0.46);
        [Vl, Fl] = prim_box(0.24, 0.24, ch * 0.72);
        Ml = mtx_translate(inX, cy - 0.3, ch * 0.38) * mtx_roty(sign(cx) * 0.28);
        Bg = mesh_add(Bg, Vl, Fl, lavaHot, Ml);
    end

    % (E) Ruined Gothic Stone Obelisks Flanking the Bridge
    obelisks = [-4.4 -1.5 2.6;   4.4 -1.0 2.8;
                -4.8  7.5 3.2;   4.8  8.0 3.0;
                -4.5 16.0 2.8;   4.5 16.2 2.9];
    for k = 1:size(obelisks, 1)
        ox = obelisks(k,1); oy = obelisks(k,2); oh = obelisks(k,3);
        Bg = add_box(Bg, [ox oy oh*0.5],        [0.85 0.85 oh], pitchBlk);
        Bg = add_box(Bg, [ox oy - 0.44 oh*0.5], [0.12 0.06 oh*0.72], bloodRed);
    end

    % (F) Two Gnarled Silhouetted Dead Trees (Left Foreground & Right Midground)
    trees = [-6.2, 2.2, 1.0,  0.10;
              7.2, 11.0, 0.9, -0.09];
    for tIdx = 1:size(trees, 1)
        tx = trees(tIdx, 1); ty = trees(tIdx, 2);
        sc = trees(tIdx, 3); lean = trees(tIdx, 4);
        [V, F] = prim_cylinder(0.26 * sc, 5.8 * sc, 6);
        Bg = mesh_add(Bg, V, F, pitchBlk, mtx_translate(tx, ty, 2.8 * sc) * mtx_roty(lean));
        branches = [
            -0.90, 0.0, 5.2,  0.13, 3.4, -0.58;
             0.82, 0.0, 5.5,  0.13, 3.2,  0.54;
            -1.65, 0.0, 7.1,  0.08, 2.4, -0.35;
             1.50, 0.0, 7.3,  0.08, 2.3,  0.38;
            -0.12, 0.0, 6.8,  0.09, 2.8, -0.12;
        ];
        for b = 1:size(branches, 1)
            br = branches(b, :) * sc;
            [Vb, Fb] = prim_cylinder(br(4), br(5), 5);
            Mb = mtx_translate(tx + br(1), ty + br(2), br(3)) * mtx_roty(branches(b, 6));
            Bg = mesh_add(Bg, Vb, Fb, pitchBlk, Mb);
        end
    end

    S.citadel = mesh_patch(ax, Bg, 'none', 0.0);

    %% 4. Charred Obsidian Bridge & Iron Pedestal Braziers (Flat-Shaded)
    St = empty_mesh();
    St = add_box(St, [0 5.0 -0.06],    [3.70 26.5 0.16], obsidian);
    St = add_box(St, [0 5.0  0.03],    [3.46 26.5 0.05], charcoal);
    St = add_box(St, [-1.78 5.0 0.06], [0.10 26.5 0.08], bronze);
    St = add_box(St, [ 1.78 5.0 0.06], [0.10 26.5 0.08], bronze);
    for ys = -6.0:2.5:16.5
        St = add_box(St, [0 ys 0.06], [3.10 0.09 0.03], bloodRed);
    end

    for k = 1:size(TP, 1)
        bx = TP(k, 1); by = TP(k, 2);
        St = add_box(St, [bx by 0.14], [0.54 0.54 0.28], obsidian);
        St = add_box(St, [bx by 1.25], [0.14 0.14 1.90], iron);
        St = add_box(St, [bx by 2.26], [0.52 0.52 0.22], bronze);
    end
    S.statics = mesh_patch(ax, St, 'flat', 0.14);

    %% 5. Brazier Flames (Low-Poly Combined Patch)
    [Vflame, Fflame] = prim_revolve([0 -0.06; 0.19 0.06; 0.12 0.28; 0 0.54], 6);
    t = (Vflame(:, 3) - min(Vflame(:, 3))) / max(1e-6, max(Vflame(:, 3)) - min(Vflame(:, 3)));
    Cflame = bloodRed .* (1 - t) + lavaHot .* t;

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

    %% 6. Minimal Lights (3 Total -> Fast + Crisp Amani)
    light('Parent', ax, 'Position', [0 -6 10], 'Style', 'infinite', 'Color', [0.54 0.54 0.64]);
    S.torchLights  = light('Parent', ax, 'Position', [0 4 4], 'Style', 'local', 'Color', [1.0 0.34 0.12]);
    S.gateLight    = light('Parent', ax, 'Position', [0 13.5 2.6], 'Style', 'local', 'Color', [0 0 0]);
    S.crystalLight = S.torchLights;

    %% 7. Glowing Portal Beyond the Gate
    [V, F] = prim_sphere(0.90, 10);
    S.portal = patch('Parent', ax, 'Vertices', mtx_apply(mtx_translate(0, 18.5, 2.3), V), ...
        'Faces', F, 'FaceColor', lavaHot, 'EdgeColor', 'none', ...
        'FaceLighting', 'none', 'Clipping', 'off');

    %% 8. Gothic Inferno Gate (3-Level Hierarchy: Frame -> Leaf -> Bolt)
    Fr = empty_mesh();
    for sd = [-1 1]
        Fr = add_box(Fr, [sd*2.96 0 2.65],    [0.98 1.08 5.30], obsidian);
        Fr = add_box(Fr, [sd*2.46 -0.54 2.65], [0.10 0.10 4.80], gold);
        Fr = add_box(Fr, [sd*2.96 -0.56 2.65], [0.16 0.08 4.40], bloodRed);
    end
    Fr = add_box(Fr, [0 0 5.36],     [7.4 1.18 0.90], obsidian * 1.15);
    Fr = add_box(Fr, [0 -0.60 4.94], [7.2 0.12 0.12], gold);
    Fr = add_box(Fr, [0 -0.62 5.74], [7.6 0.10 0.08], lavaHot);
    S.gate.frame.V0 = Fr.V;
    S.gate.frame.h  = mesh_patch(ax, struct('V', mtx_apply(mtx_translate(0,10,0), Fr.V), ...
        'F', Fr.F, 'C', Fr.C), 'flat', 0.20);

    [V, F] = prim_cylinder(0.40, 0.10, 12);
    V = mtx_apply(mtx_translate(0, -0.74, 5.34) * mtx_rotx(pi/2), V);
    S.rune = patch('Parent', ax, 'Vertices', mtx_apply(mtx_translate(0,10,0), V), 'Faces', F, ...
        'FaceColor', bloodRed, 'EdgeColor', lavaHot, 'LineWidth', 1.2, ...
        'FaceLighting', 'none', 'Clipping', 'off');

    for side = {'L', 'R'}
        sd = 1; if side{1} == 'L', sd = -1; end
        Lf = empty_mesh();
        Lf = add_box(Lf, [sd*1.25 0 2.45],     [2.44 0.30 4.80], iron);
        Lf = add_box(Lf, [sd*1.25 -0.17 3.60], [1.90 0.08 1.50], bloodRed);
        Lf = add_box(Lf, [sd*1.25 -0.19 3.60], [1.72 0.08 1.34], obsidian);
        Lf = add_box(Lf, [sd*1.25 -0.17 1.30], [1.90 0.08 1.45], bloodRed);
        Lf = add_box(Lf, [sd*1.25 -0.19 1.30], [1.72 0.08 1.28], obsidian);
        Lf = add_box(Lf, [sd*0.08 -0.22 2.45], [0.12 0.10 4.70], bronze);
        S.gate.(['leaf' side{1}]).V0 = Lf.V;
        S.gate.(['leaf' side{1}]).h  = mesh_patch(ax, Lf, 'flat', 0.22);

        Bt = empty_mesh();
        Bt = add_box(Bt, [sd*0.38 -0.34 2.45], [0.90 0.16 0.16], gold);
        S.gate.(['bolt' side{1}]).V0 = Bt.V;
        S.gate.(['bolt' side{1}]).h  = mesh_patch(ax, Bt, 'flat', 0.50);
    end

    %% 9. Hidden Panel Compatibility & Floating Crimson Crystal
    S.panelText = gobjects(1, 4);
    for k = 1:4
        S.panelText(k) = text(ax, 2.55, 4.28, 2.70, '', 'Visible', 'off');
    end

    [V, F] = prim_crystal(0.44, 0.44, 0.84);
    S.crystal.V0 = V;
    S.crystal.h  = patch('Parent', ax, 'Vertices', V, 'Faces', F, 'FaceColor', bloodRed, ...
        'EdgeColor', lavaHot, 'LineWidth', 1.0, 'FaceLighting', 'none', 'Clipping', 'off');

    %% 10. Explorer Character (Amani)
    S = build_explorer(ax, S);

    %% 11. Lightweight Embers & Hidden Halos (Zero Alpha-Sorting Lag)
    ne = 30;
    S.ember.x0 = -7 + 14 * mod(sin((1:ne) * 12.9898) * 43758.5453, 1);
    S.ember.y0 = -8 + 28 * mod(sin((1:ne) * 78.233)  * 43758.5453, 1);
    S.ember.z0 =  7      * mod(sin((1:ne) * 37.719)  * 43758.5453, 1);
    S.ember.ph = 6.28    * mod(sin((1:ne) * 4.1414)  * 43758.5453, 1);
    S.ember.h  = plot3(ax, S.ember.x0, S.ember.y0, S.ember.z0, '.', 'Color', lavaHot, 'MarkerSize', 6.5);

    [V, F] = prim_sphere(0.1, 4);
    S.halo.V0 = V; S.halo.nv = size(V, 1);
    S.halo.h  = patch('Parent', ax, 'Vertices', repmat(V, nf, 1), 'Faces', F, ...
        'Visible', 'off');
end

%% Local Helpers
function M = empty_mesh()
    M = struct('V', [], 'F', [], 'C', []);
end

function M = add_box(M, c, sz, col)
    [V, F] = prim_box(sz(1), sz(2), sz(3));
    M = mesh_add(M, V, F, col, mtx_translate(c(1), c(2), c(3)));
end