function run_project(mode)
% RUN_PROJECT  Math Temple Run - Chambers I, II (The Inferno), III (The Void)
%              & IV (Crystal Caverns - The Hidden Vault)
%
%   run_project            play the game (type the answer, press Enter)
%   run_project('lite')    lighter graphics for a slow computer
%   run_project('shots')   save screenshots into the screenshots folder and exit

if nargin < 1, mode = 'play'; end
here = fileparts(mfilename('fullpath'));
addpath(here);
rng('shuffle');

fig = figure('Name', 'Math Temple Run', 'NumberTitle', 'off', ...
    'Color', [0.02 0.015 0.012], 'MenuBar', 'none', 'ToolBar', 'none', 'Units', 'pixels');
W = 960; Hgt = 540;
scr = get(0, 'ScreenSize');
set(fig, 'Position', [max(1, (scr(3) - W) / 2), max(1, (scr(4) - Hgt) / 2), W, Hgt]);
set(fig, 'Units', 'normalized');
try, set(fig, 'GraphicsSmoothing', 'off'); catch, end

ax = axes('Parent', fig, 'Position', [0 0 1 1]);
lite = strcmp(mode, 'lite');
S = build_scene(ax, lite);
H = hud_create(fig);

% Lock-free input state (never overwritten by frame updates)
keys     = [0 0 0 0];   % [W/Up, S/Down, A/Left, D/Right]
introCmd = 0;           % 0 = none, 1 = reveal full scroll, 2 = start chapter

G = init_state(H);
setappdata(fig, 'G', G);

if strcmp(mode, 'shots')
    make_screenshots(fig, ax, S, H, here);
    close(fig);
    return;
end

set(fig, 'KeyPressFcn', @on_key, 'KeyReleaseFcn', @on_release);

t0 = tic; tprev = 0;
while ishandle(fig)
    t = toc(t0);
    dt = min(0.15, max(0.001, t - tprev));
    tprev = t;

    G = getappdata(fig, 'G');
    if isempty(G), break; end

    % Apply any pending intro scroll command immediately
    if introCmd == 1
        G.intro_t = 99;
        introCmd  = 0;
    elseif introCmd == 2
        introCmd = 0;
        if G.chamber == 5
            G.restart = true;
        else
            G.intro = false;
        end
    end
    G.keys = keys;

    % Handle restart from Victory Epilogue
    if isfield(G, 'restart') && G.restart
        cla(ax);
        S = build_scene(ax, lite);
        keys = [0 0 0 0]; introCmd = 0;
        G = init_state(H);
        setappdata(fig, 'G', G);
        tprev = toc(t0);
        continue;
    end

    G = step_state(G, dt);

    % ---- Transition: Chamber I -> Chamber II (The Inferno) ----
    if G.chamber == 1 && G.opening && G.py >= 14.5
        try_sfx('transition');
        [fadeBox, fadeTxt] = fade_out(fig, H, ['CHAMBER II  ' dotchar() '  THE INFERNO'], [1.0 0.65 0.25]);
        if ~ishandle(fig), break; end

        G.chamber = 2;
        cla(ax);
        S = build_chamber2(ax, lite);
        keys = [0 0 0 0]; introCmd = 0;
        G = reset_chamber_state(G, -4.0, -10.5, 2, H);
        G.msg = 'Walk the obsidian path to the Inferno Gate.';
        G.msg_col = [1 0.55 0.25]; G.msg_t = 99;

        setappdata(fig, 'G', G);
        draw_frame(ax, S, H, G, t);
        fade_in(fig, fadeBox, fadeTxt);
        tprev = toc(t0);
        continue;
    end

    % ---- Transition: Chamber II -> Chamber III (The Void) ----
    if G.chamber == 2 && G.opening && G.py >= 14.5
        try_sfx('transition');
        [fadeBox, fadeTxt] = fade_out(fig, H, ['CHAMBER III  ' dotchar() '  THE VOID'], [0.62 0.90 1.00]);
        if ~ishandle(fig), break; end

        G.chamber = 3;
        cla(ax);
        S = build_chamber3(ax, lite);
        keys = [0 0 0 0]; introCmd = 0;
        G = reset_chamber_state(G, -3.0, -9.5, 3, H);
        G.msg = 'Cross the floating stones toward the Astral Gate.';
        G.msg_col = [0.62 0.90 1.00]; G.msg_t = 99;

        setappdata(fig, 'G', G);
        draw_frame(ax, S, H, G, t);
        fade_in(fig, fadeBox, fadeTxt);
        tprev = toc(t0);
        continue;
    end

    % ---- Transition: Chamber III -> Chamber IV (Crystal Caverns) ----
    if G.chamber == 3 && G.opening && G.py >= 14.5
        try_sfx('transition');
        [fadeBox, fadeTxt] = fade_out(fig, H, ['CHAMBER IV  ' dotchar() '  CRYSTAL CAVERNS'], [0.35 0.92 1.00]);
        if ~ishandle(fig), break; end

        G.chamber = 4;
        cla(ax);
        S = build_chamber4(ax, lite);
        keys = [0 0 0 0]; introCmd = 0;
        G = reset_chamber_state(G, -4.0, -10.5, 4, H);
        G.msg = 'Follow the mossy bridge to the Crystal Sanctum.';
        G.msg_col = [0.35 0.92 1.00]; G.msg_t = 99;

        setappdata(fig, 'G', G);
        draw_frame(ax, S, H, G, t);
        fade_in(fig, fadeBox, fadeTxt);
        tprev = toc(t0);
        continue;
    end

    % ---- Transition: Chamber IV -> Victory Epilogue ----
    if G.chamber == 4 && G.opening && G.py >= 14.5
        try_sfx('transition');
        [fadeBox, fadeTxt] = fade_out(fig, H, ['THE HIDDEN VAULT  ' dotchar() '  UNSEALED'], [0.98 0.84 0.44]);
        if ~ishandle(fig), break; end

        G.chamber = 5;
        G.opening = false;
        G.at_sign = false;
        keys      = [0 0 0 0];
        introCmd  = 0;
        G.keys    = keys;
        G.intro   = true;
        G.intro_t = 0;
        if isfield(H, 'storyTextWin')
            G.intro_len = numel(H.storyTextWin);
        else
            G.intro_len = 200;
        end

        setappdata(fig, 'G', G);
        draw_frame(ax, S, H, G, t);
        fade_in(fig, fadeBox, fadeTxt);
        tprev = toc(t0);
        continue;
    end

    G.frame = G.frame + 1;
    setappdata(fig, 'G', G);
    draw_frame(ax, S, H, G, t);

    if isfield(G, 'shot') && ~isempty(G.shot)
        save_shot(fig, here, G.shot);
        G.shot = ''; setappdata(fig, 'G', G);
    end

    % Yield briefly so MATLAB processes keyboard callbacks immediately
    drawnow;
    spare = 1 / 60 - (toc(t0) - t);
    if spare > 0.002, pause(spare); end
end

% ---- Nested Callbacks (Direct, Zero-Latency Access to keys & introCmd) ----
function on_key(~, ev)
    key = ev.Key;
    ch  = ev.Character;
    Gcur = getappdata(fig, 'G');
    if isempty(Gcur), return; end

    if Gcur.intro
        if strcmp(key, 'escape')
            close(fig);
        elseif strcmp(key, 'space')
            if Gcur.intro_t * 38 < Gcur.intro_len
                introCmd = 1;
            else
                introCmd = 2;
            end
        elseif any(strcmp(key, {'return', 'enter', 'w', 'uparrow'}))
            introCmd = 2;
            if any(strcmp(key, {'w', 'uparrow'}))
                keys(1) = 1;
            end
        end
        return;
    end

    switch key
        case 'escape'
            close(fig); return;
        case {'uparrow', 'w'}
            if keys(1) == 0, keys(1) = 1; end
            return;
        case {'downarrow', 's'}
            if keys(2) == 0, keys(2) = 1; end
            return;
        case {'leftarrow', 'a'}
            if keys(3) == 0, keys(3) = 1; end
            return;
        case {'rightarrow', 'd'}
            if keys(4) == 0, keys(4) = 1; end
            return;
        case {'return', 'enter'}
            Gcur = submit_answer(Gcur);
        case 'backspace'
            if ~isempty(Gcur.input), Gcur.input(end) = []; end
        case 'v'
            Gcur.view = mod(Gcur.view, 3) + 1;
        case 'r'
            Gcur.puzzle = puzzle_new(Gcur.chamber);
            Gcur.input = ''; Gcur.wrong = 0;
            Gcur.opening = false; Gcur.at_sign = false;
            Gcur.px = 0; Gcur.py = -4; keys = [0 0 0 0]; Gcur.keys = keys;
            Gcur.msg = 'A new riddle forms and the gate seals itself again. Return to the sign.';
            Gcur.msg_col = [1 0.85 0.5]; Gcur.msg_t = 4;
        case 'p'
            Gcur.shot = 'screenshot';
        otherwise
            if ~isempty(ch) && any(ch == '0123456789-') && numel(Gcur.input) < 6 && ~Gcur.opening && Gcur.at_sign
                Gcur.input = [Gcur.input ch];
            end
    end
    setappdata(fig, 'G', Gcur);
end

function on_release(~, ev)
    switch ev.Key
        case {'uparrow', 'w'},    keys(1) = 0;
        case {'downarrow', 's'},  keys(2) = 0;
        case {'leftarrow', 'a'},  keys(3) = 0;
        case {'rightarrow', 'd'}, keys(4) = 0;
    end
end

end

% ------------------------------------------------------------------------
function G = init_state(H)
    G.chamber = 1;
    G.open_t = 0; G.opening = false; G.view = 1;
    G.input = ''; G.wrong = 0; G.shake_t = 0;
    G.px = 0; G.py = -4; G.heading = 0; G.phase = 0; G.moving = false; G.cheer = false;
    G.at_sign = false;
    G.score = 0; G.tries = 0; G.time = 0;
    G.intro = true; G.intro_t = 0;
    G.intro_len = numel(H.storyText);
    G.keys = [0 0 0 0];
    G.camx = 0; G.camy = -10.5; G.frame = 0;
    G.msg = 'Follow the torches to the sign, seeker.'; G.msg_col = [1 0.85 0.5]; G.msg_t = 99;
    G.puzzle = puzzle_new(1);
    G.restart = false;
end

function G = reset_chamber_state(G, startY, camY, ch, H)
    G.open_t = 0; G.opening = false; G.at_sign = false;
    G.input = ''; G.wrong = 0; G.shake_t = 0;
    G.px = 0; G.py = startY; G.heading = 0; G.phase = 0; G.moving = false; G.cheer = false;
    G.camx = 0; G.camy = camY;
    G.keys = [0 0 0 0];
    G.puzzle = puzzle_new(ch);
    G.intro = true; G.intro_t = 0;
    fld = sprintf('storyText%d', ch);
    if isfield(H, fld)
        G.intro_len = numel(H.(fld));
    else
        G.intro_len = numel(H.storyText);
    end
end

% ------------------------------------------------------------------------
function G = step_state(G, dt)
if G.opening
    G.open_t = min(1, G.open_t + dt / 3.2);
else
    G.open_t = max(0, G.open_t - dt / 2.4);
end
G.shake_t = max(0, G.shake_t - dt * 1.6);
if G.intro, G.intro_t = G.intro_t + dt; end
if ~G.opening && ~G.intro && G.chamber <= 4, G.time = G.time + dt; end
G.cheer = G.opening && G.open_t < 1;

% Immediate character movement when gameplay is active
if ~G.intro && G.chamber <= 4
    d = [G.keys(4) - G.keys(3), G.keys(1) - G.keys(2)];
    G.moving = any(d ~= 0);
    if G.moving
        d = d / norm(d);
        G.px = G.px + 5.4 * d(1) * dt;
        G.py = G.py + 5.4 * d(2) * dt;
        target = atan2(-d(1), d(2));
        diff = mod(target - G.heading + pi, 2*pi) - pi;
        G.heading = G.heading + diff * min(1, 18 * dt);
        G.phase = G.phase + 11 * dt;
    end
else
    G.moving = false;
end

% Snappy follow camera
tx = 0.6 * G.px;
ty = G.py - 6.5;
if G.at_sign && ~G.opening
    tx = tx + 0.75;
    ty = ty + 1.10;
elseif G.opening && G.open_t < 1
    ty = ty - 1.45 * sin(pi * G.open_t);
end
k = min(1, 12 * dt);
G.camx = G.camx + (tx - G.camx) * k;
G.camy = G.camy + (ty - G.camy) * k;
if G.shake_t > 0
    G.camx = G.camx + 0.16 * sin(G.frame * 1.9) * G.shake_t;
end

% Corridor / bridge boundaries
if G.chamber == 2 || G.chamber == 4
    G.px = max(-1.65, min(1.65, G.px));
elseif G.chamber == 3
    G.px = max(-2.10, min(2.10, G.px));
else
    G.px = max(-3.8, min(3.8, G.px));
end

% Stop at the sign until the puzzle is solved
STOP_Y = 3.0;
if ~G.opening
    if G.py >= STOP_Y
        G.py = STOP_Y;
        G.moving = false;
        if ~G.at_sign
            G.at_sign = true;
            G.msg = 'The gate whispers. Speak your answer, then press Enter.';
            G.msg_col = [1 0.85 0.5]; G.msg_t = 99;
        end
    end
else
    G.at_sign = false;
end

if G.open_t < 0.9
    G.py = max(-8.5, min(8.6, G.py));
else
    G.py = max(-8.5, min(17, G.py));
    if G.py > 9.3 && G.py < 10.7
        G.px = max(-2.2, min(2.2, G.px));
    end
end

if G.py > 11 && G.opening && G.msg_t > 50
    if G.chamber == 1
        G.msg = 'Stepping into Chamber II: The Inferno...';
        G.msg_col = [1 0.55 0.25]; G.msg_t = 4;
    elseif G.chamber == 2
        G.msg = 'Crossing into Chamber III: The Void...';
        G.msg_col = [0.62 0.90 1.00]; G.msg_t = 4;
    elseif G.chamber == 3
        G.msg = 'Descending into Chamber IV: The Crystal Caverns...';
        G.msg_col = [0.35 0.92 1.00]; G.msg_t = 4;
    else
        G.msg = 'Entering the Hidden Vault of Zero...';
        G.msg_col = [0.5 1 0.55]; G.msg_t = 4;
    end
end

G.msg_t = G.msg_t - dt;
if G.msg_t < 0 && ~G.opening
    G.msg = ''; G.msg_t = 99;
    if G.at_sign
        G.msg = 'Speak your answer, then press Enter.'; G.msg_col = [1 0.85 0.5];
    end
end
end

% ------------------------------------------------------------------------
function draw_frame(ax, S, H, G, t)
% Skip heavy 3D transforms while the opaque story scroll covers the screen
if ~G.intro
    update_scene(S, G, t);
    view_set(ax, S, G.view, G);
    P = G.puzzle;
    if isfield(S, 'panelText') && numel(S.panelText) >= 4
        ttl = P.place; if isfield(P, 'title'), ttl = P.title; end
        set(S.panelText(1), 'String', ttl);
        set(S.panelText(2), 'String', P.line1);
        set(S.panelText(3), 'String', P.line2);
        set(S.panelText(4), 'String', P.ask);
    end
end
hud_update(H, G);
end

% ------------------------------------------------------------------------
function G = submit_answer(G)
if G.opening, return; end
if ~G.at_sign
    G.msg = 'Approach the sign first, seeker.'; G.msg_col = [1 0.5 0.4]; G.msg_t = 3;
    return;
end
v = str2double(G.input);
if isnan(v)
    G.msg = 'The gate hears nothing. Type a number first.'; G.msg_col = [1 0.5 0.4]; G.msg_t = 3;
elseif v == G.puzzle.answer
    pts = max(100, 500 - 50 * G.wrong);
    G.tries = G.tries + 1; G.score = G.score + pts;
    G.opening = true; G.wrong = 0;
    G.msg = sprintf('The seal breaks!  +%d glory.  The old stone remembers you.', pts);
    G.msg_col = [0.5 1 0.55]; G.msg_t = 99;
    try_sfx('correct');
    try_sfx('gate');
else
    G.wrong = G.wrong + 1; G.tries = G.tries + 1; G.shake_t = 1; G.input = '';
    G.msg = 'The gate stays silent. Think again, seeker.';
    if G.wrong >= 2, G.msg = 'Still silent. A faint voice offers a clue below.'; end
    G.msg_col = [1 0.4 0.35]; G.msg_t = 5;
    try_sfx('wrong');
end
end

% ------------------------------------------------------------------------
function try_sfx(kind)
    if exist('sfx_play', 'file') == 2
        sfx_play(kind);
    end
end

% ------------------------------------------------------------------------
function [boxH, txtH] = fade_out(fig, H, label, col)
    if nargin < 4, col = [1.0 0.72 0.28]; end
    boxH = patch('Parent', H.ax, 'XData', [0 1 1 0], 'YData', [0 0 1 1], ...
        'FaceColor', [0.02 0.01 0.01], 'FaceAlpha', 0, 'EdgeColor', 'none', 'HitTest', 'off');
    txtH = text(H.ax, 0.5, 0.5, label, 'Color', col, 'FontSize', 22, ...
        'FontWeight', 'bold', 'HorizontalAlignment', 'center', 'Interpreter', 'none', 'Visible', 'off');
    for a = linspace(0, 1, 8)
        if ~ishandle(fig), return; end
        set(boxH, 'FaceAlpha', a);
        if a > 0.5, set(txtH, 'Visible', 'on'); end
        drawnow; pause(0.015);
    end
    pause(0.20);
end

function fade_in(fig, boxH, txtH)
    if ishandle(txtH), delete(txtH); end
    for a = linspace(1, 0, 8)
        if ~ishandle(fig), return; end
        if ishandle(boxH), set(boxH, 'FaceAlpha', a); end
        drawnow; pause(0.015);
    end
    if ishandle(boxH), delete(boxH); end
end

% ------------------------------------------------------------------------
function save_shot(fig, here, name)
d = fullfile(here, 'screenshots');
if ~exist(d, 'dir'), mkdir(d); end
f = fullfile(d, sprintf('%s_%s.png', name, datestr(now, 'HHMMSS')));
print(fig, '-dpng', '-r110', f);
fprintf('Saved %s\n', f);
end

% ------------------------------------------------------------------------
function make_screenshots(fig, ax, S, H, here)
d = fullfile(here, 'screenshots');
if ~exist(d, 'dir'), mkdir(d); end
G = getappdata(fig, 'G');
G.intro = false;
G.msg = ''; G.msg_t = 99;
shots = {
    'm2_1_closed',           0.00, 1, '';
    'm2_2_bolt_sliding',     0.22, 1, '';
    'm2_3_gate_half_open',   0.65, 1, '';
    'm2_4_gate_open',        1.00, 1, '';
    'm2_5_top_view_ortho',   0.65, 2, '';
    'm2_6_side_view_ortho',  0.65, 3, ''};
for k = 1:size(shots, 1)
    G.open_t = shots{k, 2}; G.view = shots{k, 3};
    G.px = 0; G.py = -2; G.moving = true; G.frame = 0; G.phase = 1.2; G.heading = 0; G.cheer = false;
    if k == 2, G.cheer = true; end
    G.at_sign = (k == 1);
    if k == 1, G.py = 3.0; G.moving = false; end
    if k == 3, G.py = 5; G.cheer = true; end
    if k == 4, G.py = 12.5; G.phase = 2.4; end
    G.opening = G.open_t > 0;
    if k == 1
        G.msg = 'The gate whispers. Speak your answer, then press Enter.'; G.msg_col = [1 0.85 0.5];
    elseif k == 4
        G.msg = 'The seal breaks!  +500 glory.  The old stone remembers you.'; G.msg_col = [0.5 1 0.55];
    else
        G.msg = '';
    end
    G.camx = 0.6 * G.px; G.camy = G.py - 6.5;
    draw_frame(ax, S, H, G, 1.3);
    drawnow;
    print(fig, '-dpng', '-r110', fullfile(d, [shots{k, 1} '.png']));
    fprintf('Saved %s\n', fullfile(d, [shots{k, 1} '.png']));
end
end