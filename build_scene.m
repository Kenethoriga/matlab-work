function S = build_scene(ax, lite)
% BUILD_SCENE  Chamber I: Grand Ancient Temple Corridor with carved columns,
%              gold wall moldings, raised carpet curbs, monumental tiered gate,
%              pedestal crystal, and upgraded explorer (build_explorer).

    if nargin < 2, lite = false; end
    S.lite = lite;

    set(ax, 'XLim', [-5.5 5.5], 'YLim', [-10 23], 'ZLim', [0 7], ...
        'DataAspectRatio', [1 1 1], 'Projection', 'perspective', ...
        'Visible', 'off', 'SortMethod', 'depth', 'Clipping', 'off');
    hold(ax, 'on');

    TP = [-4.0  1 3.35;  4.0  1 3.35;
          -4.0  6 3.35;  4.0  6 3.35;
          -4.0 14 3.35;  4.0 14 3.35];
    S.TP = TP;

    % Grand Temple Palette
    rock   = [0.54 0.41 0.30];
    stone  = [0.48 0.43 0.36];
    stoneD = [0.32 0.28 0.24];
    gold   = [0.90 0.72 0.30];
    bronze = [0.54 0.39 0.18];

    %% 1. Sculpted Rock Walls & Vaulted Ceiling
    nw = 100 - 40 * lite;
    nz = 30  - 10 * lite;
    [Y, Z] = meshgrid(linspace(-10, 23, nw), linspace(0, 6.6, nz));
    for sd = [-1 1]
        X = sd * (4.75 + 0.32 * rock_noise(Y * 0.55, Z * 0.55, 5 + sd));
        detail = 0.84 + 0.16 * rock_noise(Y * 1.3, Z * 1.3, 21);
        C = bake_color([X(:) Y(:) Z(:)], rock, TP, 0.05);
        C = reshape(min(1, C .* detail(:)), [size(X) 3]);
        h = surf(ax, X, Y, Z, C, 'FaceColor', 'interp', 'EdgeColor', 'none', 'FaceLighting', 'none');
        if sd < 0, S.wallL = h; else, S.wallR = h; end
    end

    [X, Y] = meshgrid(linspace(-5, 5, nz), linspace(-10, 23, nw));
    Z = 6.45 + 0.28 * rock_noise(X * 0.6, Y * 0.6, 9);
    C = bake_color([X(:) Y(:) Z(:)], rock * 0.76, TP, 0.04);
    S.ceil = surf(ax, X, Y, Z, reshape(C, [size(X) 3]), ...
        'FaceColor', 'interp', 'EdgeColor', 'none', 'FaceLighting', 'none');

    %% 2. Stone Floor, Royal Crimson Carpet & Woven Gold Medallions
    tile = 0.5 + 0.5 * lite;
    [X, Y] = meshgrid(-5:tile:5, -10:tile:23);
    Z = zeros(size(X));
    shade = 0.80 + 0.26 * mod(sin(X * 12.9898 + Y * 78.233) * 43758.5453, 1);

    xc = X(:) + tile / 2;
    yc = Y(:) + tile / 2;
    base = repmat([0.45 0.38 0.30], numel(X), 1);

    carpet = abs(xc) < 1.02;
    trim   = abs(xc) >= 1.02 & abs(xc) < 1.34;
    medall = abs(xc) < 0.35 & abs(mod(yc + 1.5, 4.0) - 2.0) < 0.35;
    base(carpet, :) = repmat([0.56 0.08 0.11], nnz(carpet), 1);
    base(trim,   :) = repmat([0.86 0.68 0.26], nnz(trim),   1);
    base(medall, :) = repmat([0.92 0.74 0.30], nnz(medall), 1);

    Cl = bake_color([xc, yc, zeros(numel(X), 1)], [1 1 1], TP, 0.05);
    C  = min(1, base .* Cl .* shade(:));
    S.floor = surf(ax, X, Y, Z, reshape(C, [size(X) 3]), 'FaceColor', 'flat', ...
        'EdgeColor', [0.06 0.05 0.04], 'LineWidth', 0.3, 'FaceLighting', 'none');

    %% 3. Sacred Portal Sanctuary & Closed End-Wall (eliminates hollow void)
    EndM = empty_mesh();
    % Solid carved stone back wall closing off the corridor at y = 21.8
    EndM = add_box(EndM, [0 21.8 3.3], [11.0 0.8 6.8], stoneD * 0.85);
    EndM = add_box(EndM, [0 21.3 0.45], [10.4 0.5 0.90], stoneD);
    EndM = add_box(EndM, [0 21.3 5.65], [10.4 0.5 0.70], stoneD);
    EndM = add_box(EndM, [0 21.2 1.45], [10.0 0.2 0.12], bronze);
    EndM = add_box(EndM, [0 21.2 4.85], [10.0 0.2 0.12], gold * 0.85);

    % Stepped stone-and-gold dais leading up to the portal
    EndM = add_box(EndM, [0 18.8 0.12], [5.8 4.4 0.24], stoneD);
    EndM = add_box(EndM, [0 19.3 0.30], [4.4 3.2 0.16], stone * 0.92);
    EndM = add_box(EndM, [0 19.3 0.39], [4.5 3.3 0.04], gold * 0.88);

    % Monumental Portal Archway Pillars & Crown framing the vortex
    for sd = [-1 1]
        EndM = add_box(EndM, [sd*2.15 19.2 2.25], [0.68 0.75 3.90], stone * 0.90);
        EndM = add_box(EndM, [sd*2.15 18.8 2.25], [0.14 0.12 3.60], gold * 0.90);
        % Flanking sanctuary pedestals with glowing golden orbs
        EndM = add_box(EndM, [sd*3.25 16.4 0.55], [0.78 0.78 1.10], stoneD);
        EndM = add_box(EndM, [sd*3.25 16.4 1.16], [0.88 0.88 0.14], gold * 0.85);
        [Vo, Fo] = prim_sphere(0.24, 12);
        EndM = mesh_add(EndM, Vo, Fo, [1.0 0.78 0.25], mtx_translate(sd*3.25, 16.4, 1.48));
    end
    EndM = add_box(EndM, [0 19.2 4.35], [5.4 0.85 0.58], stone * 0.95);
    EndM = add_box(EndM, [0 18.8 4.05], [5.0 0.16 0.12], gold);
    % Outer golden portal ring
    [Vr, Fr] = prim_cylinder(1.55, 0.22, 24);
    EndM = mesh_add(EndM, Vr, Fr, gold * 0.92, mtx_translate(0, 19.35, 2.25) * mtx_rotx(pi/2));
    S.sanctuary = mesh_patch(ax, EndM, 'gouraud', 0.22);

    % Radiant multi-layer glowing portal core
    [V, F] = prim_cylinder(1.32, 0.12, 24);
    V = mtx_apply(mtx_translate(0, 19.22, 2.25) * mtx_rotx(pi/2), V);
    S.portal = patch('Parent', ax, 'Vertices', V, 'Faces', F, ...
        'FaceColor', [1.0 0.86 0.38], 'EdgeColor', [1.0 0.96 0.75], 'LineWidth', 1.2, ...
        'FaceLighting', 'none', 'Clipping', 'off');

    %% 4. Ornate Columns, Wall Moldings, Carpet Curbs & Torch Sconces
    St = empty_mesh();

    % Raised stone curbs & gold wall dado rails running along the corridor
    for sd = [-1 1]
        St = add_box(St, [sd*1.48 5.0 0.05], [0.22 28.0 0.10], stoneD);
        St = add_box(St, [sd*4.52 5.0 1.45], [0.16 28.0 0.12], bronze);
        St = add_box(St, [sd*4.52 5.0 4.85], [0.16 28.0 0.12], gold * 0.85);
    end

    % Ornate temple columns & overhead coffered beams
    for yb = [-3 3 17]
        St = add_box(St, [0 yb 6.02], [10.0 0.76 0.70], stone);
        St = add_box(St, [0 yb 5.62], [9.6  0.82 0.10], gold * 0.85);
        for sd = [-1 1]
            px = sd * 4.38;
            St = add_box(St, [px yb 0.14], [1.24 1.24 0.28], stoneD);
            St = add_box(St, [px yb 0.36], [1.02 1.02 0.18], stone * 0.92);
            [V, F] = prim_cylinder(0.41, 4.70, 14);
            St = mesh_add(St, V, F, stone * 0.98, mtx_translate(px, yb, 2.80));
            for zr = [0.58, 2.80, 5.02]
                [V, F] = prim_cylinder(0.45, 0.10, 14);
                St = mesh_add(St, V, F, gold * 0.90, mtx_translate(px, yb, zr));
            end
            St = add_box(St, [px yb 5.26], [1.02 1.02 0.22], stone * 0.90);
            St = add_box(St, [px yb 5.48], [1.24 1.24 0.24], stoneD * 1.12);
        end
    end

    % Pedestal ring under the floating cyan crystal (at x=-2.6, y=6.5)
    [V, F] = prim_cylinder(0.55, 0.14, 16);
    St = mesh_add(St, V, F, stoneD, mtx_translate(-2.6, 6.5, 0.07));
    [V, F] = prim_cylinder(0.42, 0.22, 16);
    St = mesh_add(St, V, F, gold * 0.85, mtx_translate(-2.6, 6.5, 0.22));

    % Bronze torch sconces
    for k = 1:size(TP, 1)
        sx = sign(TP(k, 1));
        St = add_box(St, [sx*4.35 TP(k,2) 2.35], [0.52 0.12 0.12], [0.16 0.14 0.13]);
        [V, F] = prim_cylinder(0.07, 1.0, 10);
        St = mesh_add(St, V, F, [0.30 0.20 0.11], mtx_translate(TP(k,1), TP(k,2), 2.75));
        [V, F] = prim_revolve([0 -0.12; 0.07 -0.12; 0.16 0.10; 0.18 0.17; 0.10 0.12; 0 0.12], 14);
        St = mesh_add(St, V, F, bronze, mtx_translate(TP(k,1), TP(k,2), 3.2));
    end
    S.statics = mesh_patch(ax, St, 'gouraud', 0.22);

    %% 5. Torch Flames
    [Vo, Fo] = prim_revolve([0 -0.10; 0.09 -0.07; 0.14 0.02; 0.12 0.14; 0.06 0.26; 0 0.42], 12);
    [Vi, Fi] = prim_revolve([0 -0.06; 0.05 -0.02; 0.07 0.06; 0.04 0.16; 0 0.28], 10);
    Vflame = [Vo; Vi];
    Fflame = [Fo; Fi + size(Vo, 1)];
    t = (Vflame(:, 3) - min(Vflame(:, 3))) / (max(Vflame(:, 3)) - min(Vflame(:, 3)));
    Cflame = [1 0.28 0.04] .* (1 - t) + [1 0.94 0.48] .* t;
    Cflame(size(Vo, 1) + 1:end, :) = min(1, Cflame(size(Vo, 1) + 1:end, :) * 0.4 + 0.6);

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

    %% 6. Dynamic Lights
    % Neutral-cool key light so Amani's teal tunic & silhouette pop cleanly
    light('Parent', ax, 'Position', [0 -6 10], 'Style', 'infinite', 'Color', [0.38 0.42 0.52]);

    S.torchLights = gobjects(1, 4);
    for k = 1:4
        S.torchLights(k) = light('Parent', ax, 'Position', TP(k, :) + [0 0 0.3], ...
            'Style', 'local', 'Color', [1.0 0.64 0.32]);
    end
    S.gateLight    = light('Parent', ax, 'Position', [0 13.5 2.6], 'Style', 'local', 'Color', [0 0 0]);
    S.crystalLight = light('Parent', ax, 'Position', [-2.6 6.5 2.0], 'Style', 'local', 'Color', [0.24 0.62 0.78]);

    %% 7. Monumental Tiered Temple Gate (3-Level Hierarchy)
    Fr = empty_mesh();
    for sd = [-1 1]
        Fr = add_box(Fr, [sd*2.96 -0.05 0.18], [1.24 1.28 0.36], stoneD);
        Fr = add_box(Fr, [sd*2.96 -0.05 0.42], [1.08 1.12 0.12], gold * 0.85);
        for i = 0:5
            jit = 0.86 + 0.18 * mod(i * 5 + (sd > 0) * 3, 4) / 3;
            Fr = add_box(Fr, [sd*2.96 0 0.68 + 0.78 * i], [0.92 1.08 0.74], stone * jit);
        end
        Fr = add_box(Fr, [sd*2.48 -0.52 2.65], [0.10 0.10 4.85], gold * 0.90);
        % Twin golden finials crowning the gateposts
        Fr = add_box(Fr, [sd*3.28 -0.05 6.12], [0.60 0.65 0.40], stoneD);
        Fr = add_box(Fr, [sd*3.28 -0.05 6.40], [0.34 0.38 0.24], gold * 0.92);
    end
    % Tiered Temple Pediment & Cornice
    Fr = add_box(Fr, [0 0 5.32],     [7.2 1.16 0.90], stone * 0.92);
    Fr = add_box(Fr, [0 -0.06 5.84], [7.8 1.30 0.24], stoneD * 1.12);
    Fr = add_box(Fr, [0 -0.08 6.12], [5.8 1.14 0.28], stone * 0.85);
    Fr = add_box(Fr, [0 -0.60 4.92], [7.0 0.12 0.12], gold * 0.92);
    Fr = add_box(Fr, [0 -0.20 5.36], [1.40 1.22 1.14], stone * 1.06);
    Fr = add_box(Fr, [0 -0.22 6.08], [1.60 1.28 0.32], gold * 0.88);
    Fr = add_box(Fr, [0 -0.52 0.05], [6.2 0.56 0.10], stoneD);

    % Multi-ringed Gold & Stone Rune Bezel
    [V, F] = prim_cylinder(0.58, 0.12, 24);
    Fr = mesh_add(Fr, V, F, stoneD, mtx_translate(0, -0.66, 5.34) * mtx_rotx(pi/2));
    [V, F] = prim_cylinder(0.50, 0.14, 24);
    Fr = mesh_add(Fr, V, F, gold, mtx_translate(0, -0.70, 5.34) * mtx_rotx(pi/2));

    S.gate.frame.V0 = Fr.V;
    S.gate.frame.h  = mesh_patch(ax, struct('V', mtx_apply(mtx_translate(0,10,0), Fr.V), ...
        'F', Fr.F, 'C', Fr.C), 'flat', 0.18);

    % Glowing Crimson Rune Core
    [V, F] = prim_cylinder(0.37, 0.10, 24);
    V = mtx_apply(mtx_translate(0, -0.76, 5.34) * mtx_rotx(pi/2), V);
    S.rune = patch('Parent', ax, 'Vertices', mtx_apply(mtx_translate(0,10,0), V), 'Faces', F, ...
        'FaceColor', [0.92 0.18 0.12], 'EdgeColor', [1.0 0.72 0.32], 'LineWidth', 1.1, ...
        'FaceLighting', 'none', 'Clipping', 'off');

    % Carved Ancient Timber & Bronze-Studded Doors
    wood = [0.38 0.22 0.11]; iron = [0.14 0.13 0.15];
    for side = {'L', 'R'}
        sd = 1; if side{1} == 'L', sd = -1; end
        Lf = empty_mesh();
        for i = 0:4
            sh = 0.80 + 0.28 * mod(i * 7, 3) / 2;
            Lf = add_box(Lf, [sd * (0.25 + 0.5 * i) 0 2.45], [0.48 0.30 4.80], wood * sh);
        end
        % Gold-framed recessed door panels
        Lf = add_box(Lf, [sd*1.25 -0.17 3.62], [1.96 0.08 1.62], bronze);
        Lf = add_box(Lf, [sd*1.25 -0.19 3.62], [1.80 0.08 1.46], wood * 0.70);
        Lf = add_box(Lf, [sd*1.25 -0.17 1.32], [1.96 0.08 1.52], bronze);
        Lf = add_box(Lf, [sd*1.25 -0.19 1.32], [1.80 0.08 1.36], wood * 0.70);
        Lf = add_box(Lf, [sd*0.08 -0.21 2.45], [0.12 0.10 4.72], bronze);

        for zb = [0.95 2.45 3.95]
            Lf = add_box(Lf, [sd*1.25 -0.22 zb], [2.46 0.12 0.22], iron);
            for xr = [0.35 0.95 1.55 2.15]
                [V, F] = prim_sphere(0.068, 8);
                Lf = mesh_add(Lf, V, F, gold, mtx_translate(sd*xr, -0.30, zb));
            end
        end
        Lf = add_box(Lf, [sd*0.38 -0.24 2.45], [0.58 0.12 0.46], bronze);
        S.gate.(['leaf' side{1}]).V0 = Lf.V;
        S.gate.(['leaf' side{1}]).h  = mesh_patch(ax, Lf, 'gouraud', 0.24);

        Bt = empty_mesh();
        [V, F] = prim_cylinder(0.095, 0.90, 14);
        Bt = mesh_add(Bt, V, F, [0.68 0.65 0.60], mtx_translate(sd*0.38, -0.34, 2.45) * mtx_roty(pi/2));
        [V, F] = prim_sphere(0.18, 12);
        Bt = mesh_add(Bt, V, F, gold, mtx_translate(0, -0.35, 2.45));
        S.gate.(['bolt' side{1}]).V0 = Bt.V;
        S.gate.(['bolt' side{1}]).h  = mesh_patch(ax, Bt, 'gouraud', 0.82);
    end

    %% 8. Hidden Right-Side Board (keeps update_scene/run_project compatible)
    [Vb, Fb] = prim_box(2.58, 0.12, 1.88);
    S.panelBorder = patch('Parent', ax, 'Vertices', Vb, 'Faces', Fb, 'Visible', 'off');
    S.panel       = patch('Parent', ax, 'Vertices', Vb, 'Faces', Fb, 'Visible', 'off');
    S.panelText   = gobjects(1, 4);
    for k = 1:4
        S.panelText(k) = text(ax, 2.55, 4.28, 2.70, '', 'Visible', 'off');
    end

    %% 9. Floating Cyan Rune Crystal
    [V, F] = prim_crystal(0.44, 0.44, 0.82);
    S.crystal.V0 = V;
    S.crystal.h  = patch('Parent', ax, 'Vertices', V, 'Faces', F, 'FaceColor', [0.35 0.90 1.0], ...
        'EdgeColor', [0.88 1 1], 'LineWidth', 1.0, 'FaceLighting', 'none', 'FaceAlpha', 0.94, 'Clipping', 'off');

    %% 10. Upgraded Hero Explorer Character (Amani)
    S = build_explorer(ax, S);

    %% 11. Drifting Embers & Torch Halos
    ne = 75;
    S.ember.x0 = -4 + 8  * mod(sin((1:ne) * 12.9898) * 43758.5453, 1);
    S.ember.y0 = -8 + 30 * mod(sin((1:ne) * 78.233)  * 43758.5453, 1);
    S.ember.z0 =  6      * mod(sin((1:ne) * 37.719)  * 43758.5453, 1);
    S.ember.ph = 6.28    * mod(sin((1:ne) * 4.1414)  * 43758.5453, 1);
    S.ember.h  = plot3(ax, S.ember.x0, S.ember.y0, S.ember.z0, '.', 'Color', [1 0.80 0.40], 'MarkerSize', 7);

    [V, F] = prim_sphere(0.6, 12);
    nv = size(V, 1); nF = size(F, 1);
    Vh = zeros(nf * nv, 3); Fh = zeros(nf * nF, 4);
    for k = 1:nf
        Vh((k-1)*nv + (1:nv), :) = V;
        Fh((k-1)*nF + (1:nF), :) = F + (k-1) * nv;
    end
    S.halo.V0 = V; S.halo.nv = nv;
    S.halo.h  = patch('Parent', ax, 'Vertices', Vh, 'Faces', Fh, 'FaceColor', [1 0.56 0.16], ...
        'EdgeColor', 'none', 'FaceAlpha', 0.12, 'FaceLighting', 'none', 'Clipping', 'off');

    if lite
        set(S.halo.h,  'Visible', 'off');
        set(S.ember.h, 'Visible', 'off');
    end
end

function M = empty_mesh()
    M = struct('V', [], 'F', [], 'C', []);
end

function M = add_box(M, c, sz, col)
    [V, F] = prim_box(sz(1), sz(2), sz(3));
    M = mesh_add(M, V, F, col, mtx_translate(c(1), c(2), c(3)));
end