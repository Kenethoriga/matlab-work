function S = build_chamber2(ax, lite)
% BUILD_CHAMBER2  Chamber II: The Inferno (Open Volcanic Caldera).
%                 Glowing red sky dome, jagged volcanic peaks, giant volcano
%                 behind the gate, tiled lava sea, raised obsidian walkway,
%                 standing iron pedestal braziers, and the Inferno Gate.

    if nargin < 2, lite = false; end
    S.lite = lite;

    set(ax, 'XLim', [-18 18], 'YLim', [-14 34], 'ZLim', [0 18], ...
        'DataAspectRatio', [1 1 1], 'Projection', 'perspective', ...
        'Visible', 'off', 'SortMethod', 'childorder', 'Clipping', 'off');
    hold(ax, 'on');

    % 6 standing pedestal brazier flame positions lining the obsidian path
    TP = [-2.15  1.0 2.55;  2.15  1.0 2.55;
          -2.15  6.0 2.55;  2.15  6.0 2.55;
          -2.15 14.0 2.55;  2.15 14.0 2.55];
    S.TP = TP;

    % Palette
    obsidian = [0.09 0.08 0.09];
    iron     = [0.13 0.11 0.12];
    peakCol  = [0.06 0.04 0.04];
    magma    = [1.00 0.34 0.05];
    emberGld = [1.00 0.70 0.20];

    %% 1. Glowing Volcanic Sky Dome (Open Caldera Horizon)
    [sx, sy, sz] = cylinder(30, 32);
    sz = sz * 22 - 1;
    sy = sy + 8;
    tSky = max(0, min(1, (sz + 1) / 22));
    Csky = zeros([size(sz), 3]);
    % Bright fiery orange-red at the horizon fading to deep crimson-black overhead
    Csky(:, :, 1) = 0.72 * (1 - tSky).^1.4 + 0.10;
    Csky(:, :, 2) = 0.20 * (1 - tSky).^2.0 + 0.01;
    Csky(:, :, 3) = 0.03 * (1 - tSky).^2.5;
    S.sky = surf(ax, sx, sy, sz, Csky, 'FaceColor', 'flat', ...
        'EdgeColor', 'none', 'FaceLighting', 'none', 'Clipping', 'off');
    % Compatibility handles for view_set.m (hides sky in top-down map view)
    S.ceil  = S.sky;
    S.wallL = patch('Parent', ax, 'XData', [], 'YData', [], 'ZData', []);
    S.wallR = patch('Parent', ax, 'XData', [], 'YData', [], 'ZData', []);

    %% 2. Wide Tiled Lava Sea Floor (Red / Crimson / Orange / Yellow Mosaic)
    tile = 1.2 + 0.6 * lite;
    [X, Y] = meshgrid(-22:tile:22, -14:tile:32);
    Z = zeros(size(X));
    r = mod(sin(X * 12.9898 + Y * 78.233) * 43758.5453, 1);

    C = zeros(numel(X), 3);
    hot  = r > 0.80;                  % bright yellow-orange lava pockets
    warm = r > 0.45 & r <= 0.80;      % glowing orange-red lava
    cool = r <= 0.45;                 % deep crimson crust

    C(hot,  1) = 1.00; C(hot,  2) = 0.72 + 0.25 * (r(hot) - 0.80) / 0.20; C(hot,  3) = 0.15;
    C(warm, 1) = 0.78 + 0.20 * r(warm); C(warm, 2) = 0.16 + 0.24 * r(warm); C(warm, 3) = 0.03;
    C(cool, 1) = 0.34 + 0.26 * r(cool); C(cool, 2) = 0.04 + 0.06 * r(cool); C(cool, 3) = 0.02;

    S.floor = surf(ax, X, Y, Z, reshape(C, [size(X) 3]), 'FaceColor', 'flat', ...
        'EdgeColor', [0.18 0.04 0.01], 'LineWidth', 0.3, 'FaceLighting', 'none');

    %% 3. Giant Volcano Behind the Gate & Jagged Black Volcanic Peaks
    Volc = empty_mesh();
    % Giant truncated volcano behind the gate (y = 20)
    [V, F] = prim_revolve([0 0; 8.5 0; 6.0 4.5; 2.8 9.2; 1.6 9.5; 0 9.0], 14);
    Volc = mesh_add(Volc, V, F, [0.18 0.09 0.06], mtx_translate(0, 20.5, 0));
    % Glowing molten crater rim at the top of the volcano
    [V, F] = prim_revolve([0 9.1; 2.85 9.1; 2.35 9.85; 1.4 9.75; 0 9.5], 14);
    Volc = mesh_add(Volc, V, F, [0.95 0.48 0.10], mtx_translate(0, 20.5, 0));

    % Jagged black volcanic mountains / spires framing the caldera
    peaks = [
        -11.5, -2.0,  4.2, 11.5;
        -8.5,   3.0,  2.8,  7.5;
        -12.5,  8.5,  4.8, 12.8;
        -7.2,  12.5,  2.5,  6.8;
        -10.5, 18.0,  4.5, 11.2;
         11.5, -1.5,  4.4, 12.0;
         8.2,   4.0,  2.6,  7.2;
         12.2,  9.5,  4.6, 13.0;
         7.5,  13.0,  2.4,  6.5;
         10.8, 18.5,  4.4, 11.5;
        -5.8,  -6.0,  2.2,  5.5;
         6.0,  -5.5,  2.4,  6.0;
    ];
    for k = 1:size(peaks, 1)
        px = peaks(k,1); py = peaks(k,2); rad = peaks(k,3); hgt = peaks(k,4);
        [V, F] = prim_revolve([0 0; rad 0; rad*0.55 hgt*0.45; 0 hgt], 6);
        Volc = mesh_add(Volc, V, F, peakCol * (0.85 + 0.3 * mod(k, 3) / 2), ...
            mtx_translate(px, py, 0) * mtx_rotz(k * 0.9));
    end

    % Small glowing lava flame-spires rising from the lava sea
    spires = [-4.5 2.5; 4.6 3.8; -5.2 9.5; 5.0 11.0; -3.8 -3.5; 4.2 -2.8];
    for k = 1:size(spires, 1)
        [V, F] = prim_revolve([0 0; 0.42 0.25; 0.36 0.9; 0.16 1.5; 0 2.0], 8);
        Volc = mesh_add(Volc, V, F, [1.0 0.32 0.06], mtx_translate(spires(k,1), spires(k,2), 0));
    end
    S.volcano = mesh_patch(ax, Volc, 'flat', 0.08);

    %% 4. Glowing Portal Beyond the Gate (drawn BEFORE gate & explorer!)
    [V, F] = prim_sphere(0.85, 18);
    S.portal = patch('Parent', ax, 'Vertices', mtx_apply(mtx_translate(0, 19, 2.2), V), 'Faces', F, ...
        'FaceColor', [1.0 0.85 0.38], 'EdgeColor', 'none', 'FaceLighting', 'none', 'Clipping', 'off');

    %% 5. Raised Obsidian Walkway & Standing Iron Pedestal Braziers
    St = empty_mesh();
    % Raised dark obsidian walkway slabs down the center with glowing edges
    St = add_box(St, [0 5.5 0.06], [3.55 29.0 0.12], magma * 0.75);
    for ys = -8.5:1.6:19.5
        St = add_box(St, [-0.82 ys 0.16], [1.56 1.48 0.18], obsidian);
        St = add_box(St, [ 0.82 ys 0.16], [1.56 1.48 0.18], obsidian * 1.1);
    end

    % 6 Tall Standing Iron Pedestal Braziers
    for k = 1:size(TP, 1)
        bx = TP(k, 1); by = TP(k, 2);
        St = add_box(St, [bx by 0.12], [0.58 0.58 0.24], iron);                 % base
        [V, F] = prim_cylinder(0.09, 2.05, 10);
        St = mesh_add(St, V, F, iron * 0.9, mtx_translate(bx, by, 1.25));       % shaft
        [V, F] = prim_revolve([0 -0.15; 0.10 -0.15; 0.34 0.18; 0.40 0.28; 0.24 0.20; 0 0.16], 12);
        St = mesh_add(St, V, F, iron * 1.15, mtx_translate(bx, by, 2.30));      % flared bowl
    end
    S.statics = mesh_patch(ax, St, 'gouraud', 0.22);

    %% 6. Brazier Flames (Combined Patch — animated by update_scene)
    [Vo, Fo] = prim_revolve([0 -0.08; 0.15 -0.05; 0.20 0.05; 0.15 0.22; 0.06 0.38; 0 0.52], 10);
    [Vi, Fi] = prim_revolve([0 -0.04; 0.08 -0.01; 0.10 0.10; 0.05 0.24; 0 0.34], 8);
    Vflame = [Vo; Vi];
    Fflame = [Fo; Fi + size(Vo, 1)];
    t = (Vflame(:, 3) - min(Vflame(:, 3))) / (max(Vflame(:, 3)) - min(Vflame(:, 3)));
    Cflame = [1.0 0.25 0.03] .* (1 - t) + [1.0 0.88 0.28] .* t;
    Cflame(size(Vo, 1) + 1:end, :) = min(1, Cflame(size(Vo, 1) + 1:end, :) * 0.35 + 0.65);

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

    %% 7. Dynamic Lights
    S.torchLights = gobjects(1, 4);
    for k = 1:4
        S.torchLights(k) = light('Parent', ax, 'Position', TP(k, :) + [0 0 0.4], ...
            'Style', 'local', 'Color', [1.0 0.45 0.15]);
    end
    S.gateLight    = light('Parent', ax, 'Position', [0 13.5 2.6], 'Style', 'local', 'Color', [0 0 0]);
    S.crystalLight = light('Parent', ax, 'Position', [-2.6 6.5 2.0], 'Style', 'local', 'Color', [1.0 0.38 0.12]);

    %% 8. The Obsidian Inferno Gate (3-Level Hierarchy: Frame -> Leaf -> Bolt)
    Fr = empty_mesh();
    for sd = [-1 1]
        Fr = add_box(Fr, [sd*2.95 -0.05 0.18], [1.18 1.24 0.36], obsidian);
        for i = 0:5
            jit = 0.85 + 0.22 * mod(i * 5 + (sd > 0) * 3, 4) / 3;
            Fr = add_box(Fr, [sd*2.95 0 0.50 + 0.84 * i], [0.90 1.08 0.80], obsidian * jit);
        end
        Fr = add_box(Fr, [sd*2.48 -0.52 2.65], [0.10 0.10 4.90], emberGld * 0.85);
    end
    Fr = add_box(Fr, [0 0 5.32],    [7.2 1.15 0.90], obsidian * 1.1);
    Fr = add_box(Fr, [0 -0.06 5.84],[7.8 1.30 0.28], iron);
    Fr = add_box(Fr, [0 -0.58 4.92],[7.0 0.10 0.10], emberGld * 0.85);
    Fr = add_box(Fr, [0 -0.20 5.35],[1.36 1.20 1.10], iron * 1.15);
    Fr = add_box(Fr, [0 -0.52 0.10],[6.2 0.56 0.16], obsidian);

    [V, F] = prim_cylinder(0.54, 0.12, 24);
    Fr = mesh_add(Fr, V, F, iron * 1.3, mtx_translate(0, -0.68, 5.32) * mtx_rotx(pi/2));

    S.gate.frame.V0 = Fr.V;
    S.gate.frame.h  = mesh_patch(ax, struct('V', mtx_apply(mtx_translate(0,10,0), Fr.V), ...
        'F', Fr.F, 'C', Fr.C), 'flat', 0.20);

    % Glowing Crimson-Orange Gate Rune
    [V, F] = prim_cylinder(0.40, 0.10, 24);
    V = mtx_apply(mtx_translate(0, -0.74, 5.32) * mtx_rotx(pi/2), V);
    S.rune = patch('Parent', ax, 'Vertices', mtx_apply(mtx_translate(0,10,0), V), 'Faces', F, ...
        'FaceColor', [0.95 0.22 0.12], 'EdgeColor', [1.0 0.72 0.25], 'LineWidth', 1.0, ...
        'FaceLighting', 'none', 'Clipping', 'off');

    % Heavy Blackened-Iron Gate Leaves
    for side = {'L', 'R'}
        sd = 1; if side{1} == 'L', sd = -1; end
        Lf = empty_mesh();
        for i = 0:4
            sh = 0.80 + 0.25 * mod(i * 7, 3) / 2;
            Lf = add_box(Lf, [sd * (0.25 + 0.5 * i) 0 2.45], [0.48 0.32 4.80], iron * sh);
        end
        for zb = [1.0 2.45 3.9]
            Lf = add_box(Lf, [sd*1.25 -0.22 zb], [2.46 0.14 0.22], [0.07 0.06 0.07]);
            for xr = [0.3 0.9 1.5 2.1]
                [V, F] = prim_sphere(0.065, 8);
                Lf = mesh_add(Lf, V, F, emberGld * 0.9, mtx_translate(sd*xr, -0.30, zb));
            end
        end
        Lf = add_box(Lf, [sd*0.38 -0.24 2.45], [0.56 0.12 0.42], iron * 1.4);
        S.gate.(['leaf' side{1}]).V0 = Lf.V;
        S.gate.(['leaf' side{1}]).h  = mesh_patch(ax, Lf, 'gouraud', 0.28);

        Bt = empty_mesh();
        [V, F] = prim_cylinder(0.09, 0.88, 14);
        Bt = mesh_add(Bt, V, F, [0.48 0.45 0.46], mtx_translate(sd*0.38, -0.34, 2.45) * mtx_roty(pi/2));
        [V, F] = prim_sphere(0.17, 12);
        Bt = mesh_add(Bt, V, F, magma, mtx_translate(0, -0.35, 2.45));
        S.gate.(['bolt' side{1}]).V0 = Bt.V;
        S.gate.(['bolt' side{1}]).h  = mesh_patch(ax, Bt, 'gouraud', 0.78);
    end

    %% 9. Hidden Right-Side Board (keeps update_scene/run_project compatible)
    [Vb, Fb] = prim_box(2.58, 0.12, 1.88);
    S.panelBorder = patch('Parent', ax, 'Vertices', Vb, 'Faces', Fb, 'Visible', 'off');
    S.panel       = patch('Parent', ax, 'Vertices', Vb, 'Faces', Fb, 'Visible', 'off');
    S.panelText   = gobjects(1, 4);
    for k = 1:4
        S.panelText(k) = text(ax, 2.55, 4.28, 2.70, '', 'Visible', 'off');
    end

    %% 10. Floating Fiery Orange Rune Crystal
    [V, F] = prim_crystal(0.44, 0.44, 0.82);
    S.crystal.V0 = V;
    S.crystal.h  = patch('Parent', ax, 'Vertices', V, 'Faces', F, 'FaceColor', [1.0 0.42 0.10], ...
        'EdgeColor', [1.0 0.85 0.35], 'LineWidth', 0.9, 'FaceLighting', 'none', 'FaceAlpha', 0.94, 'Clipping', 'off');

    %% 11. Explorer Character (Amani)
    S = add_explorer(ax, S);

    %% 12. Rising Volcanic Embers & Brazier Halos
    ne = 85;
    S.ember.x0 = -5 + 10 * mod(sin((1:ne) * 12.9898) * 43758.5453, 1);
    S.ember.y0 = -8 + 30 * mod(sin((1:ne) * 78.233)  * 43758.5453, 1);
    S.ember.z0 =  7      * mod(sin((1:ne) * 37.719)  * 43758.5453, 1);
    S.ember.ph = 6.28    * mod(sin((1:ne) * 4.1414)  * 43758.5453, 1);
    S.ember.h  = plot3(ax, S.ember.x0, S.ember.y0, S.ember.z0, '.', 'Color', [1.0 0.60 0.14], 'MarkerSize', 7);

    [V, F] = prim_sphere(0.60, 12);
    nv = size(V, 1); nF = size(F, 1);
    Vh = zeros(nf * nv, 3); Fh = zeros(nf * nF, 4);
    for k = 1:nf
        Vh((k-1)*nv + (1:nv), :) = V;
        Fh((k-1)*nF + (1:nF), :) = F + (k-1) * nv;
    end
    S.halo.V0 = V; S.halo.nv = nv;
    S.halo.h  = patch('Parent', ax, 'Vertices', Vh, 'Faces', Fh, 'FaceColor', [1.0 0.34 0.05], ...
        'EdgeColor', 'none', 'FaceAlpha', 0.13, 'FaceLighting', 'none', 'Clipping', 'off');

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

function p = mkpart(ax, M, lighting, spec)
    p.V0 = M.V;
    p.h  = mesh_patch(ax, M, lighting, spec);
end

function S = add_explorer(ax, S)
    skin = [0.86 0.64 0.48]; tunic = [0.11 0.36 0.48]; scarf = [0.72 0.14 0.14];
    pants = [0.24 0.18 0.13]; leather = [0.28 0.16 0.08]; hatCol = [0.30 0.19 0.10];
    bootCol = [0.14 0.09 0.06]; hairCol = [0.10 0.07 0.05]; gold = [0.85 0.67 0.28];

    B = empty_mesh();
    [V, F] = prim_capsule(0.25, 0.28, 16);
    B = mesh_add(B, V, F, tunic, mtx_translate(0, 0, 1.22) * mtx_scale(1.02, 0.68, 1.0));
    [V, F] = prim_cylinder(0.20, 0.10, 16);
    B = mesh_add(B, V, F, scarf, mtx_translate(0, 0, 1.57) * mtx_scale(1.05, 0.85, 1.0));
    B = add_box(B, [0 0.16 1.48], [0.14 0.06 0.24], scarf * 0.92);
    [V, F] = prim_cylinder(0.275, 0.13, 16);
    B = mesh_add(B, V, F, leather, mtx_translate(0, 0, 0.93) * mtx_scale(1.02, 0.70, 1.0));
    B = add_box(B, [0 0.195 0.93], [0.13 0.04 0.11], gold);
    B = add_box(B, [0 0.175 1.24], [0.06 0.04 0.62], leather * 1.1);
    [V, F] = prim_sphere(0.24, 18);
    B = mesh_add(B, V, F, skin, mtx_translate(0, 0, 1.84));
    [V, F] = prim_sphere(0.245, 16);
    B = mesh_add(B, V, F, hairCol, mtx_translate(0, -0.04, 1.88) * mtx_scale(1.0, 0.95, 0.85));
    for sd = [-1 1]
        [V, F] = prim_sphere(0.036, 10);
        B = mesh_add(B, V, F, [0.07 0.05 0.04], mtx_translate(sd*0.085, 0.215, 1.87));
        B = add_box(B, [sd*0.085 0.22 1.92], [0.065 0.02 0.018], hairCol);
    end
    [V, F] = prim_sphere(0.03, 8);
    B = mesh_add(B, V, F, skin * 0.92, mtx_translate(0, 0.235, 1.82));
    [V, F] = prim_cylinder(0.40, 0.045, 22);
    B = mesh_add(B, V, F, hatCol, mtx_translate(0, 0, 2.04));
    [V, F] = prim_sphere(0.245, 16);
    B = mesh_add(B, V, F, hatCol, mtx_translate(0, 0, 2.05) * mtx_scale(1, 1, 0.78));
    [V, F] = prim_cylinder(0.258, 0.065, 18);
    B = mesh_add(B, V, F, gold, mtx_translate(0, 0, 2.065));
    B = add_box(B, [0.24 -0.04 2.20], [0.03 0.08 0.24], scarf);
    B = add_box(B, [0 -0.28 1.24], [0.42 0.20 0.54], leather);
    B = add_box(B, [-0.12 -0.39 1.36], [0.06 0.03 0.10], gold);
    B = add_box(B, [ 0.12 -0.39 1.36], [0.06 0.03 0.10], gold);
    [V, F] = prim_cylinder(0.09, 0.52, 12);
    B = mesh_add(B, V, F, [0.62 0.56 0.42], mtx_translate(0, -0.28, 1.56) * mtx_roty(pi/2));

    S.char.body     = mkpart(ax, B, 'gouraud', 0.22);
    S.char.hip      = [0.15 0 0.84];  S.char.knee  = [0 0 0.43];
    S.char.shoulder = [0.30 0 1.50];  S.char.elbow = [0 0 1.20];

    for sd = [-1 1]
        nm = 'R'; if sd < 0, nm = 'L'; end
        T = empty_mesh();
        [V, F] = prim_capsule(0.115, 0.28, 12);
        T = mesh_add(T, V, F, pants, mtx_translate(sd*0.15, 0, 0.63));
        S.char.(['thigh' nm]) = mkpart(ax, T, 'gouraud', 0.12);

        T = empty_mesh();
        [V, F] = prim_capsule(0.10, 0.24, 12);
        T = mesh_add(T, V, F, bootCol * 1.25, mtx_translate(sd*0.15, 0, 0.25));
        [V, F] = prim_cylinder(0.112, 0.06, 12);
        T = mesh_add(T, V, F, gold * 0.85, mtx_translate(sd*0.15, 0, 0.36));
        T = add_box(T, [sd*0.15 0.07 0.06], [0.20 0.36 0.12], bootCol);
        S.char.(['shin' nm]) = mkpart(ax, T, 'gouraud', 0.20);

        T = empty_mesh();
        [V, F] = prim_sphere(0.132, 14);
        T = mesh_add(T, V, F, tunic * 1.1, mtx_translate(sd*0.29, 0, 1.50));
        [V, F] = prim_capsule(0.09, 0.20, 12);
        T = mesh_add(T, V, F, tunic, mtx_translate(sd*0.30, 0, 1.32));
        [V, F] = prim_sphere(0.085, 10);
        T = mesh_add(T, V, F, tunic, mtx_translate(sd*0.30, 0, 1.17));
        S.char.(['uarm' nm]) = mkpart(ax, T, 'gouraud', 0.16);

        T = empty_mesh();
        [V, F] = prim_capsule(0.075, 0.18, 12);
        T = mesh_add(T, V, F, skin, mtx_translate(sd*0.30, 0, 1.01));
        [V, F] = prim_cylinder(0.085, 0.05, 12);
        T = mesh_add(T, V, F, gold * 0.9, mtx_translate(sd*0.30, 0, 0.93));
        [V, F] = prim_sphere(0.092, 10);
        T = mesh_add(T, V, F, leather, mtx_translate(sd*0.30, 0, 0.84));
        S.char.(['farm' nm]) = mkpart(ax, T, 'gouraud', 0.22);
    end

    [V, F] = prim_revolve([0 0; 0.5 0; 0.5 0.01; 0 0.01], 20);
    S.shadow.V0 = V;
    S.shadow.h  = patch('Parent', ax, 'Vertices', V, 'Faces', F, 'FaceColor', [0 0 0], ...
        'EdgeColor', 'none', 'FaceAlpha', 0.42, 'FaceLighting', 'none', 'Clipping', 'off');
end