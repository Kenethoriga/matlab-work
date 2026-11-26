function run_project(mode)
% RUN_PROJECT  Math Temple Run - Chambers I, II (The Inferno) & III (The Void)
%
%   run_project            play the game (type the answer, press Enter)
%   run_project('lite')    lighter graphics for a slow computer
%   run_project('shots')   save screenshots into the screenshots folder and exit
%
% Authors: <add group member names>
% Course:  SCS3301 Computer Graphics, University of Nairobi
% Base MATLAB only, no toolboxes.

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
try, set(fig, 'GraphicsSmoothing', 'on'); catch, end

ax = axes('Parent', fig, 'Position', [0 0 1 1]);
lite = strcmp(mode, 'lite');
S = build_scene(ax, lite);
H = hud_create(fig);

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
setappdata(fig, 'G', G);

if strcmp(mode, 'shots')
    make_screenshots(fig, ax, S, H, here);
    close(fig);
    return;
end

set(fig, 'KeyPressFcn', @on_key, 'KeyReleaseFcn', @on_release);
t0 = tic; tprev = 0;
while ishandle(fig)
    t = toc(t0); dt = min(0.1, t - tprev); tprev = t;
    G = getappdata(fig, 'G');
    if isempty(G), break; end
    G = step_state(G, dt);

    % ---- Smooth Cinematic Transition: Chamber I -> Chamber II (The Inferno) ----
    if G.chamber == 1 && G.opening && G.py >= 14.5
        try_sfx('transition');
        [fadeBox, fadeTxt] = fade_out(fig, H, ['CHAMBER II  ' dotchar() '  THE INFERNO'], [1.0 0.65 0.25]);
        if ~ishandle(fig), break; end

        G.chamber = 2;
        cla(ax);
        S = build_chamber2(ax, lite);
        G.open_t = 0; G.opening = false; G.at_sign = false;
        G.input = ''; G.wrong = 0; G.shake_t = 0;
        G.px = 0; G.py = -4; G.heading = 0; G.phase = 0; G.moving = false; G.cheer = false;
        G.camx = 0; G.camy = -10.5;
        G.keys = [0 0 0 0];
        G.puzzle = puzzle_new(2);
        G.intro = true; G.intro_t = 0;
        if isfield(H, 'storyText2')
            G.intro_len = numel(H.storyText2);
        else
            G.intro_len = numel(H.storyText);
        end
        G.msg = 'Walk the obsidian path to the Inferno Gate.';
        G.msg_col = [1 0.55 0.25]; G.msg_t = 99;

        setappdata(fig, 'G', G);
        draw_frame(ax, S, H, G, t);
        fade_in(fig, fadeBox, fadeTxt);
        tprev = toc(t0);
        continue;
    end

    % ---- Smooth Cinematic Transition: Chamber II -> Chamber III (The Void) ----
    if G.chamber == 2 && G.opening && G.py >= 14.5
        try_sfx('transition');
        [fadeBox, fadeTxt] = fade_out(fig, H, ['CHAMBER III  ' dotchar() '  THE VOID'], [0.62 0.90 1.00]);
        if ~ishandle(fig), break; end

        G.chamber = 3;
        cla(ax);
        S = build_chamber3(ax, lite);
        G.open_t = 0; G.opening = false; G.at_sign = false;
        G.input = ''; G.wrong = 0; G.shake_t = 0;
        G.px = 0; G.py = -3.0; G.heading = 0; G.phase = 0; G.moving = false; G.cheer = false;
        G.camx = 0; G.camy = -9.5;
        G.keys = [0 0 0 0];
        G.puzzle = puzzle_new(3);
        G.intro = true; G.intro_t = 0;
        if isfield(H, 'storyText3')
            G.intro_len = numel(H.storyText3);
        else
            G.intro_len = numel(H.storyText);
        end
        G.msg = 'Cross the floating stones toward the Astral Gate.';
        G.msg_col = [0.62 0.90 1.00]; G.msg_t = 99;

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
    drawnow;
    spare = 1 / 60 - (toc(t0) - t);
    if spare > 0.002, pause(spare); end
end
end

% ------------------------------------------------------------------------
function G = step_state(G, dt)
if G.opening
    G.open_t = min(1, G.open_t + dt / 3.4);
else
    G.open_t = max(0, G.open_t - dt / 2.4);
end
G.shake_t = max(0, G.shake_t - dt * 1.6);
if G.intro, G.intro_t = G.intro_t + dt; end
if ~G.opening && ~G.intro, G.time = G.time + dt; end
G.cheer = G.opening && G.open_t < 1;

% Smooth follow camera with riddle zoom, gate pullback & shake
tx = 0.6 * G.px;
ty = G.py - 6.5;
if G.at_sign && ~G.opening
    tx = tx + 0.75;   % frame Amani & gate cleanly beside the left riddle tablet
    ty = ty + 1.10;   % gentle focus zoom
elseif G.opening && G.open_t < 1
    ty = ty - 1.45 * sin(pi * G.open_t);  % dramatic pullback as gate opens
end
k = min(1, 4 * dt);
G.camx = G.camx + (tx - G.camx) * k;
G.camy = G.camy + (ty - G.camy) * k;
if G.shake_t > 0
    G.camx = G.camx + 0.16 * sin(G.frame * 1.9) * G.shake_t;
end

% Walk the explorer
d = [G.keys(4) - G.keys(3), G.keys(1) - G.keys(2)];
G.moving = any(d ~= 0);
if G.moving
    d = d / norm(d);
    G.px = G.px + 4.2 * d(1) * dt;
    G.py = G.py + 4.2 * d(2) * dt;
    target = atan2(-d(1), d(2));
    diff = mod(target - G.heading + pi, 2*pi) - pi;
    G.heading = G.heading + diff * min(1, 12 * dt);
    G.phase = G.phase + 9 * dt;
end

% Keep explorer inside corridor / bridge / floating stones
if G.chamber == 2
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
    else
        G.msg = 'The Void yields! The Hidden Vault of Zero awaits ahead.';
        G.msg_col = [0.5 1 0.55]; G.msg_t = 6;
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
hud_update(H, G);
end

% ------------------------------------------------------------------------
function on_key(fig, ev)
G = getappdata(fig, 'G');
key = ev.Key; ch = ev.Character;
if G.intro
    if strcmp(key, 'escape')
        close(fig); return;
    elseif any(strcmp(key, {'return', 'enter', 'space'}))
        if G.intro_t * 48 < G.intro_len, G.intro_t = 99; else, G.intro = false; end
    end
    setappdata(fig, 'G', G);
    return;
end
switch key
    case 'escape'
        close(fig); return;
    case {'uparrow', 'w'}
        G.keys(1) = 1;
    case {'downarrow', 's'}
        G.keys(2) = 1;
    case {'leftarrow', 'a'}
        G.keys(3) = 1;
    case {'rightarrow', 'd'}
        G.keys(4) = 1;
    case {'return', 'enter'}
        G = submit_answer(G);
    case 'backspace'
        if ~isempty(G.input), G.input(end) = []; end
    case 'v'
        G.view = mod(G.view, 3) + 1;
    case 'r'
        G.puzzle = puzzle_new(G.chamber); G.input = ''; G.wrong = 0; G.time = 0;
        G.opening = false; G.at_sign = false;
        G.px = 0; G.py = -4; G.keys = [0 0 0 0];
        G.msg = 'A new riddle forms and the gate seals itself again. Return to the sign.';
        G.msg_col = [1 0.85 0.5]; G.msg_t = 4;
    case 'p'
        G.shot = 'screenshot';
    otherwise
        if ~isempty(ch) && any(ch == '0123456789-') && numel(G.input) < 6 && ~G.opening && G.at_sign
            G.input = [G.input ch];
        end
end
setappdata(fig, 'G', G);
end

% ------------------------------------------------------------------------
function on_release(fig, ev)
G = getappdata(fig, 'G');
switch ev.Key
    case {'uparrow', 'w'},    G.keys(1) = 0;
    case {'downarrow', 's'},  G.keys(2) = 0;
    case {'leftarrow', 'a'},  G.keys(3) = 0;
    case {'rightarrow', 'd'}, G.keys(4) = 0;
end
setappdata(fig, 'G', G);
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
    for a = linspace(0, 1, 18)
        if ~ishandle(fig), return; end
        set(boxH, 'FaceAlpha', a);
        if a > 0.5, set(txtH, 'Visible', 'on'); end
        drawnow; pause(0.02);
    end
    pause(0.45);
end

function fade_in(fig, boxH, txtH)
    if ishandle(txtH), delete(txtH); end
    for a = linspace(1, 0, 16)
        if ~ishandle(fig), return; end
        if ishandle(boxH), set(boxH, 'FaceAlpha', a); end
        drawnow; pause(0.02);
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