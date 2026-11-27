function S = build_explorer(ax, S)
% BUILD_EXPLORER  FPS-optimized hero explorer (Amani) with animated cape,
%                 vest, feathered hat, bracers, and cuffed boots.

    skin    = [0.87 0.65 0.49];
    tunic   = [0.10 0.36 0.50];
    vest    = [0.18 0.14 0.12];
    scarf   = [0.76 0.14 0.15];
    pants   = [0.24 0.19 0.15];
    leather = [0.30 0.17 0.09];
    hatCol  = [0.28 0.17 0.09];
    bootCol = [0.15 0.10 0.07];
    hairCol = [0.09 0.06 0.05];
    gold    = [0.92 0.74 0.30];
    gemCyan = [0.35 0.92 1.00];

    B = empty_mesh();

    %% Torso, Adventurer Vest & Coat Tail
    [V, F] = prim_capsule(0.24, 0.28, 10);
    B = mesh_add(B, V, F, tunic, mtx_translate(0, 0, 1.24) * mtx_scale(1.02, 0.68, 1.0));
    B = add_box(B, [-0.12 0.13 1.24], [0.14 0.10 0.44], vest);
    B = add_box(B, [ 0.12 0.13 1.24], [0.14 0.10 0.44], vest);
    B = add_box(B, [-0.05 0.185 1.24], [0.025 0.02 0.42], gold);
    B = add_box(B, [ 0.05 0.185 1.24], [0.025 0.02 0.42], gold);
    [V, F] = prim_revolve([0 0; 0.25 0; 0.28 -0.18; 0 -0.18], 10);
    B = mesh_add(B, V, F, tunic * 0.92, mtx_translate(0, 0, 0.94) * mtx_scale(1.02, 0.72, 1.0));

    %% Crimson Scarf & Collar Clasp
    [V, F] = prim_cylinder(0.21, 0.11, 10);
    B = mesh_add(B, V, F, scarf, mtx_translate(0, 0, 1.56) * mtx_scale(1.06, 0.86, 1.0));
    B = add_box(B, [0 0.175 1.48], [0.13 0.05 0.22], scarf * 0.90);
    [V, F] = prim_sphere(0.045, 6);
    B = mesh_add(B, V, F, gold, mtx_translate(0, 0.21, 1.54));

    %% Leather Belt, Gold Buckle & Glowing Hip Compass
    [V, F] = prim_cylinder(0.275, 0.12, 10);
    B = mesh_add(B, V, F, leather, mtx_translate(0, 0, 0.94) * mtx_scale(1.02, 0.72, 1.0));
    B = add_box(B, [0 0.20 0.94], [0.14 0.045 0.11], gold);
    B = add_box(B, [0 0.21 0.94], [0.06 0.045 0.05], vest);
    [V, F] = prim_cylinder(0.065, 0.04, 8);
    B = mesh_add(B, V, F, gold, mtx_translate(0.26, 0.04, 0.92) * mtx_roty(pi/2));
    [V, F] = prim_cylinder(0.045, 0.045, 8);
    B = mesh_add(B, V, F, gemCyan, mtx_translate(0.265, 0.04, 0.92) * mtx_roty(pi/2));

    %% Neck, Head, Hair & Face
    [V, F] = prim_cylinder(0.095, 0.14, 8);
    B = mesh_add(B, V, F, skin * 0.94, mtx_translate(0, 0, 1.64));
    [V, F] = prim_sphere(0.235, 10);
    B = mesh_add(B, V, F, skin, mtx_translate(0, 0, 1.85) * mtx_scale(0.96, 1.0, 1.04));

    [V, F] = prim_sphere(0.245, 10);
    B = mesh_add(B, V, F, hairCol, mtx_translate(0, -0.045, 1.90) * mtx_scale(1.0, 0.96, 0.86));
    [V, F] = prim_capsule(0.065, 0.18, 8);
    B = mesh_add(B, V, F, hairCol, mtx_translate(0, -0.24, 1.78) * mtx_rotx(0.35));

    for sd = [-1 1]
        [V, F] = prim_sphere(0.036, 6);
        B = mesh_add(B, V, F, [0.06 0.05 0.04], mtx_translate(sd*0.082, 0.212, 1.88));
        B = add_box(B, [sd*0.082 0.218 1.93], [0.068 0.02 0.016], hairCol);
    end
    [V, F] = prim_sphere(0.028, 6);
    B = mesh_add(B, V, F, skin * 0.90, mtx_translate(0, 0.232, 1.83));

    %% Feathered Explorer Hat
    [V, F] = prim_cylinder(0.36, 0.04, 12);
    B = mesh_add(B, V, F, hatCol, mtx_translate(0, -0.02, 2.08) * mtx_scale(1.0, 1.05, 1.0));
    [V, F] = prim_sphere(0.245, 10);
    B = mesh_add(B, V, F, hatCol, mtx_translate(0, -0.02, 2.10) * mtx_scale(0.98, 1.02, 0.82));
    [V, F] = prim_cylinder(0.256, 0.068, 12);
    B = mesh_add(B, V, F, gold, mtx_translate(0, -0.02, 2.11));
    [V, F] = prim_sphere(0.042, 6);
    B = mesh_add(B, V, F, gemCyan, mtx_translate(0.23, 0.09, 2.115));
    B = add_box(B, [0.24 -0.04 2.25], [0.03 0.09 0.22], scarf);
    B = add_box(B, [0.25 -0.07 2.37], [0.025 0.06 0.12], gold);

    %% Leather Backpack & Bedroll
    B = add_box(B, [0 -0.32 1.24], [0.40 0.18 0.50], leather);
    B = add_box(B, [0 -0.415 1.38], [0.42 0.04 0.16], leather * 0.82);
    B = add_box(B, [-0.11 -0.43 1.32], [0.055 0.03 0.12], gold);
    B = add_box(B, [ 0.11 -0.43 1.32], [0.055 0.03 0.12], gold);
    [V, F] = prim_cylinder(0.085, 0.48, 8);
    B = mesh_add(B, V, F, [0.68 0.60 0.45], mtx_translate(0, -0.32, 1.54) * mtx_roty(pi/2));

    S.char.body     = mkpart(ax, B, 'flat', 0.20);
    S.char.hip      = [0.15 0 0.84];  S.char.knee  = [0 0 0.43];
    S.char.shoulder = [0.30 0 1.50];  S.char.elbow = [0 0 1.20];

    %% Animated Flowing Cape
    Cp = empty_mesh();
    Cp = add_box(Cp, [0 -0.22 1.12], [0.46 0.04 0.82], scarf * 0.88);
    Cp = add_box(Cp, [0 -0.225 0.72], [0.48 0.045 0.05], gold * 0.9);
    S.char.cape      = mkpart(ax, Cp, 'flat', 0.16);
    S.char.capePivot = [0 -0.22 1.52];

    %% Articulated Limbs
    for sd = [-1 1]
        nm = 'R'; if sd < 0, nm = 'L'; end

        T = empty_mesh();
        [V, F] = prim_capsule(0.112, 0.28, 8);
        T = mesh_add(T, V, F, pants, mtx_translate(sd*0.15, 0, 0.63));
        S.char.(['thigh' nm]) = mkpart(ax, T, 'flat', 0.12);

        T = empty_mesh();
        [V, F] = prim_capsule(0.098, 0.24, 8);
        T = mesh_add(T, V, F, bootCol * 1.25, mtx_translate(sd*0.15, 0, 0.25));
        [V, F] = prim_cylinder(0.114, 0.065, 8);
        T = mesh_add(T, V, F, leather, mtx_translate(sd*0.15, 0, 0.37));
        [V, F] = prim_cylinder(0.118, 0.025, 8);
        T = mesh_add(T, V, F, gold, mtx_translate(sd*0.15, 0, 0.34));
        T = add_box(T, [sd*0.15 0.075 0.06], [0.19 0.36 0.12], bootCol);
        T = add_box(T, [sd*0.15 0.22 0.06], [0.15 0.06 0.08], bootCol * 0.85);
        S.char.(['shin' nm]) = mkpart(ax, T, 'flat', 0.20);

        T = empty_mesh();
        [V, F] = prim_sphere(0.135, 8);
        T = mesh_add(T, V, F, vest * 1.2, mtx_translate(sd*0.29, 0, 1.51));
        [V, F] = prim_cylinder(0.132, 0.03, 8);
        T = mesh_add(T, V, F, gold, mtx_translate(sd*0.29, 0, 1.46));
        [V, F] = prim_capsule(0.088, 0.20, 8);
        T = mesh_add(T, V, F, tunic, mtx_translate(sd*0.30, 0, 1.32));
        [V, F] = prim_sphere(0.084, 6);
        T = mesh_add(T, V, F, tunic, mtx_translate(sd*0.30, 0, 1.17));
        S.char.(['uarm' nm]) = mkpart(ax, T, 'flat', 0.18);

        T = empty_mesh();
        [V, F] = prim_capsule(0.074, 0.18, 8);
        T = mesh_add(T, V, F, skin, mtx_translate(sd*0.30, 0, 1.01));
        [V, F] = prim_cylinder(0.086, 0.09, 8);
        T = mesh_add(T, V, F, leather, mtx_translate(sd*0.30, 0, 0.94));
        [V, F] = prim_cylinder(0.090, 0.025, 8);
        T = mesh_add(T, V, F, gold, mtx_translate(sd*0.30, 0, 0.98));
        [V, F] = prim_sphere(0.090, 6);
        T = mesh_add(T, V, F, leather * 0.9, mtx_translate(sd*0.30, 0, 0.84));
        S.char.(['farm' nm]) = mkpart(ax, T, 'flat', 0.22);
    end

    %% Opaque Ground Shadow Disc (Zero Alpha-Sorting Lag)
    [V, F] = prim_revolve([0 0; 0.48 0; 0.48 0.01; 0 0.01], 12);
    S.shadow.V0 = V;
    S.shadow.h  = patch('Parent', ax, 'Vertices', V, 'Faces', F, 'FaceColor', [0.05 0.04 0.04], ...
        'EdgeColor', 'none', 'FaceLighting', 'none', 'Clipping', 'off');
end

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