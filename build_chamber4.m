function S = build_chamber4(ax, lite)
% BUILD_CHAMBER4  Chamber IV: Crystal Caverns (Enhanced Glacial Cavern).
%                 Open luminous ice-blue mist, glacial waterfall & winding river,
%                 multi-shard cyan/sapphire crystal clusters, mossy slopes,
%                 rune-carved temple columns, distant horizon arch & golden spores.

    if nargin < 2, lite = false; end
    S.lite = lite;

    set(ax, 'XLim', [-18 18], 'YLim', [-14 34], 'ZLim', [-2 18], ...
        'DataAspectRatio', [1 1 1], 'Projection', 'perspective', ...
        'Color', [0.02 0.06 0.11], 'Visible', 'off', ...
        'SortMethod', 'depth', 'Clipping', 'off');
    hold(ax, 'on');

    % 6 stone brazier positions lining the ancient cavern path
    TP = [-2.25  1.0 2.50;  2.25  1.0 2.50;
          -2.25  6.0 2.50;  2.25  6.0 2.50;
          -2.25 14.0 2.50;  2.25 14.0 2.50];
    S.TP = TP;

    % Crystal Caverns Palette
    deepTeal    = [0.04 0.11 0.17];
    mossGreen   = [0.09 0.27 0.23];
    templeStone = [0.11 0.18 0.24];
    slate       = [0.16 0.24 0.31];
    sapphire    = [0.10 0.42 0.85];
    cyanCrystal = [0.22 0.78 0.96];
    iceGlow     = [0.68 0.94 1.00];
    amberOrb    = [1.00 0.78 0.20];

    %% 1. Luminous Ice-Blue Cavern Mist Backdrop (Single Fast Surface)
    [sx, sz] = meshgrid(linspace(-28, 28, 16), linspace(-2, 19, 10));
    sy = 27.5 - 0.014 * (sx.^2);
    mistCore = exp(-(((sx + 3.5) / 13.5).^2 + ((sz - 6.5) / 7.5).^2));
    mistWide = exp(-((sz - 5.5) / 11.0).^2);

    Csky = zeros([size(sx), 3]);
    Csky(:, :, 1) = min(1, 0.03 + 0.18 * mistWide + 0.48 * mistCore);
    Csky(:, :, 2) = min(1, 0.09 + 0.42 * mistWide + 0.44 * mistCore);
    Csky(:, :, 3) = min(1, 0.16 + 0.62 * mistWide + 0.22 * mistCore);
    S.sky = surf(ax, sx, sy, sz, Csky, 'FaceColor', 'interp', ...
        'EdgeColor', 'none', 'FaceLighting', 'none', 'Clipping', 'off');

    S.ceil  = S.sky;
    S.wallL = gobjects(0);
    S.wallR = gobjects(0);

    %% 2. Sculpted Mossy-Teal Floor & Winding Glacial River Under Bridge
    step = 1.6 + 0.5 * lite;
    [Xf, Yf] = meshgrid(-22:step:22, -12:step:26);
    sideDist = max(0, abs(Xf) - 2.0);
    hills    = 0.55 * sin(Xf * 0.48 + Yf * 0.32) + 0.35 * cos(Xf * 0.92 - Yf * 0.52);

    % Winding glacial stream crossing underneath the stone bridge around y = 3..9
    riverPath = 4.2 + 2.6 * sin(Xf * 0.26);
    river     = exp(-((Yf - riverPath) / 2.1).^2);

    Zf = -0.32 + 0.22 * (sideDist.^1.18) + hills .* min(1, sideDist / 2.2) - 0.28 * river;
    Zf(abs(Xf) < 2.05) = -0.32 - 0.16 * river(abs(Xf) < 2.05);

    depthT = max(0, min(1, (Yf + 10) / 34));
    mossW  = (1 - depthT) .* min(1, sideDist / 3.5) .* (1 - river);
    iceW   = depthT .* (1 - river);

    Cf = zeros([size(Xf), 3]);
    Cf(:, :, 1) = min(1, 0.05 + 0.06 * mossW + 0.24 * iceW + 0.36 * river);
    Cf(:, :, 2) = min(1, 0.14 + 0.18 * mossW + 0.46 * iceW + 0.78 * river);
    Cf(:, :, 3) = min(1, 0.20 + 0.06 * mossW + 0.58 * iceW + 0.96 * river);

    S.floor = surf(ax, Xf, Yf, Zf, Cf, 'FaceColor', 'interp', ...
        'EdgeColor', 'none', 'FaceLighting', 'none');

    %% 3. Temple Columns, Glacial Waterfall, Crystal Bouquets & Golden Spores
    Cav = empty_mesh();

    % (A) Rune-Carved Ancient Temple Pillars & Overhead Stone Lintel
    pillars = [-9.5, 4.0, 1.35, 16.0;
                7.2, 7.5, 1.25, 15.5;
               -8.5, 15.5, 1.20, 15.0;
                8.5, 15.5, 1.20, 15.0];
    for k = 1:size(pillars, 1)
        px = pillars(k,1); py = pillars(k,2); pr = pillars(k,3); ph = pillars(k,4);
        Cav = add_box(Cav, [px py 0.5],          [pr*2.3 pr*2.3 1.0], slate);
        Cav = add_box(Cav, [px py ph*0.5],     [pr*1.6 pr*1.6 ph], templeStone);
        Cav = add_box(Cav, [px py ph - 0.6],   [pr*2.2 pr*2.2 1.1], slate);
        % Glowing cyan rune strip inlaid on the inner face of each column
        inX = px - sign(px) * (pr * 0.82);
        Cav = add_box(Cav, [inX py ph*0.48],   [0.08 0.16 ph*0.62], cyanCrystal);
    end
    Cav = add_box(Cav, [0, 6.5, 14.6], [24.0, 2.2, 1.6], deepTeal);
    Cav = add_box(Cav, [0, 6.5, 13.7], [24.0, 2.5, 0.4], templeStone);

    % Hanging glowing sapphire-blue crystal vines & mossy tendrils on overhead beam
    vineX = [-5.2, -3.6, -2.1, -0.8, 0.9, 2.4, 3.9];
    vineL = [ 2.4,  3.2,  1.9,  2.8,  2.2,  3.0,  1.8];
    for k = 1:numel(vineX)
        vx = vineX(k); vl = vineL(k);
        Cav = add_crystal(Cav, 0.18, 0.18, vl * 0.50, sapphire,    mtx_translate(vx, 6.2, 13.6 - vl*0.5));
        Cav = add_crystal(Cav, 0.12, 0.12, vl * 0.35, cyanCrystal, mtx_translate(vx, 6.2, 13.6 - vl));
        % Companion mossy vine strand
        Cav = add_box(Cav, [vx + 0.45, 6.1, 13.6 - vl*0.35], [0.08 0.08 vl*0.7], mossGreen);
    end

    % (B) Distant Ice-Blue Crystal Spires, Glacial Waterfall & Ruined Horizon Arch
    spires = [
        -11.5, 22.5, 3.2, 11.5;  -7.2, 23.5, 2.6, 13.5;  -3.6, 24.0, 2.2, 14.2;
          0.5, 24.2, 2.4, 12.0;   4.5, 23.5, 2.8, 11.2;   9.5, 22.5, 3.4, 10.5;
    ];
    for k = 1:size(spires, 1)
        sx0 = spires(k,1); sy0 = spires(k,2); sr = spires(k,3); sh = spires(k,4);
        [Vs, Fs] = prim_revolve([0 0; sr 0; sr*0.42 sh*0.65; 0 sh], 5);
        sCol = [0.28 0.68 0.92] * (0.75 + 0.25 * mod(k, 2));
        Cav = mesh_add(Cav, Vs, Fs, sCol, mtx_translate(sx0, sy0, -0.3) * mtx_rotz(k * 0.6));
    end

    % Cascading Glacial Waterfall pouring down the distant left-center cliff
    Cav = add_box(Cav, [-5.4, 21.8, 5.2], [1.45, 0.35, 10.8], cyanCrystal);
    Cav = add_box(Cav, [-5.4, 21.6, 5.2], [0.75, 0.38, 10.8], iceGlow);
    [Vw, Fw] = prim_sphere(1.3, 8);
    Cav = mesh_add(Cav, Vw, Fw, iceGlow, mtx_translate(-5.4, 21.2, -0.1) * mtx_scale(1.4, 1.0, 0.45));

    % Distant Ruined Stone Torii/Archway Silhouetted in the Mist (Left-Center)
    Cav = add_box(Cav, [-3.9, 20.5, 2.2], [0.42, 0.42, 4.4], templeStone * 1.15);
    Cav = add_box(Cav, [-2.1, 20.5, 2.2], [0.42, 0.42, 4.4], templeStone * 1.15);
    Cav = add_box(Cav, [-3.0, 20.5, 4.3], [2.70, 0.48, 0.36], slate * 1.15);
    Cav = add_box(Cav, [-3.0, 20.5, 3.7], [2.20, 0.36, 0.22], templeStone * 1.15);

    % (C) Rocky Moss-Covered Banks & Multi-Shard Cyan Crystal Bouquets
    % Massive hero crystal cluster jutting diagonally from the upper right
    Mh  = mtx_translate(8.4, 3.2, 5.8) * mtx_roty(-0.42) * mtx_rotx(0.18);
    Cav = add_crystal(Cav, 1.35, 1.35, 5.2, cyanCrystal, Mh);
    Mh2 = mtx_translate(7.4, 2.2, 4.4) * mtx_roty(-0.52) * mtx_rotx(-0.15);
    Cav = add_crystal(Cav, 0.95, 0.95, 3.6, sapphire, Mh2);
    Mh3 = mtx_translate(9.1, 2.0, 4.0) * mtx_roty(-0.30) * mtx_rotx(0.24);
    Cav = add_crystal(Cav, 0.72, 0.72, 3.0, iceGlow, Mh3);

    % Left & Right multi-shard crystal clusters along the mossy slopes
    clusters = [
        -5.2, -1.2, 0.55, 2.1,  0.48,  0.12;
        -6.1, -0.4, 0.42, 1.6,  0.65, -0.15;
         4.8, -0.8, 0.50, 1.9, -0.46,  0.10;
         5.6,  0.2, 0.38, 1.5, -0.62, -0.12;
        -6.4,  6.5, 0.65, 2.5,  0.44,  0.10;
         6.2,  6.8, 0.62, 2.4, -0.45, -0.10;
        -5.8, 13.5, 0.58, 2.3,  0.40,  0.08;
         5.8, 13.8, 0.58, 2.3, -0.40, -0.08;
    ];
    for k = 1:size(clusters, 1)
        cx = clusters(k,1); cy = clusters(k,2);
        cr = clusters(k,3); ch = clusters(k,4);
        ry = clusters(k,5); rx = clusters(k,6);
        cz = 0.25 + 0.16 * max(0, abs(cx) - 2.0);
        cCol = cyanCrystal;
        if mod(k, 2) == 0, cCol = sapphire; end

        % Primary crystal shard
        Mc = mtx_translate(cx, cy, cz + ch*0.45) * mtx_roty(ry) * mtx_rotx(rx);
        Cav = add_crystal(Cav, cr, cr, ch, cCol, Mc);
        % Secondary companion crystal shard angled beside it
        Mc2 = mtx_translate(cx + sign(cx)*0.32, cy - 0.28, cz + ch*0.30) * mtx_roty(ry*1.25) * mtx_rotx(rx - 0.18);
        Cav = add_crystal(Cav, cr*0.65, cr*0.65, ch*0.65, iceGlow, Mc2);

        % Mossy boulder base anchoring each crystal bouquet
        [Vb, Fb] = prim_sphere(cr * 1.95, 7);
        Mb = mtx_translate(cx + sign(cx)*0.4, cy, cz) * mtx_scale(1.35, 1.15, 0.65);
        Cav = mesh_add(Cav, Vb, Fb, mossGreen, Mb);
    end

    % (D) Warm Golden-Amber Spore / Firefly Orbs Perched on the Mossy Banks
    orbs = [
        -4.2, -2.2, 0.85;   4.3, -1.8, 0.95;
        -4.9,  3.2, 1.25;   4.7,  2.8, 1.35;
        -4.4,  9.2, 1.15;   4.5,  9.5, 1.20;
        -4.8, 15.2, 1.30;   4.8, 15.0, 1.25;
    ];
    for k = 1:size(orbs, 1)
        ox = orbs(k,1); oy = orbs(k,2); oz = orbs(k,3);
        [Vs, Fs] = prim_cylinder(0.03, oz, 5);
        Cav = mesh_add(Cav, Vs, Fs, mossGreen, mtx_translate(ox, oy, oz*0.5));
        [Vo, Fo] = prim_sphere(0.18, 8);
        Cav = mesh_add(Cav, Vo, Fo, amberOrb, mtx_translate(ox, oy, oz));
        % Smaller secondary spore bud on alternating stalks
        if mod(k, 2) == 1
            [Vo2, Fo2] = prim_sphere(0.11, 6);
            Cav = mesh_add(Cav, Vo2, Fo2, amberOrb, mtx_translate(ox + sign(ox)*0.24, oy + 0.15, oz*0.72));
        end
    end

    % (E) Crystal Crown Framing the Exit Portal Behind the Gate
    for ang = linspace(-0.9, 0.9, 5)
        px = 2.1 * sin(ang);
        pz = 2.3 + 1.8 * cos(ang);
        Mp = mtx_translate(px, 18.4, pz) * mtx_roty(-ang * 0.85);
        Cav = add_crystal(Cav, 0.22, 0.22, 0.95, cyanCrystal, Mp);
    end

    S.cavern = mesh_patch(ax, Cav, 'none', 0.0);

    %% 4. Ancient Mossy-Slate Bridge & Stone Braziers (Flat-Shaded)
    St = empty_mesh();
    St = add_box(St, [0 5.0 -0.06],    [3.70 26.5 0.16], deepTeal);
    St = add_box(St, [0 5.0  0.03],    [3.46 26.5 0.05], slate);
    St = add_box(St, [-1.78 5.0 0.06], [0.10 26.5 0.08], mossGreen * 1.3);
    St = add_box(St, [ 1.78 5.0 0.06], [0.10 26.5 0.08], mossGreen * 1.3);
    for ys = -6.0:2.5:16.5
        St = add_box(St, [0 ys 0.06], [3.10 0.09 0.03], cyanCrystal * 0.85);
    end

    for k = 1:size(TP, 1)
        bx = TP(k, 1); by = TP(k, 2);
        St = add_box(St, [bx by 0.14], [0.54 0.54 0.28], templeStone);
        St = add_box(St, [bx by 1.25], [0.14 0.14 1.90], slate);
        St = add_box(St, [bx by 2.26], [0.52 0.52 0.22], mossGreen * 1.4);
    end
    S.statics = mesh_patch(ax, St, 'flat', 0.16);

    %% 5. Warm Golden-Amber Brazier Flames
    [Vflame, Fflame] = prim_revolve([0 -0.06; 0.19 0.06; 0.12 0.28; 0 0.54], 6);
    t = (Vflame(:, 3) - min(Vflame(:, 3))) / max(1e-6, max(Vflame(:, 3)) - min(Vflame(:, 3)));
    Cflame = [1.00 0.55 0.10] .* (1 - t) + [1.00 0.92 0.45] .* t;

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
    light('Parent', ax, 'Position', [0 -6 10], 'Style', 'infinite', 'Color', [0.52 0.62 0.72]);
    S.torchLights  = light('Parent', ax, 'Position', [0 4 4], 'Style', 'local', 'Color', [0.45 0.85 1.00]);
    S.gateLight    = light('Parent', ax, 'Position', [0 13.5 2.6], 'Style', 'local', 'Color', [0 0 0]);
    S.crystalLight = S.torchLights;

    %% 7. Glowing Ice-Cyan Portal Beyond the Gate
    [V, F] = prim_sphere(0.90, 10);
    S.portal = patch('Parent', ax, 'Vertices', mtx_apply(mtx_translate(0, 18.5, 2.3), V), ...
        'Faces', F, 'FaceColor', iceGlow, 'EdgeColor', 'none', ...
        'FaceLighting', 'none', 'Clipping', 'off');

    %% 8. Crystal Temple Gate (3-Level Hierarchy: Frame -> Leaf -> Bolt)
    Fr = empty_mesh();
    for sd = [-1 1]
        Fr = add_box(Fr, [sd*2.96 0 2.65],    [0.98 1.08 5.30], templeStone);
        Fr = add_box(Fr, [sd*2.46 -0.54 2.65], [0.10 0.10 4.80], cyanCrystal);
        Fr = add_box(Fr, [sd*2.96 -0.56 2.65], [0.16 0.08 4.40], sapphire);
    end
    Fr = add_box(Fr, [0 0 5.36],     [7.4 1.18 0.90], slate);
    Fr = add_box(Fr, [0 -0.60 4.94], [7.2 0.12 0.12], cyanCrystal);
    Fr = add_box(Fr, [0 -0.62 5.74], [7.6 0.10 0.08], iceGlow);
    S.gate.frame.V0 = Fr.V;
    S.gate.frame.h  = mesh_patch(ax, struct('V', mtx_apply(mtx_translate(0,10,0), Fr.V), ...
        'F', Fr.F, 'C', Fr.C), 'flat', 0.22);

    [V, F] = prim_cylinder(0.40, 0.10, 12);
    V = mtx_apply(mtx_translate(0, -0.74, 5.34) * mtx_rotx(pi/2), V);
    S.rune = patch('Parent', ax, 'Vertices', mtx_apply(mtx_translate(0,10,0), V), 'Faces', F, ...
        'FaceColor', cyanCrystal, 'EdgeColor', iceGlow, 'LineWidth', 1.2, ...
        'FaceLighting', 'none', 'Clipping', 'off');

    for side = {'L', 'R'}
        sd = 1; if side{1} == 'L', sd = -1; end
        Lf = empty_mesh();
        Lf = add_box(Lf, [sd*1.25 0 2.45],     [2.44 0.30 4.80], deepTeal);
        Lf = add_box(Lf, [sd*1.25 -0.17 3.60], [1.90 0.08 1.50], sapphire);
        Lf = add_box(Lf, [sd*1.25 -0.19 3.60], [1.72 0.08 1.34], templeStone);
        Lf = add_box(Lf, [sd*1.25 -0.17 1.30], [1.90 0.08 1.45], cyanCrystal);
        Lf = add_box(Lf, [sd*1.25 -0.19 1.30], [1.72 0.08 1.28], templeStone);
        Lf = add_box(Lf, [sd*0.08 -0.22 2.45], [0.12 0.10 4.70], amberOrb);
        S.gate.(['leaf' side{1}]).V0 = Lf.V;
        S.gate.(['leaf' side{1}]).h  = mesh_patch(ax, Lf, 'flat', 0.24);

        Bt = empty_mesh();
        Bt = add_box(Bt, [sd*0.38 -0.34 2.45], [0.90 0.16 0.16], amberOrb);
        S.gate.(['bolt' side{1}]).V0 = Bt.V;
        S.gate.(['bolt' side{1}]).h  = mesh_patch(ax, Bt, 'flat', 0.50);
    end

    %% 9. Hidden Panel Compatibility & Floating Cyan Crystal Clue
    S.panelText = gobjects(1, 4);
    for k = 1:4
        S.panelText(k) = text(ax, 2.55, 4.28, 2.70, '', 'Visible', 'off');
    end

    [V, F] = prim_crystal(0.46, 0.46, 0.88);
    S.crystal.V0 = V;
    S.crystal.h  = patch('Parent', ax, 'Vertices', V, 'Faces', F, 'FaceColor', cyanCrystal, ...
        'EdgeColor', iceGlow, 'LineWidth', 1.0, 'FaceLighting', 'none', 'Clipping', 'off');

    %% 10. Explorer Character (Amani)
    S = build_explorer(ax, S);

    %% 11. Drifting Golden Firefly Spores & Hidden Halos (Zero Alpha Lag)
    ne = 32;
    S.ember.x0 = -7 + 14 * mod(sin((1:ne) * 12.9898) * 43758.5453, 1);
    S.ember.y0 = -8 + 28 * mod(sin((1:ne) * 78.233)  * 43758.5453, 1);
    S.ember.z0 =  7      * mod(sin((1:ne) * 37.719)  * 43758.5453, 1);
    S.ember.ph = 6.28    * mod(sin((1:ne) * 4.1414)  * 43758.5453, 1);
    S.ember.h  = plot3(ax, S.ember.x0, S.ember.y0, S.ember.z0, '.', 'Color', amberOrb, 'MarkerSize', 7.0);

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

function M = add_crystal(M, rx, ry, h, col, T)
    [V, F] = prim_crystal(rx, ry, h);
    if size(F, 2) == 3
        F = [F, F(:, 3)];
    end
    M = mesh_add(M, V, F, col, T);
end