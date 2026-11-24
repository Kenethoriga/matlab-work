function update_scene(S, G, t)
% UPDATE_SCENE  Move everything for time t (seconds) and game state G.
% Every movement is done with our own 4x4 matrices (mtx_*.m):
%   gate:      world = M_gate * M_leaf * M_bolt          (leaf turns about its hinge)
%   explorer:  world = M_root * M_thigh * M_shin  (and upper arm -> forearm)
%   flames flicker, crystal spins and bobs, embers drift.
% Authors: <add group member names>

% ---------- gate (only recomputed when it is moving) ----------
s  = G.open_t;
sb = smooth01(min(1, s / 0.30));              % bolt slide 0..1
sl = smooth01(max(0, (s - 0.30) / 0.70));     % door swing 0..1
key = s;
ud = get(S.rune, 'UserData');
if G.shake_t > 0 || isempty(ud) || ud ~= key
    shake = G.shake_t * sin(40 * t) * 0.03;   % small rattle after a wrong answer
    M_gate = mtx_translate(0, 10, 0);         % level 1: gate placed in the corridor
    hinge = 2.5;
    angL =  (105 * pi / 180) * sl + shake;
    angR = -(105 * pi / 180) * sl - shake;
    M_leafL = M_gate * rot_about_z(-hinge, angL);          % level 2: leaf about its hinge
    M_leafR = M_gate * rot_about_z( hinge, angR);
    set(S.gate.leafL.h, 'Vertices', mtx_apply(M_leafL, S.gate.leafL.V0));
    set(S.gate.leafR.h, 'Vertices', mtx_apply(M_leafR, S.gate.leafR.V0));
    set(S.gate.boltL.h, 'Vertices', mtx_apply(M_leafL * mtx_translate(-0.75 * sb, 0, 0), S.gate.boltL.V0));  % level 3
    set(S.gate.boltR.h, 'Vertices', mtx_apply(M_leafR * mtx_translate( 0.75 * sb, 0, 0), S.gate.boltR.V0));
    set(S.rune, 'FaceColor', [0.8 0.15 0.1] * (1 - sl) + [1 0.85 0.3] * sl, 'UserData', key);
    set(S.gateLight, 'Color', [1 0.82 0.45] * sl);
    set(S.portal, 'FaceColor', [1 0.85 0.45] * (0.25 + 0.75 * sl));
end

% ---------- explorer: body -> thigh -> shin, body -> upper arm -> forearm ----------
mv = double(G.moving);
bob = 0.06 * abs(sin(G.phase)) * mv + 0.012 * sin(2.2 * t) * (1 - mv);   % step bounce / breathing
lean = -0.08 * mv;                                                       % lean into the walk
M_root = mtx_translate(G.px, G.py, bob) * mtx_rotz(G.heading) * mtx_rotx(lean);
p = G.phase;
hipL =  0.75 * sin(p) * mv;           hipR = -hipL;
kneeL = -0.95 * max(0, cos(p)) * mv;  kneeR = -0.95 * max(0, -cos(p)) * mv;   % knee bends in the swing
shL = -0.65 * sin(p) * mv;            shR = -shL;
elL = 0.20 + 0.45 * max(0, sin(p + 0.4)) * mv;
elR = 0.20 + 0.45 * max(0, -sin(p + 0.4)) * mv;
if G.cheer                             % both arms up when the gate opens
    wave = 0.25 * sin(10 * t);
    shL = 2.7 + wave; shR = 2.7 - wave; elL = 0.2; elR = 0.2;
end
C = S.char;
set(C.body.h, 'Vertices', mtx_apply(M_root, C.body.V0));
for sd = 1:2
    if sd == 1
        nm = 'L'; hp = hipL; kn = kneeL; sh = shL; el = elL; sx = -1;
    else
        nm = 'R'; hp = hipR; kn = kneeR; sh = shR; el = elR; sx = 1;
    end
    hipP = [sx * C.hip(1), C.hip(2), C.hip(3)];
    kneeP = [sx * C.hip(1), 0, C.knee(3)];
    shP = [sx * C.shoulder(1), 0, C.shoulder(3)];
    elP = [sx * C.shoulder(1), 0, C.elbow(3)];
    M_thigh = M_root * rot_about_x(hipP, hp);                  % level 2
    M_shin  = M_thigh * rot_about_x(kneeP, kn);                % level 3
    M_uarm  = M_root * rot_about_x(shP, sh);
    M_farm  = M_uarm * rot_about_x(elP, el);
    set(C.(['thigh' nm]).h, 'Vertices', mtx_apply(M_thigh, C.(['thigh' nm]).V0));
    set(C.(['shin'  nm]).h, 'Vertices', mtx_apply(M_shin,  C.(['shin'  nm]).V0));
    set(C.(['uarm'  nm]).h, 'Vertices', mtx_apply(M_uarm,  C.(['uarm'  nm]).V0));
    set(C.(['farm'  nm]).h, 'Vertices', mtx_apply(M_farm,  C.(['farm'  nm]).V0));
end
sc = 1 - 0.25 * bob / 0.06;            % shadow shrinks a little when the explorer steps up
set(S.shadow.h, 'Vertices', mtx_apply(mtx_translate(G.px, G.py, 0.02) * mtx_rotz(G.heading) * mtx_scale(sc * 0.9, sc * 0.7, 1), S.shadow.V0));

% ---------- flames, halos, embers, crystal (every 2nd frame is plenty) ----------
if mod(G.frame, 2) == 0
nf = S.flame.n; nv = S.flame.nv;
Vf = zeros(nf * nv, 3);
Vh = zeros(nf * S.halo.nv, 3);
for k = 1:nf
    f = 1.10 + 0.28 * sin(9 * t + 2.1 * k) + 0.12 * sin(23 * t + k);
    M = mtx_translate(S.TP(k, 1), S.TP(k, 2), S.TP(k, 3)) * ...
        mtx_rotx(0.14 * sin(7 * t + k)) * mtx_roty(0.14 * sin(9 * t + 2 * k)) * mtx_scale(0.9, 0.9, f);
    Vf((k-1)*nv + (1:nv), :) = mtx_apply(M, S.flame.V0);
    if ~S.lite
        g = 0.9 + 0.12 * sin(9 * t + 2.1 * k);
        Mh = mtx_translate(S.TP(k, 1), S.TP(k, 2), S.TP(k, 3) + 0.12) * mtx_scale(g, g, g);
        Vh((k-1)*S.halo.nv + (1:S.halo.nv), :) = mtx_apply(Mh, S.halo.V0);
    end
end
set(S.flame.h, 'Vertices', Vf);
if ~S.lite
    set(S.halo.h, 'Vertices', Vh);
    e = S.ember;
    zz = mod(e.z0 + 0.35 * t, 6);
    set(e.h, 'XData', e.x0 + 0.4 * sin(0.8 * t + e.ph), 'YData', e.y0 + 0.3 * cos(0.6 * t + e.ph), 'ZData', zz);
end
end

if mod(G.frame, 2) == 0                      % lights: follow the two nearest torch pairs
    pairs = [1 6 14];
    [~, ord] = sort(abs(pairs - G.py));
    idx = [2*ord(1)-1, 2*ord(1), 2*ord(2)-1, 2*ord(2)];
    for k = 1:4
        g = 0.82 + 0.12 * sin(9 * t + 2.1 * idx(k)) + 0.04 * sin(23 * t + idx(k));
        set(S.torchLights(k), 'Position', S.TP(idx(k), :) + [0 0 0.3], 'Color', min(1, [1.0 0.60 0.28] * g));
    end
end

M = mtx_translate(-2.6, 6.5, 1.9 + 0.15 * sin(1.6 * t)) * mtx_rotz(1.2 * t) * mtx_rotx(0.25);
set(S.crystal.h, 'Vertices', mtx_apply(M, S.crystal.V0));
set(S.crystalLight, 'Color', [0.2 0.5 0.6] * (0.8 + 0.2 * sin(3 * t)));
end

function y = smooth01(x)
y = x .* x .* (3 - 2 * x);                   % ease in / ease out
end

function M = rot_about_z(hx, ang)
% turn by ang about the vertical line through (hx, 0).  Same result as
% T(h) * Rz(ang) * T(-h), written out so it needs one matrix call.
M = mtx_rotz(ang);
M(1:3, 4) = [hx; 0; 0] - M(1:3, 1:3) * [hx; 0; 0];
end

function M = rot_about_x(pv, ang)
% turn by ang about the sideways line through the pivot point pv.  Same result as
% T(p) * Rx(ang) * T(-p), written out so it needs one matrix call.
M = mtx_rotx(ang);
M(1:3, 4) = pv(:) - M(1:3, 1:3) * pv(:);
end
