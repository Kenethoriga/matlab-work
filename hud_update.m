function hud_update(H, G)
% HUD_UPDATE  Efficiently refresh the HUD for Chambers I - IV & Victory Epilogue.

    P      = G.puzzle;
    solved = G.opening;
    atsign = G.at_sign && ~solved;
    gold   = [1.00 0.84 0.46];

    ch = 1;
    if isfield(G, 'chamber'), ch = G.chamber; end
    rn  = {'I', 'II', 'III', 'IV'};
    mid = dotchar();

    %% 1. Story Opening Screen (Readable Pace + Stay Until Dismissed)
    vis = onoff(G.intro);
    if ~strcmp(get(H.intro(1), 'Visible'), vis)
        for k = 1:numel(H.intro), set(H.intro(k), 'Visible', vis); end
    end

    if G.intro
        if ch >= 5 && isfield(H, 'storyTextWin')
            nl  = char(10);
            txt = [H.storyTextWin nl nl ...
                sprintf('Final Glory: %d   %s   Attempts: %d   %s   Time: %d:%02d', ...
                G.score, mid, G.tries, mid, floor(G.time / 60), floor(mod(G.time, 60)))];
            setv(H.introTitle,   'String', 'T H E   H I D D E N   V A U L T   U N L O C K E D');
            setv(H.introTitleSh, 'String', 'T H E   H I D D E N   V A U L T   U N L O C K E D');
            setv(H.introTitle,   'Color',  [0.98 0.83 0.46]);
            setv(H.introSub,     'String', ['VICTORY   ' mid '   ALL FOUR SEALS BROKEN']);
            doneHint = 'PRESS  [ENTER]  TO  PLAY  AGAIN   |   [ESC]  TO  EXIT';
        elseif ch == 4 && isfield(H, 'storyText4')
            txt = H.storyText4;
            setv(H.introTitle,   'String', 'C H A M B E R   I V  :  C R Y S T A L   C A V E R N S');
            setv(H.introTitleSh, 'String', 'C H A M B E R   I V  :  C R Y S T A L   C A V E R N S');
            setv(H.introTitle,   'Color',  [0.35 0.92 1.00]);
            setv(H.introSub,     'String', ['THE HIDDEN VAULT   ' mid '   LINEAR EQUATIONS']);
            doneHint = 'PRESS  [ENTER]  OR  [W]  TO  ENTER  THE  SANCTUM';
        elseif ch == 3 && isfield(H, 'storyText3')
            txt = H.storyText3;
            setv(H.introTitle,   'String', 'C H A M B E R   I I I  :  T H E   V O I D');
            setv(H.introTitleSh, 'String', 'C H A M B E R   I I I  :  T H E   V O I D');
            setv(H.introTitle,   'Color',  [0.65 0.88 1.00]);
            setv(H.introSub,     'String', ['THE ASTRAL GATE   ' mid '   COLLAPSE TO ZERO']);
            doneHint = 'PRESS  [ENTER]  OR  [W]  TO  STEP  INTO  THE  VOID';
        elseif ch == 2 && isfield(H, 'storyText2')
            txt = H.storyText2;
            setv(H.introTitle,   'String', 'C H A M B E R   I I  :  T H E   I N F E R N O');
            setv(H.introTitleSh, 'String', 'C H A M B E R   I I  :  T H E   I N F E R N O');
            setv(H.introTitle,   'Color',  [1.00 0.62 0.24]);
            setv(H.introSub,     'String', ['THE CRUCIBLE OF DETERMINANTS   ' mid '   2x2 MATRICES']);
            doneHint = 'PRESS  [ENTER]  OR  [W]  TO  ENTER  THE  INFERNO';
        else
            txt = H.storyText;
            setv(H.introTitle,   'String', 'T H E   T E M P L E   O F   N U M B E R S');
            setv(H.introTitleSh, 'String', 'T H E   T E M P L E   O F   N U M B E R S');
            setv(H.introTitle,   'Color',  [0.98 0.83 0.46]);
            setv(H.introSub,     'String', ['CHAPTER I   ' mid '   THE GATE OF DIRECTION']);
            doneHint = 'PRESS  [ENTER]  OR  [W]  TO  BEGIN  YOUR  JOURNEY';
        end

        % Calm, readable typewriter speed (38 chars/sec)
        n = min(numel(txt), max(1, floor(G.intro_t * 38)));
        setv(H.introBody, 'String', txt(1:n));
        if isfield(H, 'introBodySh')
            setv(H.introBodySh, 'String', txt(1:n));
        end

        if n < numel(txt)
            setv(H.introHint, 'String', 'PRESS  [SPACE]  TO  REVEAL  ALL   |   [ENTER]  TO  START');
        else
            setv(H.introHint, 'String', doneHint);
        end
        setv(H.introHint, 'Visible', 'on');
        return
    end

    %% 2. Top Bar & Chamber Seals
    if solved
        quest = 'Quest: Pass through the open gate';
    elseif atsign
        quest = 'Quest: Speak the answer to the gate';
    else
        quest = 'Quest: Approach the arcane sign';
    end

    setv(H.sub,   'String', ['Chamber ' rn{min(ch, 4)} '  ' mid '  ' P.place]);
    setv(H.quest, 'String', quest);
    setv(H.score, 'String', sprintf('GLORY  %d', G.score));
    setv(H.stats, 'String', sprintf('Attempts %d    %s    Time %d:%02d', ...
        G.tries, mid, floor(G.time / 60), floor(mod(G.time, 60))));

    names = {['Camera 1  ' mid '  Follow (Perspective)'], ...
             ['Camera 2  ' mid '  Top Map (Orthographic)'], ...
             ['Camera 3  ' mid '  Side View (Orthographic)']};
    setv(H.view, 'String', names{G.view});

    for k = 1:4
        if k < ch || (k == ch && solved)
            setv(H.pip(k), 'FaceColor', [0.42 0.92 0.52]);
        elseif k == ch
            pulse = 0.85 + 0.15 * sin(G.frame * 0.12);
            setv(H.pip(k), 'FaceColor', min(1, gold * pulse));
        else
            setv(H.pip(k), 'FaceColor', [0.48 0.42 0.34]);
        end
    end

    %% 3. Question & Answer Dialogue Box
    cvis = onoff(atsign);
    if ~strcmp(get(H.cardParts(1), 'Visible'), cvis)
        for k = 1:numel(H.cardParts), set(H.cardParts(k), 'Visible', cvis); end
    end
    if atsign
        topic  = 'Vectors';                     if isfield(P, 'topic'),  topic  = P.topic;  end
        askStr = 'Find the dot product  A . B'; if isfield(P, 'ask'),    askStr = P.ask;    end
        pref   = 'A . B =  ';                   if isfield(P, 'prefix'), pref   = P.prefix; end

        setv(H.cHead,    'String', upper(P.place));
        setv(H.cChamber, 'String', ['Chamber ' rn{min(ch, 4)} '  ' mid '  ' topic]);
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