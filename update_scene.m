function update_scene(S, G, t)
% UPDATE_SCENE  Animate gate (3-level hierarchy), torches, crystal, embers,
%               and lifelike explorer movement (bob, lean, sway, breathing).

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

    %% 2. Lifelike Explorer Movement (Fixed Forward Elbows & Outward Arm Swing)
    ph = G.phase;
    if G.cheer
        % Energetic victory hop & arms raised in a V-shape
        bob   = abs(sin(t * 7.5)) * 0.22;
        lean  = -0.05;
        sway  = 0.04 * sin(t * 7.5);
        hipL  = 0; hipR = 0; kneeL = 0; kneeR = 0;
        armL  = 2.65 + 0.18 * sin(t * 10);
        armR  = 2.65 - 0.18 * sin(t * 10);
        elbL  = 0.25; elbR = 0.25;
        splay = 0.30;   % wide V-shape for cheer
    elseif G.moving
        % Natural athletic stride with bounce, forward lean & hip sway
        bob   = abs(sin(ph)) * 0.085;
        lean  = 0.10;
        sway  = 0.045 * sin(ph);
        hipL  =  0.52 * sin(ph);
        hipR  = -0.52 * sin(ph);
        kneeL = -max(0, 0.65 * cos(ph));    % knee bends backward
        kneeR = -max(0, -0.65 * cos(ph));
        armL  = -0.48 * sin(ph);            % swings opposite to left leg
        armR  =  0.48 * sin(ph);            % swings opposite to right leg
        elbL  =  0.32 + 0.38 * max(0, -sin(ph));  % bends FORWARD on forward swing
        elbR  =  0.32 + 0.38 * max(0,  sin(ph));
        splay =  0.14;  % slight outward clearance from cape/hips
    else
        % Subtle idle breathing & relaxed arms
        bob   = 0.020 * sin(t * 2.6);
        lean  = 0;
        sway  = 0.010 * sin(t * 1.3);
        hipL  = 0; hipR = 0; kneeL = 0; kneeR = 0;
        armL  =  0.04 * sin(t * 2.6);
        armR  = -0.04 * sin(t * 2.6);
        elbL  =  0.18; elbR = 0.18;         % gentle forward bend at rest
        splay =  0.10;
    end

    M_root = mtx_translate(G.px, G.py, bob) * mtx_rotz(G.heading) * ...
             mtx_rotx(lean) * mtx_roty(sway);
    set(S.char.body.h, 'Vertices', mtx_apply(M_root, S.char.body.V0));

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

    %% 3. Floating Crystal (Rotate + Bob)
    M_crys = mtx_translate(-2.6, 6.5, 2.0 + 0.22 * sin(t * 2.4)) * mtx_rotz(t * 1.4);
    set(S.crystal.h, 'Vertices', mtx_apply(M_crys, S.crystal.V0));

    %% 4. Flickering Torch Flames & Halos
    nf = S.flame.n; nv = S.flame.nv;
    Vf = zeros(nf * nv, 3);
    for k = 1:nf
        fl = 0.86 + 0.22 * sin(t * 11 + k * 2.1) + 0.08 * sin(t * 19 + k);
        M_fl = mtx_translate(S.TP(k,1), S.TP(k,2), S.TP(k,3)) * mtx_scale(0.95, 0.95, fl);
        Vf((k-1)*nv + (1:nv), :) = mtx_apply(M_fl, S.flame.V0);
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
end