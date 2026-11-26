function update_scene(S, G, t)
% UPDATE_SCENE  Animate gate (3-level hierarchy), lifelike explorer + flowing
%               cape, live flickering torch lights, pulsing portal, breathing
%               lava, and Chamber II volcano eruption + smoke plumes.

    %% 1. 3-Level Gate Hierarchy: M_gate * M_leaf * M_bolt
    shake = 0;
    if G.shake_t > 0
        shake = 0.08 * sin(t * 55) * G.shake_t;
    end
    M_gate = mtx_translate(shake, 10, 0);
    set(S.gate.frame.h, 'Vertices', mtx_apply(M_gate, S.gate.frame.V0));

    % Bolt slides back first (0 -> 0.30), then leaves swing open (0.25 -> 1.0)
    boltSlide = min(1, G.open_t / 0.30) * 0.62;
    leafFrac  = max(0, (G.open_t - 0.25) / 0.75);
    leafEase  = leafFrac * leafFrac * (3 - 2 * leafFrac);   % smoothstep
    angle     = leafEase * (pi * 0.48);

    for side = {'L', 'R'}
        sd = 1; if side{1} == 'L', sd = -1; end
        hinge = sd * 2.48;
        M_leaf = mtx_translate(hinge, 0, 0) * mtx_rotz(sd * angle) * mtx_translate(-hinge, 0, 0);
        M_bolt = mtx_translate(sd * boltSlide, 0, 0);

        set(S.gate.(['leaf' side{1}]).h, 'Vertices', ...
            mtx_apply(M_gate * M_leaf, S.gate.(['leaf' side{1}]).V0));
        set(S.gate.(['bolt' side{1}]).h, 'Vertices', ...
            mtx_apply(M_gate * M_leaf * M_bolt, S.gate.(['bolt' side{1}]).V0));
    end

    % Rune & gate light glow brighter as the seal breaks
    if G.opening
        set(S.rune, 'FaceColor', [0.25 0.95 0.45], 'EdgeColor', [0.80 1.0 0.85]);
        set(S.gateLight, 'Color', [0.35 0.90 0.45] * leafEase);
    else
        pulse = 0.80 + 0.20 * sin(t * 3.5);
        set(S.rune, 'FaceColor', [0.92 0.18 0.12] * pulse);
        set(S.gateLight, 'Color', [0 0 0]);
    end

    %% 2. Lifelike Explorer Movement + Flowing Cape
    ph = G.phase;
    if G.cheer
        bob   = abs(sin(t * 7.5)) * 0.22;
        lean  = -0.05;
        sway  = 0.04 * sin(t * 7.5);
        hipL  = 0; hipR = 0; kneeL = 0; kneeR = 0;
        armL  = 2.65 + 0.18 * sin(t * 10);
        armR  = 2.65 - 0.18 * sin(t * 10);
        elbL  = 0.25; elbR = 0.25;
        splay = 0.30;
        capeAng = -0.30 - 0.12 * sin(t * 9);
    elseif G.moving
        bob   = abs(sin(ph)) * 0.085;
        lean  = 0.10;
        sway  = 0.045 * sin(ph);
        hipL  =  0.52 * sin(ph);
        hipR  = -0.52 * sin(ph);
        kneeL = -max(0, 0.65 * cos(ph));
        kneeR = -max(0, -0.65 * cos(ph));
        armL  = -0.48 * sin(ph);
        armR  =  0.48 * sin(ph);
        elbL  =  0.32 + 0.38 * max(0, -sin(ph));
        elbR  =  0.32 + 0.38 * max(0,  sin(ph));
        splay =  0.14;
        capeAng = -0.26 - 0.10 * sin(ph * 2);   % billows back while running
    else
        bob   = 0.020 * sin(t * 2.6);
        lean  = 0;
        sway  = 0.010 * sin(t * 1.3);
        hipL  = 0; hipR = 0; kneeL = 0; kneeR = 0;
        armL  =  0.04 * sin(t * 2.6);
        armR  = -0.04 * sin(t * 2.6);
        elbL  =  0.18; elbR = 0.18;
        splay =  0.10;
        capeAng = -0.05 - 0.04 * sin(t * 2.8);  % gentle idle ripple
    end

    M_root = mtx_translate(G.px, G.py, bob) * mtx_rotz(G.heading) * ...
             mtx_rotx(lean) * mtx_roty(sway);
    set(S.char.body.h, 'Vertices', mtx_apply(M_root, S.char.body.V0));

    % Flowing cape child transform
    if isfield(S.char, 'cape')
        cp = S.char.capePivot;
        M_cape = M_root * mtx_translate(cp(1), cp(2), cp(3)) * ...
                 mtx_rotx(capeAng) * mtx_translate(-cp(1), -cp(2), -cp(3));
        set(S.char.cape.h, 'Vertices', mtx_apply(M_cape, S.char.cape.V0));
    end

    % Left & Right Legs and Arms
    hip  = S.char.hip;  knee = S.char.knee;
    shld = S.char.shoulder; elbw = S.char.elbow;
    hips  = [hipL, hipR];   knees = [kneeL, kneeR];
    arms  = [armL, armR];   elbs  = [elbL,  elbR];
    sides = {'L', 'R'};

    for k = 1:2
        sd = -1; if k == 2, sd = 1; end
        nm = sides{k};

        % Leg hierarchy (Body -> Thigh -> Shin)
        pH = [sd * hip(1), hip(2), hip(3)];
        pK = [sd * hip(1), knee(2), knee(3)];
        M_thigh = M_root * mtx_translate(pH(1), pH(2), pH(3)) * mtx_rotx(hips(k)) * ...
                  mtx_translate(-pH(1), -pH(2), -pH(3));
        M_shin  = M_thigh * mtx_translate(pK(1), pK(2), pK(3)) * mtx_rotx(knees(k)) * ...
                  mtx_translate(-pK(1), -pK(2), -pK(3));
        set(S.char.(['thigh' nm]).h, 'Vertices', mtx_apply(M_thigh, S.char.(['thigh' nm]).V0));
        set(S.char.(['shin'  nm]).h, 'Vertices', mtx_apply(M_shin,  S.char.(['shin'  nm]).V0));

        % Arm hierarchy (Body -> Upper Arm -> Forearm) with outward shoulder flare
        pS = [sd * shld(1), shld(2), shld(3)];
        pE = [sd * shld(1), elbw(2), elbw(3)];
        M_uarm = M_root * mtx_translate(pS(1), pS(2), pS(3)) * ...
                 mtx_roty(-sd * splay) * mtx_rotx(arms(k)) * ...
                 mtx_translate(-pS(1), -pS(2), -pS(3));
        M_farm = M_uarm * mtx_translate(pE(1), pE(2), pE(3)) * mtx_rotx(elbs(k)) * ...
                 mtx_translate(-pE(1), -pE(2), -pE(3));
        set(S.char.(['uarm' nm]).h, 'Vertices', mtx_apply(M_uarm, S.char.(['uarm' nm]).V0));
        set(S.char.(['farm' nm]).h, 'Vertices', mtx_apply(M_farm, S.char.(['farm' nm]).V0));
    end

    % Ground shadow stays on floor and scales slightly with jump height
    shScale = max(0.75, 1.0 - bob * 0.9);
    set(S.shadow.h, 'Vertices', mtx_apply( ...
        mtx_translate(G.px, G.py, 0.03) * mtx_scale(shScale, shScale, 1), S.shadow.V0));

    %% 3. Floating Crystal & Pulsing Portal Glow
    M_crys = mtx_translate(-2.6, 6.5, 2.0 + 0.22 * sin(t * 2.4)) * mtx_rotz(t * 1.4);
    set(S.crystal.h, 'Vertices', mtx_apply(M_crys, S.crystal.V0));

    if isfield(S, 'portal') && ishandle(S.portal)
        gp = 0.85 + 0.15 * sin(t * 4.2);
        set(S.portal, 'FaceColor', min(1, [1.0 0.86 0.38] * gp));
    end

    %% 4. Live Flickering Torch Lights, Flames & Halos
    nf = S.flame.n; nv = S.flame.nv;
    Vf = zeros(nf * nv, 3);
    for k = 1:nf
        fl = 0.86 + 0.22 * sin(t * 11 + k * 2.1) + 0.08 * sin(t * 19 + k);
        M_fl = mtx_translate(S.TP(k,1), S.TP(k,2), S.TP(k,3)) * mtx_scale(0.95, 0.95, fl);
        Vf((k-1)*nv + (1:nv), :) = mtx_apply(M_fl, S.flame.V0);
        if isfield(S, 'torchLights') && k <= numel(S.torchLights) && ishandle(S.torchLights(k))
            lf = 0.84 + 0.16 * sin(t * 13 + k * 1.9);
            set(S.torchLights(k), 'Color', [1.0 0.54 0.22] * lf);
        end
    end
    set(S.flame.h, 'Vertices', Vf);

    if ~S.lite
        nvh = S.halo.nv;
        Vh  = zeros(nf * nvh, 3);
        for k = 1:nf
            hs = 0.92 + 0.14 * sin(t * 9 + k * 1.7);
            M_h = mtx_translate(S.TP(k,1), S.TP(k,2), S.TP(k,3) + 0.15) * mtx_scale(hs, hs, hs);
            Vh((k-1)*nvh + (1:nvh), :) = mtx_apply(M_h, S.halo.V0);
        end
        set(S.halo.h, 'Vertices', Vh);

        % Drifting embers
        z = mod(S.ember.z0 + t * 0.55, 6.2);
        x = S.ember.x0 + 0.25 * sin(t * 1.4 + S.ember.ph);
        set(S.ember.h, 'XData', x, 'YData', S.ember.y0, 'ZData', z);
    end

    %% 5. Chamber II: Pulsing Lava Sea, Volcano Eruption & Smoke Plumes
    if isfield(S, 'lavaC0') && ~S.lite && mod(G.frame, 3) == 0
        C = S.lavaC0;
        glow = 0.88 + 0.18 * sin(t * 2.4);
        C(:, :, 1) = min(1, C(:, :, 1) .* (1 + (glow - 1) * S.lavaMask));
        C(:, :, 2) = min(1, C(:, :, 2) .* (1 + (glow - 1) * S.lavaMask));
        set(S.floor, 'CData', C);
    end

    if isfield(S, 'erupt')
        E = S.erupt;
        o = E.origin;

        % Periodic eruption surges (and a massive eruption when the gate opens!)
        surge = max(0, sin(t * 0.85)).^3;
        if G.opening, surge = 1.25; end
        inten = 0.28 + 0.95 * surge;

        % Animate the molten lava fountain shooting out of the crater
        wScale = 0.65 + 0.55 * inten + 0.08 * sin(t * 16);
        hScale = 0.25 + 1.15 * inten + 0.12 * sin(t * 21);
        M_jet  = mtx_translate(o(1), o(2), o(3)) * ...
                 mtx_rotz(t * 2.2) * mtx_scale(wScale, wScale, hScale);
        set(E.jetH, 'Vertices', mtx_apply(M_jet, E.jetV0));

        % Animate ballistic lava bombs arching out of the crater under gravity
        g   = 9.8;
        tau = mod(t * (0.95 + 0.45 * surge) + E.ph, 2.6);
        bx  = o(1) + E.vx .* tau;
        by  = o(2) + E.vy .* tau;
        bz  = o(3) + (E.vz * (0.75 + 0.45 * inten)) .* tau - 0.5 * g * (tau.^2);

        % Hide bombs once they fall below the lava sea
        bx(bz < 0.2) = NaN;
        by(bz < 0.2) = NaN;
        bz(bz < 0.2) = NaN;
        set(E.bombs, 'XData', bx, 'YData', by, 'ZData', bz);

        % Flash the volcanic sky light with each eruption surge
        set(E.light, 'Color', min(1, [1.0 0.40 0.08] * (0.45 + 0.90 * surge)));

        % Rising volcanic smoke plumes
        if isfield(E, 'smoke') && ~S.lite
            for k = 1:numel(E.smoke)
                p = mod(t * 0.22 + (k - 1) / numel(E.smoke), 1);
                rad = 1.1 + 2.4 * p;
                sx = o(1) + 0.9 * sin(t * 0.7 + k * 1.5) * p;
                sy = o(2) + 0.6 * cos(t * 0.6 + k) * p;
                sz = o(3) + 1.2 + 8.5 * p;
                M_sm = mtx_translate(sx, sy, sz) * mtx_scale(rad, rad, rad * 0.72);
                set(E.smoke(k), 'Vertices', mtx_apply(M_sm, E.smokeV0), ...
                    'FaceAlpha', 0.28 * (1 - p));
            end
        end
    end
end