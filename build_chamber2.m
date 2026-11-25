function S = build_chamber2(ax, lite)
% BUILD_CHAMBER2  Chamber II: The Inferno (High-Graphics Volcanic Caldera).
%                 Smooth gradient volcanic sky, giant volcano with lava streams,
%                 jagged basalt peaks, glowing lava sea, raised obsidian walkway,
%                 iron pedestal braziers, and an ornate Inferno Gate.

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

    % Rich Inferno Palette
    obsidian = [0.09 0.08 0.10];
    basalt   = [0.14 0.10 0.10];
    iron     = [0.16 0.14 0.16];
    bronze   = [0.58 0.40 0.18];
    gold     = [0.95 0.74 0.28];
    magma    = [1.00 0.34 0.04];

    %% 1. Smooth Gradient Volcanic Sky Dome
    [sx, sy, sz] = cylinder(32, 40);
    sz = sz * 24 - 1;
    sy = sy + 8;
    tSky = max(0, min(1, (sz + 1) / 24));
    Csky = zeros([size(sz), 3]);
    Csky(:, :, 1) = 0.85 * (1 - tSky).^1.5 + 0.08;
    Csky(:, :, 2) = 0.26 * (1 - tSky).^2.2 + 0.01;
    Csky(:, :, 3) = 0.04 * (1 - tSky).^3.0 + 0.01;
    S.sky = surf(ax, sx, sy, sz, Csky, 'FaceColor', 'interp', ...
        'EdgeColor', 'none', 'FaceLighting', 'none', 'Clipping', 'off');

    % Compatibility handles for view_set.m
    S.ceil  = S.sky;
    S.wallL = patch('Parent', ax, 'XData', [], 'YData', [], 'ZData', []);
    S.wallR = patch('Parent', ax, 'XData', [], 'YData', [], 'ZData', []);

    %% 2. Glowing Volcanic Lava Sea Floor
    tile = 1.0 + 0.6 * lite;
    [X, Y] = meshgrid(-22:tile:22, -14:tile:32);
    Z = zeros(size(X));
    r = mod(sin(X * 12.9898 + Y * 78.233) * 43758.5453, 1);

    C = zeros(numel(X), 3);
    hot  = r > 0.78;
    warm = r > 0.42 & r <= 0.78;
    cool = r <= 0.42;

    C(hot,  1) = 1.00; C(hot,  2) = 0.74 + 0.24 * (r(hot) - 0.78) / 0.22; C(hot,  3) = 0.16;
    C(warm, 1) = 0.82 + 0.18 * r(warm); C(warm, 2) = 0.18 + 0.26 * r(warm); C(warm, 3) = 0.03;
    C(cool, 1) = 0.30 + 0.26 * r(cool); C(cool, 2) = 0.04 + 0.06 * r(cool); C(cool, 3) = 0.02;

    S.floor = surf(ax, X, Y, Z, reshape(C, [size(X) 3]), 'FaceColor', 'flat', ...
        'EdgeColor', [0.16 0.03 0.01], 'LineWidth', 0.25, 'FaceLighting', 'none');

    %% 3. Giant Volcano with Lava Streams & Jagged Caldera Peaks
    Volc = empty_mesh();
    % Main volcano cone behind the gate
    [V, F] = prim_revolve([0 0; 9.2 0; 6.4 4.8; 3.0 9.6; 1.7 9.9; 0 9.3], 18);
    Volc = mesh_add(Volc, V, F, [0.15 0.08 0.06], mtx_translate(0, 21.0, 0));
    % Glowing molten crater rim
    [V, F] = prim_revolve([0 9.4; 3.05 9.4; 2.45 10.2; 1.4 10.0; 0 9.7], 18);
    Volc = mesh_add(Volc, V, F, [1.00 0.50 0.10], mtx_translate(0, 21.0, 0));

    % 3 glowing lava streams flowing down the volcano slopes
    for ang = [-0.55, 0.0, 0.55]
        [V, F] = prim_box(0.55, 0.35, 9.2);
        M = mtx_translate(0, 21.0, 0) * mtx_rotz(ang) * mtx_translate(0, -5.2, 4.6) * mtx_rotx(-0.56);
        Volc = mesh_add(Volc, V, F, magma, M);
    end

    % Jagged black volcanic mountains framing the caldera
    peaks = [
        -11.5, -2.0,  4.4, 12.0;  -8.4,   3.0,  2.8,  7.8;
        -12.5,  8.5,  5.0, 13.5;  -7.2,  12.5,  2.6,  7.0;
        -10.5, 18.0,  4.6, 11.8;   11.5, -1.5,  4.5, 12.4;
          8.2,  4.0,  2.7,  7.5;   12.2,  9.5,  4.8, 13.6;
          7.5, 13.0,  2.5,  6.8;   10.8, 18.5,  4.5, 12.0;
         -5.8, -6.0,  2.2,  5.6;    6.0, -5.5,  2.4,  6.2;
    ];
    for k = 1:size(peaks, 1)
        px = peaks(k,1); py = peaks(k,2); rad = peaks(k,3); hgt = peaks(k,4);
        [V, F] = prim_revolve([0 0; rad 0; rad*0.52 hgt*0.48; 0 hgt], 6);
        Volc = mesh_add(Volc, V, F, [0.06 0.04 0.045] * (0.85 + 0.3 * mod(k, 3) / 2), ...
            mtx_translate(px, py, 0) * mtx_rotz(k * 0.9));
    end

    % Glowing lava flame-spires rising from the lava sea
    spires = [-4.5 2.5; 4.6 3.8; -5.2 9.5; 5.0 11.0; -3.8 -3.5; 4.2 -2.8];
    for k = 1:size(spires, 1)
        [V, F] = prim_revolve([0 0; 0.44 0.25; 0.36 0.95; 0.15 1.6; 0 2.1], 8);
        Volc = mesh_add(Volc, V, F, [1.0 0.34 0.06], mtx_translate(spires(k,1), spires(k,2), 0));
    end
    S.volcano = mesh_patch(ax, Volc, 'flat', 0.10);


    %% 3b. Volcano Eruption Fountain, Lava Bombs & Crater Flash Light
    S.erupt.origin = [0, 21.0, 9.6];

    % Molten lava jet shooting up from the crater
    [Vj, Fj] = prim_revolve([0 0; 1.15 0; 0.85 1.8; 1.45 3.6; 0.65 5.2; 0 6.2], 14);
    tj = (Vj(:, 3) - min(Vj(:, 3))) / max(1e-6, max(Vj(:, 3)) - min(Vj(:, 3)));
    Cj = [1.00 0.22 0.02] .* (1 - tj) + [1.00 0.92 0.35] .* tj;
    S.erupt.jetV0 = Vj;
    S.erupt.jetH  = patch('Parent', ax, 'Vertices', Vj, 'Faces', Fj, ...
        'FaceVertexCData', Cj, 'FaceColor', 'interp', 'EdgeColor', 'none', ...
        'FaceLighting', 'none', 'FaceAlpha', 0.92, 'Clipping', 'off');

    % 45 ballistic lava bombs launched from the crater
    nb = 45;
    ang = 2 * pi * mod(sin((1:nb) * 12.9898) * 43758.5453, 1);
    spd = 2.2 + 4.8 * mod(sin((1:nb) * 78.233)  * 43758.5453, 1);
    S.erupt.vx  = spd .* cos(ang);
    S.erupt.vy  = spd .* sin(ang);
    S.erupt.vz  = 8.5 + 6.5 * mod(sin((1:nb) * 37.719) * 43758.5453, 1);
    S.erupt.ph  = 3.0 * mod(sin((1:nb) * 4.1414) * 43758.5453, 1);
    S.erupt.bombs = plot3(ax, zeros(1, nb), 21 * ones(1, nb), 10 * ones(1, nb), ...
        'o', 'MarkerSize', 5.5, 'MarkerFaceColor', [1.0 0.72 0.16], ...
        'MarkerEdgeColor', [1.0 0.25 0.02]);

    % Overhead crater flash light
    S.erupt.light = light('Parent', ax, 'Position', [0 21.0 13.0], ...
        'Style', 'local', 'Color', [1.0 0.38 0.08]);

    %% 4. Glowing Portal Beyond the Gate (drawn BEFORE gate & explorer)
    [V, F] = prim_sphere(0.85, 18);
    S.portal = patch('Parent', ax, 'Vertices', mtx_apply(mtx_translate(0, 19, 2.2), V), 'Faces', F, ...
        'FaceColor', [1.0 0.85 0.38], 'EdgeColor', 'none', 'FaceLighting', 'none', 'Clipping', 'off');

    %% 5. Raised Obsidian Walkway & Ornate Iron Pedestal Braziers
    St = empty_mesh();
    % Glowing magma under-glow & stepped obsidian bridge-slabs
    St = add_box(St, [0 5.5 0.05], [3.70 29.0 0.10], magma * 0.85);
    St = add_box(St, [0 5.5 0.11], [3.45 29.0 0.08], obsidian * 0.85);
    for ys = -8.5:1.6:19.5
        St = add_box(St, [-0.82 ys 0.19], [1.54 1.46 0.14], obsidian);
        St = add_box(St, [ 0.82 ys 0.19], [1.54 1.46 0.14], obsidian * 1.12);
        % Subtle gold-bronze curb markers along the walkway
        St = add_box(St, [-1.68 ys 0.24], [0.10 0.42 0.08], bronze);
        St = add_box(St, [ 1.68 ys 0.24], [0.10 0.42 0.08], bronze);
    end

    % 6 Tall Standing Iron & Gold Pedestal Braziers
    for k = 1:size(TP, 1)
        bx = TP(k, 1); by = TP(k, 2);
        St = add_box(St, [bx by 0.12], [0.64 0.64 0.24], obsidian);
        St = add_box(St, [bx by 0.28], [0.48 0.48 0.12], bronze);
        [V, F] = prim_cylinder(0.09, 1.98, 12);
        St = mesh_add(St, V, F, iron, mtx_translate(bx, by, 1.30));
        [V, F] = prim_cylinder(0.13, 0.10, 12);
        St = mesh_add(St, V, F, gold * 0.85, mtx_translate(bx, by, 1.85));
        [V, F] = prim_revolve([0 -0.15; 0.10 -0.15; 0.36 0.18; 0.42 0.28; 0.25 0.20; 0 0.16], 14);
        St = mesh_add(St, V, F, iron * 1.15, mtx_translate(bx, by, 2.30));
    end
    S.statics = mesh_patch(ax, St, 'gouraud', 0.26);

    %% 6. Brazier Flames (Combined Patch)
    [Vo, Fo] = prim_revolve([0 -0.08; 0.15 -0.05; 0.21 0.06; 0.15 0.24; 0.06 0.40; 0 0.56], 10);
    [Vi, Fi] = prim_revolve([0 -0.04; 0.08 -0.01; 0.10 0.10; 0.05 0.25; 0 0.36], 8);
    Vflame = [Vo; Vi];
    Fflame = [Fo; Fi + size(Vo, 1)];
    t = (Vflame(:, 3) - min(Vflame(:, 3))) / (max(Vflame(:, 3)) - min(Vflame(:, 3)));
    Cflame = [1.0 0.24 0.03] .* (1 - t) + [1.0 0.90 0.30] .* t;
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
            'Style', 'local', 'Color', [1.0 0.48 0.16]);
    end
    S.gateLight    = light('Parent', ax, 'Position', [0 13.5 2.6], 'Style', 'local', 'Color', [0 0 0]);
    S.crystalLight = light('Parent', ax, 'Position', [-2.6 6.5 2.0], 'Style', 'local', 'Color', [1.0 0.40 0.12]);

    %% 8. Monumental Ornate Inferno Gate (3-Level Hierarchy: Frame -> Leaf -> Bolt)
    Fr = empty_mesh();
    for sd = [-1 1]
        % Heavy stepped obsidian & bronze gatepost plinth
        Fr = add_box(Fr, [sd*2.98 -0.05 0.20], [1.32 1.32 0.40], obsidian);
        Fr = add_box(Fr, [sd*2.98 -0.05 0.46], [1.14 1.18 0.14], bronze);
        for i = 0:5
            jit = 0.86 + 0.20 * mod(i * 5 + (sd > 0) * 3, 4) / 3;
            Fr = add_box(Fr, [sd*2.98 0 0.72 + 0.78 * i], [0.96 1.12 0.74], basalt * jit);
        end
        % Vertical glowing magma channel & gold molding on each gatepost
        Fr = add_box(Fr, [sd*2.46 -0.54 2.65], [0.10 0.10 4.80], gold * 0.90);
        Fr = add_box(Fr, [sd*2.98 -0.58 2.65], [0.14 0.08 4.40], magma);
        % Crowned horned spire on top of each gatepost
        Fr = add_box(Fr, [sd*3.35 -0.05 6.18], [0.65 0.70 0.45], obsidian);
        Fr = add_box(Fr, [sd*3.35 -0.05 6.46], [0.35 0.40 0.25], gold * 0.85);
    end
    % Tiered Temple Pediment & Cornice
    Fr = add_box(Fr, [0 0 5.32],     [7.4 1.20 0.92], obsidian * 1.15);
    Fr = add_box(Fr, [0 -0.06 5.86], [8.0 1.36 0.26], iron * 1.1);
    Fr = add_box(Fr, [0 -0.08 6.14], [6.2 1.18 0.30], obsidian);
    Fr = add_box(Fr, [0 -0.62 4.92], [7.2 0.12 0.12], gold * 0.92);
    Fr = add_box(Fr, [0 -0.64 5.76], [7.8 0.10 0.08], magma);
    Fr = add_box(Fr, [0 -0.22 5.40], [1.46 1.26 1.18], iron * 1.2);
    Fr = add_box(Fr, [0 -0.24 6.15], [1.66 1.32 0.34], gold * 0.88);
    Fr = add_box(Fr, [0 -0.52 0.10], [6.3 0.58 0.16], obsidian);

    % Multi-ringed Gold & Obsidian Rune Bezel
    [V, F] = prim_cylinder(0.60, 0.12, 24);
    Fr = mesh_add(Fr, V, F, obsidian, mtx_translate(0, -0.66, 5.34) * mtx_rotx(pi/2));
    [V, F] = prim_cylinder(0.52, 0.14, 24);
    Fr = mesh_add(Fr, V, F, gold, mtx_translate(0, -0.70, 5.34) * mtx_rotx(pi/2));

    S.gate.frame.V0 = Fr.V;
    S.gate.frame.h  = mesh_patch(ax, struct('V', mtx_apply(mtx_translate(0,10,0), Fr.V), ...
        'F', Fr.F, 'C', Fr.C), 'flat', 0.24);

    % Glowing Molten Rune Core
    [V, F] = prim_cylinder(0.38, 0.10, 24);
    V = mtx_apply(mtx_translate(0, -0.76, 5.34) * mtx_rotx(pi/2), V);
    S.rune = patch('Parent', ax, 'Vertices', mtx_apply(mtx_translate(0,10,0), V), 'Faces', F, ...
        'FaceColor', [1.0 0.36 0.06], 'EdgeColor', [1.0 0.88 0.32], 'LineWidth', 1.2, ...
        'FaceLighting', 'none', 'Clipping', 'off');

    % Ornate Forged-Iron & Magma-Inlaid Double Gate Doors
    for side = {'L', 'R'}
        sd = 1; if side{1} == 'L', sd = -1; end
        Lf = empty_mesh();
        for i = 0:4
            sh = 0.82 + 0.24 * mod(i * 7, 3) / 2;
            Lf = add_box(Lf, [sd * (0.25 + 0.5 * i) 0 2.45], [0.48 0.32 4.80], iron * sh);
        end
        % Recessed obsidian door panels with glowing magma borders
        Lf = add_box(Lf, [sd*1.25 -0.17 3.62], [1.96 0.08 1.62], magma * 0.90);
        Lf = add_box(Lf, [sd*1.25 -0.19 3.62], [1.80 0.08 1.46], obsidian);
        Lf = add_box(Lf, [sd*1.25 -0.17 1.32], [1.96 0.08 1.52], magma * 0.90);
        Lf = add_box(Lf, [sd*1.25 -0.19 1.32], [1.80 0.08 1.36], obsidian);

        % Forged vertical bronze center trim
        Lf = add_box(Lf, [sd*0.08 -0.22 2.45], [0.12 0.10 4.72], bronze);

        % Triple hammered iron bands with golden studs
        for zb = [0.95 2.45 3.95]
            Lf = add_box(Lf, [sd*1.25 -0.23 zb], [2.46 0.12 0.24], [0.07 0.06 0.08]);
            for xr = [0.35 0.95 1.55 2.15]
                [V, F] = prim_sphere(0.068, 8);
                Lf = mesh_add(Lf, V, F, gold, mtx_translate(sd*xr, -0.31, zb));
            end
        end
        % Ornate central lock escutcheon
        Lf = add_box(Lf, [sd*0.38 -0.25 2.45], [0.60 0.12 0.50], bronze);
        S.gate.(['leaf' side{1}]).V0 = Lf.V;
        S.gate.(['leaf' side{1}]).h  = mesh_patch(ax, Lf, 'gouraud', 0.34);

        % Heavy gold-and-steel sliding bolt
        Bt = empty_mesh();
        [V, F] = prim_cylinder(0.095, 0.90, 14);
        Bt = mesh_add(Bt, V, F, [0.58 0.54 0.52], mtx_translate(sd*0.38, -0.35, 2.45) * mtx_roty(pi/2));
        [V, F] = prim_sphere(0.18, 12);
        Bt = mesh_add(Bt, V, F, gold, mtx_translate(0, -0.36, 2.45));
        S.gate.(['bolt' side{1}]).V0 = Bt.V;
        S.gate.(['bolt' side{1}]).h  = mesh_patch(ax, Bt, 'gouraud', 0.85);
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
    [V, F] = prim_crystal(0.45, 0.45, 0.84);
    S.crystal.V0 = V;
    S.crystal.h  = patch('Parent', ax, 'Vertices', V, 'Faces', F, 'FaceColor', [1.0 0.42 0.08], ...
        'EdgeColor', [1.0 0.90 0.38], 'LineWidth', 1.0, 'FaceLighting', 'none', 'FaceAlpha', 0.95, 'Clipping', 'off');

    %% 11. Explorer Character (Amani)
    S = build_explorer(ax, S);

    %% 12. Rising Volcanic Embers & Brazier Halos
    ne = 90;
    S.ember.x0 = -5 + 10 * mod(sin((1:ne) * 12.9898) * 43758.5453, 1);
    S.ember.y0 = -8 + 30 * mod(sin((1:ne) * 78.233)  * 43758.5453, 1);
    S.ember.z0 =  7      * mod(sin((1:ne) * 37.719)  * 43758.5453, 1);
    S.ember.ph = 6.28    * mod(sin((1:ne) * 4.1414)  * 43758.5453, 1);
    S.ember.h  = plot3(ax, S.ember.x0, S.ember.y0, S.ember.z0, '.', 'Color', [1.0 0.65 0.16], 'MarkerSize', 7.5);

    [V, F] = prim_sphere(0.62, 12);
    nv = size(V, 1); nF = size(F, 1);
    Vh = zeros(nf * nv, 3); Fh = zeros(nf * nF, 4);
    for k = 1:nf
        Vh((k-1)*nv + (1:nv), :) = V;
        Fh((k-1)*nF + (1:nF), :) = F + (k-1) * nv;
    end
    S.halo.V0 = V; S.halo.nv = nv;
    S.halo.h  = patch('Parent', ax, 'Vertices', Vh, 'Faces', Fh, 'FaceColor', [1.0 0.34 0.05], ...
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