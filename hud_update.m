function hud_update(H, G)
% HUD_UPDATE  Efficiently refresh the HUD for Chamber I & Chamber II.

    P      = G.puzzle;
    solved = G.opening;
    atsign = G.at_sign && ~solved;
    gold   = [1.00 0.84 0.46];

    ch = 1;
    if isfield(G, 'chamber'), ch = G.chamber; end
    rn = {'I', 'II', 'III', 'IV'};

    %% 1. Story Opening Screen (Chamber 1 & Chamber 2)
    vis = 'off'; if G.intro, vis = 'on'; end
    for k = 1:numel(H.intro), setv(H.intro(k), 'Visible', vis); end
    if G.intro
        if ch == 2 && isfield(H, 'storyText2')
            txt = H.storyText2;
        else
            txt = H.storyText;
        end
        n = min(numel(txt), floor(G.intro_t * 48));
        setv(H.introBody, 'String', txt(1:n));
        v = 'off';
        if n >= numel(txt) && mod(floor(G.frame / 22), 2) == 0, v = 'on'; end
        setv(H.introHint, 'Visible', v);
        return
    end

    mid = dotchar();

    %% 2. Top Bar & Chamber Seals
    if solved
        quest = 'Quest: Pass through the open gate';
    elseif atsign
        quest = 'Quest: Speak the answer to the gate';
    else
        quest = 'Quest: Approach the arcane sign';
    end

    setv(H.sub,   'String', ['Chamber ' rn{ch} '  ' mid '  ' P.place]);
    setv(H.quest, 'String', quest);
    setv(H.score, 'String', sprintf('GLORY  %d', G.score));
    setv(H.stats, 'String', sprintf('Attempts %d    %s    Time %d:%02d', ...
        G.tries, mid, floor(G.time / 60), floor(mod(G.time, 60))));

    names = {['Camera 1  ' mid '  Follow (Perspective)'], ...
             ['Camera 2  ' mid '  Top Map (Orthographic)'], ...
             ['Camera 3  ' mid '  Side View (Orthographic)']};
    setv(H.view, 'String', names{G.view});

    % Update all 4 Roman-numeral seals
    for k = 1:4
        if k < ch || (k == ch && solved)
            setv(H.pip(k), 'FaceColor', [0.42 0.92 0.52]);
        elseif k == ch
            pulse = 0.85 + 0.15 * sin(G.frame * 0.12);
            setv(H.pip(k), 'FaceColor', min(1, gold * pulse));
        else
            setv(H.pip(k), 'FaceColor', [0.22 0.20 0.22]);
        end
    end

    %% 3. Question & Answer Dialogue Box
    vis = 'off'; if atsign, vis = 'on'; end
    for k = 1:numel(H.cardParts), setv(H.cardParts(k), 'Visible', vis); end
    if atsign
        topic  = 'Vectors';                     if isfield(P, 'topic'),  topic  = P.topic;  end
        askStr = 'Find the dot product  A . B'; if isfield(P, 'ask'),    askStr = P.ask;    end
        pref   = 'A . B =  ';                   if isfield(P, 'prefix'), pref   = P.prefix; end

        setv(H.cHead,    'String', upper(P.place));
        setv(H.cChamber, 'String', ['Chamber ' rn{ch} '  ' mid '  ' topic]);
        setv(H.cWhisper, 'String', P.whisper);
        setv(H.cA,       'String', P.line1);
        setv(H.cB,       'String', P.line2);
        setv(H.cAsk,     'String', askStr);

        cur = '|'; if mod(floor(G.frame / 18), 2) == 1, cur = ' '; end
        setv(H.cAns, 'String', [pref G.input cur]);

        if G.wrong >= 2
            k = find(P.hint == ':', 1);
            if ~isempty(k)
                setv(H.cHint, 'String', {P.hint(1:k), strtrim(P.hint(k+1:end))});
            else
                setv(H.cHint, 'String', P.hint);
            end
        else
            setv(H.cHint, 'String', '');
        end
    end

    %% 4. Prompts & Banners
    setv(H.walk,         'Visible', onoff(~solved && ~atsign));
    setv(H.banner,       'Visible', onoff(solved && G.open_t < 1));
    setv(H.bannerShadow, 'Visible', onoff(solved && G.open_t < 1));

    if isempty(G.msg)
        setv(H.msg, 'Visible', 'off');
    else
        setv(H.msg, 'String',    G.msg);
        setv(H.msg, 'EdgeColor', G.msg_col);
        setv(H.msg, 'Color',     G.msg_col * 0.35 + 0.65);
        setv(H.msg, 'Visible',   'on');
    end
end

function s = onoff(tf)
    if tf, s = 'on'; else, s = 'off'; end
end

function setv(h, prop, val)
    if ~isequal(get(h, prop), val), set(h, prop, val); end
end