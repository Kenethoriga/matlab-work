function S = build_chamber3(ax, lite)
% BUILD_CHAMBER3  Chamber III: The Void — cosmic starfield, floating obsidian
%                 monoliths, Astral Gate, and a 3-ring spinning singularity.

    if nargin < 2, lite = false; end
    S.lite = lite;
    S.ceil  = gobjects(0);
    S.wallL = gobjects(0);
    S.wallR = gobjects(0);

    cla(ax);
    hold(ax, 'on');
    set(ax, 'Color', [0.012 0.010 0.028], 'Projection', 'perspective', ...
        'DataAspectRatio', [1 1 1], 'Visible', 'off', 'Clipping', 'off');

    % Void palette
    obsid   = [0.09 0.08 0.14];
    obsidL  = [0.16 0.14 0.24];
    gold    = [0.95 0.78 0.34];
    cyan    = [0.30 0.92 1.00];
    violet  = [0.68 0.30 1.00];
    glass   = [0.14 0.10 0.26];

    %% 1. 3D Cosmic Starfield
    ns = 260;
    if lite, ns = 120; end
    u1 = mod(sin((1:ns) * 12.9898) * 43758.5453, 1);
    u2 = mod(sin((1:ns) * 78.2330) * 43758.5453, 1);
    u3 = mod(sin((1:ns) * 37.7190) * 43758.5453, 1);
    sx = (u1 - 0.5) * 60;
    sy = -10 + u2 * 55;
    sz = -4 + u3 * 28;
    plot3(ax, sx(1:3:end), sy(1:3:end), sz(1:3:end), '.', 'Color', [0.95 0.96 1.00], 'MarkerSize', 5);
    plot3(ax, sx(2:3:end), sy(2:3:end), sz(2:3:end), '.', 'Color', cyan,             'MarkerSize', 6);
    plot3(ax, sx(3:3:end), sy(3:3:end), sz(3:3:end), '.', 'Color', violet,           'MarkerSize', 5);

    %% 2. Floating Obsidian & Gold Stepping-Stone Walkway
    Walk = empty_mesh();
    for y = -4:2.2:14.5
        % Main floating slab
        Walk = add_box(Walk, [0, y, -0.22], [5.4, 1.92, 0.44], obsid);
        % Glowing cyan/gold inlay strip
        Walk = add_box(Walk, [0, y,  0.005], [4.9, 0.14, 0.02], cyan * 0.75);
        Walk = add_box(Walk, [-2.55, y, -0.02], [0.18, 1.92, 0.12], gold * 0.85);
        Walk = add_box(Walk, [ 2.55, y, -0.02], [0.18, 1.92, 0.12], gold * 0.85);
    end
    S.floor = mesh_patch(ax, Walk, 'flat', 0.25);

    %% 3. Drifting Zero-Gravity Monolith Ruins (animated in update_scene)
    ruinPos = [-7.5  2.0  1.5;   7.5  3.5  2.2;
               -9.0  8.5  3.8;   9.0  7.5  3.0;
               -6.8 14.0  4.5;   6.8 15.0  4.0];
    S.void.ruins = struct('h', {}, 'V0', {}, 'pos', {}, 'ph', {});
    for k = 1:size(ruinPos, 1)
        R = empty_mesh();
        R = add_box(R, [0 0 0],    [1.3 1.3 4.2], obsidL);
        R = add_box(R, [0 0 2.15], [1.45 1.45 0.18], gold * 0.9);
        R = add_box(R, [0 0 0],    [1.36 0.18 3.2], violet * 0.85);
        S.void.ruins(k).V0  = R.V;
        S.void.ruins(k).pos = ruinPos(k, :);
        S.void.ruins(k).ph  = k * 1.1;
        S.void.ruins(k).h   = mesh_patch(ax, R, 'flat', 0.22);
    end

    %% 4. The Spinning Singularity (Centerpiece behind the Astral Gate)
    S.void.origin = [0, 22.0, 7.2];

    % Pitch-black Event Horizon Sphere
    [Vs, Fs] = prim_sphere(2.3, 20);
    S.void.core = patch('Parent', ax, 'Vertices', mtx_apply(mtx_translate(0, 22.0, 7.2), Vs), ...
        'Faces', Fs, 'FaceColor', [0.01 0.005 0.02], 'EdgeColor', 'none', ...
        'FaceLighting', 'none', 'Clipping', 'off');

    % 3 Concentric Counter-Rotating Accretion Rings (Gold, Cyan, Violet)
    ringCols = {gold, cyan, violet};
    ringRads = [3.4, 4.5, 5.7];
    S.void.rings = struct('h', {}, 'V0', {});
    for k = 1:3
        r0 = ringRads(k);
        [Vr, Fr] = prim_revolve([r0-0.16 -0.06; r0+0.16 -0.06; r0+0.16 0.06; r0-0.16 0.06; r0-0.16 -0.06], 28);
        S.void.rings(k).V0 = Vr;
        S.void.rings(k).h  = patch('Parent', ax, 'Vertices', Vr, 'Faces', Fr, ...
            'FaceColor', ringCols{k}, 'EdgeColor', 'none', ...
            'FaceLighting', 'none', 'FaceAlpha', 0.88, 'Clipping', 'off');
    end
    S.void.light = light('Parent', ax, 'Position', [0 20.0 9.5], ...
        'Style', 'local', 'Color', [0.55 0.35 1.00]);

    %% 5. The Astral Gate (3-Level Hierarchy: Frame -> Leaf -> Bolt)
    Gf = empty_mesh();
    for sd = [-1 1]
        Gf = add_box(Gf, [sd*2.95 0 3.0], [0.95 1.1 6.0], obsidL);
        Gf = add_box(Gf, [sd*2.95 0 6.1], [1.15 1.3 0.35], gold);
        Gf = add_box(Gf, [sd*2.48 0 3.0], [0.12 1.16 5.6], cyan * 0.85);
    end
    Gf = add_box(Gf, [0 0 6.25], [7.2 1.3 0.75], obsidL);
    Gf = add_box(Gf, [0 0 6.72], [7.5 1.4 0.22], gold);
    S.gate.frame.V0 = Gf.V;
    S.gate.frame.h  = mesh_patch(ax, Gf, 'flat', 0.30);

    for side = {'L', 'R'}
        sd = 1; if side{1} == 'L', sd = -1; end
        Gl = empty_mesh();
        Gl = add_box(Gl, [sd*1.24 0 2.95], [2.44 0.30 5.85], glass);
        Gl = add_box(Gl, [sd*1.24 0 2.95], [2.10 0.36 0.14], gold * 0.9);
        Gl = add_box(Gl, [sd*1.24 0 4.50], [2.10 0.36 0.12], violet);
        Gl = add_box(Gl, [sd*1.24 0 1.40], [2.10 0.36 0.12], cyan);
        S.gate.(['leaf' side{1}]).V0 = Gl.V;
        S.gate.(['leaf' side{1}]).h  = mesh_patch(ax, Gl, 'flat', 0.35);

        Gb = empty_mesh();
        Gb = add_box(Gb, [sd*0.55 -0.22 2.95], [1.05 0.18 0.28], gold);
        S.gate.(['bolt' side{1}]).V0 = Gb.V;
        S.gate.(['bolt' side{1}]).h  = mesh_patch(ax, Gb, 'flat', 0.45);
    end

    % Gate Seal Rune & Unlock Light
    [Vr, Fr] = prim_cylinder(0.55, 0.18, 16);
    S.rune = patch('Parent', ax, 'Vertices', mtx_apply(mtx_translate(0, 9.75, 5.95) * mtx_rotx(pi/2), Vr), ...
        'Faces', Fr, 'FaceColor', violet, 'EdgeColor', cyan, 'FaceLighting', 'none', 'Clipping', 'off');
    S.gateLight = light('Parent', ax, 'Position', [0 9.0 3.2], 'Style', 'local', 'Color', [0 0 0]);

    % Portal Disc behind Gate (leads to Hidden Vault / Victory)
    [Vp, Fp] = prim_cylinder(2.1, 0.08, 24);
    S.portal = patch('Parent', ax, 'Vertices', mtx_apply(mtx_translate(0, 14.6, 2.8) * mtx_rotx(pi/2), Vp), ...
        'Faces', Fp, 'FaceColor', cyan, 'EdgeColor', 'none', ...
        'FaceAlpha', 0.85, 'FaceLighting', 'none', 'Clipping', 'off');

    %% 6. Floating Arcane Sign Crystal & Pedestal
    Ped = empty_mesh();
    [Vc, Fc] = prim_cylinder(0.62, 0.28, 16);
    Ped = mesh_add(Ped, Vc, Fc, obsidL, mtx_translate(-2.6, 6.5, 0.14));
    [Vc, Fc] = prim_cylinder(0.48, 0.08, 16);
    Ped = mesh_add(Ped, Vc, Fc, gold, mtx_translate(-2.6, 6.5, 0.30));
    mesh_patch(ax, Ped, 'flat', 0.25);

    [Vc, Fc] = prim_revolve([0 -0.75; 0.42 0; 0 0.75], 6);
    S.crystal.V0 = Vc;
    S.crystal.h  = patch('Parent', ax, 'Vertices', Vc, 'Faces', Fc, ...
        'FaceColor', cyan, 'EdgeColor', [0.85 0.98 1.0], 'FaceAlpha', 0.90, ...
        'FaceLighting', 'none', 'Clipping', 'off');

    %% 7. Floating Crystal Torches (compatible with update_scene.m)
    S.TP = [-3.3 -1.0 2.6;  3.3 -1.0 2.6;
            -3.3  4.5 2.6;  3.3  4.5 2.6;
            -3.3  8.8 2.6;  3.3  8.8 2.6];
    nf = size(S.TP, 1);

    [Vf0, Ff0] = prim_revolve([0 -0.35; 0.24 0; 0 0.48], 6);
    S.flame.V0 = Vf0; S.flame.n = nf; S.flame.nv = size(Vf0, 1);
    Ff = zeros(nf * size(Ff0, 1), size(Ff0, 2));
    for k = 1:nf
        Ff((k-1)*size(Ff0,1) + (1:size(Ff0,1)), :) = Ff0 + (k-1)*S.flame.nv;
    end
    S.flame.h = patch('Parent', ax, 'Vertices', zeros(nf * S.flame.nv, 3), 'Faces', Ff, ...
        'FaceColor', violet, 'EdgeColor', cyan, 'FaceLighting', 'none', 'Clipping', 'off');

    if ~lite
        [Vh0, Fh0] = prim_sphere(0.65, 10);
        S.halo.V0 = Vh0; S.halo.nv = size(Vh0, 1);
        Fh = zeros(nf * size(Fh0, 1), size(Fh0, 2));
        for k = 1:nf
            Fh((k-1)*size(Fh0,1) + (1:size(Fh0,1)), :) = Fh0 + (k-1)*S.halo.nv;
        end
        S.halo.h = patch('Parent', ax, 'Vertices', zeros(nf * S.halo.nv, 3), 'Faces', Fh, ...
            'FaceColor', cyan, 'EdgeColor', 'none', 'FaceAlpha', 0.14, ...
            'FaceLighting', 'none', 'Clipping', 'off');

        ne = 40;
        S.ember.x0 = (rand(1, ne) - 0.5) * 9.0;
        S.ember.y0 = -2 + rand(1, ne) * 14.0;
        S.ember.z0 = rand(1, ne) * 6.0;
        S.ember.ph = rand(1, ne) * 2 * pi;
        S.ember.h  = plot3(ax, S.ember.x0, S.ember.y0, S.ember.z0, '.', ...
            'Color', [0.70 0.90 1.00], 'MarkerSize', 7);
    end

    %% 8. Cool Cosmic Lighting & Explorer
    light('Parent', ax, 'Position', [0 -6 10], 'Style', 'infinite', 'Color', [0.42 0.48 0.72]);
    S.torchLights = gobjects(1, 2);
    S.torchLights(1) = light('Parent', ax, 'Position', [-3.3 4.5 3.0], 'Style', 'local', 'Color', [0.45 0.75 1.00]);
    S.torchLights(2) = light('Parent', ax, 'Position', [ 3.3 4.5 3.0], 'Style', 'local', 'Color', [0.75 0.40 1.00]);

    S = build_explorer(ax, S);
end

function M = empty_mesh()
    M = struct('V', [], 'F', [], 'C', []);
end

function M = add_box(M, c, sz, col)
    [V, F] = prim_box(sz(1), sz(2), sz(3));
    M = mesh_add(M, V, F, col, mtx_translate(c(1), c(2), c(3)));
end