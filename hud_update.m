function hud_update(H, G)
% HUD_UPDATE  Refresh the on-screen interface from the game state G.
% Only properties that actually changed are set, to keep the game fast.
% Authors: <add group member names>

P = G.puzzle;
solved = G.opening;
atsign = G.at_sign && ~solved;
gold = [1.00 0.82 0.45];

% ---- story opening screen: text types itself out, Enter skips / starts ----
vis = 'off'; if G.intro, vis = 'on'; end
for k = 1:numel(H.intro), setv(H.intro(k), 'Visible', vis); end
if G.intro
    txt = H.storyText;
    n = min(numel(txt), floor(G.intro_t * 45));
    setv(H.introBody, 'String', txt(1:n));
    v = 'off'; if n >= numel(txt) && mod(floor(G.frame / 25), 2) == 0, v = 'on'; end
    setv(H.introHint, 'Visible', v);
    return
end

mid = dotchar();

% ---- top bar ----
if solved
    quest = 'Quest: pass through the open gate';
elseif atsign
    quest = 'Quest: speak the answer to the gate';
else
    quest = 'Quest: approach the sign';
end
setv(H.sub, 'String', ['Chamber I  ' mid '  ' P.place]);
setv(H.quest, 'String', quest);
setv(H.score, 'String', sprintf('GLORY  %d', G.score));
setv(H.stats, 'String', sprintf('Attempts %d    %s    Time %d:%02d', G.tries, mid, floor(G.time / 60), floor(mod(G.time, 60))));
names = {['Camera 1  ' mid '  follow, perspective'], ['Camera 2  ' mid '  top map, orthographic'], ...
    ['Camera 3  ' mid '  side, orthographic']};
setv(H.view, 'String', names{G.view});

% seals: the first glows gold while you play and turns green when broken; the rest stay dark
if solved, setv(H.pip(1), 'FaceColor', [0.45 0.9 0.5]); else, setv(H.pip(1), 'FaceColor', gold); end

% ---- riddle card, only at the sign ----
vis = 'off'; if atsign, vis = 'on'; end
for k = 1:numel(H.cardParts), setv(H.cardParts(k), 'Visible', vis); end
if atsign
    setv(H.cHead, 'String', upper(P.place));
    setv(H.cChamber, 'String', ['Chamber I  ' mid '  Vectors']);
    setv(H.cWhisper, 'String', P.whisper);
    setv(H.cA, 'String', P.line1);
    setv(H.cB, 'String', P.line2);
    setv(H.cAsk, 'String', 'Find the dot product  A . B');
    cur = '_'; if mod(floor(G.frame / 20), 2) == 1, cur = ' '; end
    setv(H.cAns, 'String', ['  A . B = ' G.input cur '  ']);
    if G.wrong >= 2
        k = find(P.hint == ':', 1);                 % split the hint over two lines
        setv(H.cHint, 'String', {P.hint(1:k), strtrim(P.hint(k+1:end))});
    else
        setv(H.cHint, 'String', '');
    end
end

% ---- prompts and banners ----
vis = 'off'; if ~solved && ~atsign, vis = 'on'; end
setv(H.walk, 'Visible', vis);
vis = 'off'; if solved && G.open_t < 1, vis = 'on'; end
setv(H.banner, 'Visible', vis);
setv(H.bannerShadow, 'Visible', vis);

% message banner
if isempty(G.msg)
    setv(H.msg, 'Visible', 'off');
else
    setv(H.msg, 'String', G.msg);
    setv(H.msg, 'EdgeColor', G.msg_col);
    setv(H.msg, 'Color', G.msg_col * 0.35 + 0.65);
    setv(H.msg, 'Visible', 'on');
end
end

function setv(h, prop, val)
% set a property only when it changed
if ~isequal(get(h, prop), val), set(h, prop, val); end
end
