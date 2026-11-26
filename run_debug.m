function run_debug(startChamber, skipIntro, lite)
% RUN_DEBUG  Universal debug runner for Math Temple Run.
%            Supports jumping into any chamber (1, 2, 3, 4+).
%
%   run_debug                 -> starts in Chamber I, skips intro
%   run_debug(3)              -> starts in Chamber III (The Void)
%   run_debug(2, false)       -> starts in Chamber II WITH story intro
%   run_debug(3, true, true)  -> Chamber III in lite mode
%
% Debug Hotkeys:
%   F1 - F4       : Jump directly to Chamber I, II, III, or IV
%   [  /  ]       : Jump to Previous / Next Chamber
%   F5            : Auto-solve puzzle & open gate
%   F6            : Teleport to sign (or past open gate)

    if nargin < 1 || isempty(startChamber), startChamber = 1;     end
    if nargin < 2 || isempty(skipIntro),    skipIntro    = true;  end
    if nargin < 3 || isempty(lite),         lite         = false; end

    here = fileparts(mfilename('fullpath'));
    addpath(here);
    rng('shuffle');

    % Detect highest available chamber automatically (checks build_chamber2..9)
    maxCh = 1;
    for c = 2:9
        if exist(sprintf('build_chamber%d', c), 'file') == 2
            maxCh = c;
        end
    end
    startChamber = max(1, min(maxCh, round(startChamber)));

    fig = figure('Name', 'Math Temple Run [DEBUG]', 'NumberTitle', 'off', ...
        'Color', [0.02 0.015 0.012], 'MenuBar', 'none', 'ToolBar', 'none', 'Units', 'pixels');
    W = 960; Hgt = 540;
    scr = get(0, 'ScreenSize');
    set(fig, 'Position', [max(1, (scr(3) - W) / 2), max(1, (scr(4) - Hgt) / 2), W, Hgt]);
    set(fig, 'Units', 'normalized');
    try, set(fig, 'GraphicsSmoothing', 'on'); catch, end

    ax = axes('Parent', fig, 'Position', [0 0 1 1]);
    H  = hud_create(fig);

    % Initialize base game state
    G.view = 1; G.score = 0; G.tries = 0; G.correct = 0; G.failed = 0;
    G.time = 0; G.frame = 0; G.switch_to = 0; G.shot = '';
    G.maxCh = maxCh;
    [S, G] = load_chamber(ax, H, G, startChamber, lite, skipIntro);
    setappdata(fig, 'G', G);

    set(fig, 'KeyPressFcn', @on_key, 'KeyReleaseFcn', @on_release);
    t0 = tic; tprev = 0;

    while ishandle(fig)
        t = toc(t0); dt = min(0.1, t - tprev); tprev = t;
        G = getappdata(fig, 'G');
        if isempty(G), break; end

        % Instant debug chamber switch (F1-F4 or [ / ])
        if G.switch_to > 0
            targetCh = max(1, min(G.maxCh, G.switch_to));
            G.switch_to = 0;
            [S, G] = load_chamber(ax, H, G, targetCh, lite, skipIntro);
            setappdata(fig, 'G', G);
            tprev = toc(t0);
            continue;
        end

        G = step_state(G, dt);

        % Normal gate-walk transitions to the next available chamber
        if G.opening && G.py >= 14.5 && G.chamber < G.maxCh
            try_sfx('transition');
            [S, G] = load_chamber(ax, H, G, G.chamber + 1, lite, skipIntro);
            setappdata(fig, 'G', G);
            tprev = toc(t0);
            continue;
        end

        G.frame = G.frame + 1;
        setappdata(fig, 'G', G);
        draw_frame(ax, S, H, G, t);

        if ~isempty(G.shot)
            save_shot(fig, here, G.shot);
            G.shot = ''; setappdata(fig, 'G', G);
        end
        drawnow;
        spare = 1 / 60 - (toc(t0) - t);
        if spare > 0.002, pause(spare); end
    end
end

% ------------------------------------------------------------------------
function [S, G] = load_chamber(ax, H, G, ch, lite, skipIntro)
    cla(ax);
    G.chamber = ch;
    G.open_t = 0; G.opening = false; G.at_sign = false;
    G.input = ''; G.wrong = 0; G.shake_t = 0;
    G.px = 0; G.heading = 0; G.phase = 0; G.moving = false; G.cheer = false;
    G.keys = [0 0 0 0]; G.camx = 0; G.msg_t = 99;
    G.intro = ~skipIntro; G.intro_t = 0;

    % Dynamically call build_scene (Chamber 1) or build_chamberN (Chamber 2+)
    if ch == 1
        S = build_scene(ax, lite);
        G.py = -4.0; G.camy = -10.5;
        G.msg_col = [1.00 0.85 0.50];
    else
        builder = str2func(sprintf('build_chamber%d', ch));
        S = builder(ax, lite);
        if ch == 3
            G.py = -3.0; G.camy = -9.5;
            G.msg_col = [0.62 0.90 1.00];
        elseif ch == 2
            G.py = -4.0; G.camy = -10.5;
            G.msg_col = [1.00 0.55 0.25];
        else
            G.py = -3.5; G.camy = -10.0;
            G.msg_col = [0.85 0.95 0.65];
        end
    end

    % Match story intro length if available
    stField = sprintf('storyText%d', ch);
    if ch == 1
        G.intro_len = numel(H.storyText);
    elseif isfield(H, stField)
        G.intro_len = numel(H.(stField));
    else
        G.intro_len = 1;
    end

    G.puzzle = puzzle_new(ch);
    G.msg = sprintf('[DEBUG] Chamber %d/%d | F1-F%d or [/] jump | F5 solve | F6 warp', ...
        ch, G.maxCh, G.maxCh);
    fprintf('[DEBUG] Chamber %d/%d loaded | Answer = %d | Hotkeys: F1-F%d, [/], F5=Solve, F6=Warp\n', ...
        ch, G.maxCh, G.puzzle.answer, G.maxCh);
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

    tx = 0.6 * G.px;
    ty = G.py - 6.5;
    if G.at_sign && ~G.opening
        tx = tx + 0.75; ty = ty + 1.10;
    elseif G.opening && G.open_t < 1
        ty = ty - 1.45 * sin(pi * G.open_t);
    end
    k = min(1, 4 * dt);
    G.camx = G.camx + (tx - G.camx) * k;
    G.camy = G.camy + (ty - G.camy) * k;
    if G.shake_t > 0
        G.camx = G.camx + 0.16 * sin(G.frame * 1.9) * G.shake_t;
    end

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

    if G.chamber == 2
        G.px = max(-1.65, min(1.65, G.px));
    elseif G.chamber == 3
        G.px = max(-2.10, min(2.10, G.px));
    else
        G.px = max(-3.8, min(3.8, G.px));
    end

    STOP_Y = 3.0;
    if ~G.opening
        if G.py >= STOP_Y
            G.py = STOP_Y; G.moving = false;
            if ~G.at_sign
                G.at_sign = true;
                G.msg = sprintf('[DEBUG] Answer is %d. Type it + Enter, or press F5.', G.puzzle.answer);
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

    G.msg_t = G.msg_t - dt;
    if G.msg_t < 0 && ~G.opening
        G.msg = ''; G.msg_t = 99;
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
        if strcmp(key, 'escape'), close(fig); return;
        elseif any(strcmp(key, {'return', 'enter', 'space'}))
            if G.intro_t * 48 < G.intro_len, G.intro_t = 99; else, G.intro = false; end
        end
        setappdata(fig, 'G', G);
        return;
    end

    switch key
        case 'escape', close(fig); return;
        case 'f1',     G.switch_to = 1;
        case 'f2',     G.switch_to = 2;
        case 'f3',     G.switch_to = 3;
        case 'f4',     G.switch_to = 4;
        case 'leftbracket'
            G.switch_to = max(1, G.chamber - 1);
        case 'rightbracket'
            G.switch_to = min(G.maxCh, G.chamber + 1);
        case 'f5'
            % Debug auto-solve
            G.opening = true; G.at_sign = false; G.wrong = 0;
            G.tries = G.tries + 1; G.correct = G.correct + 1; G.score = G.score + 500;
            G.msg = '[DEBUG] Auto-solved! Gate opening.'; G.msg_col = [0.5 1 0.55]; G.msg_t = 4;
            try_sfx('correct'); try_sfx('gate');
        case 'f6'
            % Debug teleport
            if G.opening
                G.px = 0; G.py = 13.5;
            else
                G.px = 0; G.py = 3.0; G.at_sign = true;
            end
        case {'uparrow', 'w'},    G.keys(1) = 1;
        case {'downarrow', 's'},  G.keys(2) = 1;
        case {'leftarrow', 'a'},  G.keys(3) = 1;
        case {'rightarrow', 'd'}, G.keys(4) = 1;
        case {'return', 'enter'}, G = submit_answer(G);
        case 'backspace'
            if ~isempty(G.input), G.input(end) = []; end
        case 'v'
            G.view = mod(G.view, 3) + 1;
        case 'r'
            G.puzzle = puzzle_new(G.chamber); G.input = ''; G.wrong = 0;
            G.opening = false; G.at_sign = false; G.px = 0; G.py = -3; G.keys = [0 0 0 0];
            fprintf('[DEBUG] New riddle | Answer = %d\n', G.puzzle.answer);
        case 'p'
            G.shot = 'debug_shot';
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
    if G.opening || ~G.at_sign, return; end
    v = str2double(G.input);
    if isnan(v)
        G.msg = 'Type a number first.'; G.msg_col = [1 0.5 0.4]; G.msg_t = 3;
    elseif v == G.puzzle.answer
        pts = max(100, 500 - 50 * G.wrong);
        G.tries = G.tries + 1; G.correct = G.correct + 1; G.score = G.score + pts;
        G.opening = true; G.wrong = 0;
        G.msg = sprintf('The seal breaks!  +%d glory.', pts);
        G.msg_col = [0.5 1 0.55]; G.msg_t = 99;
        try_sfx('correct'); try_sfx('gate');
    else
        G.wrong = G.wrong + 1; G.tries = G.tries + 1; G.failed = G.failed + 1;
        G.shake_t = 1; G.input = '';
        G.msg = 'Wrong answer. Try again.'; G.msg_col = [1 0.4 0.35]; G.msg_t = 4;
        try_sfx('wrong');
    end
end

function try_sfx(kind)
    if exist('sfx_play', 'file') == 2, sfx_play(kind); end
end

function save_shot(fig, here, name)
    d = fullfile(here, 'screenshots');
    if ~exist(d, 'dir'), mkdir(d); end
    f = fullfile(d, sprintf('%s_%s.png', name, datestr(now, 'HHMMSS')));
    print(fig, '-dpng', '-r110', f);
    fprintf('Saved %s\n', f);
end