function H = hud_create(fig)
% HUD_CREATE  High-contrast ancient carved-stone & gold temple HUD with
%             gilded manuscript scroll story screens for Chamber I & II.

    gold      = [0.98 0.83 0.46];
    goldD     = [0.62 0.48 0.22];
    parchment = [0.99 0.95 0.86];
    cyan      = [0.62 0.93 1.00];
    dark      = [0.04 0.035 0.045];
    mid       = dotchar();

    H.ax = axes('Parent', fig, 'Position', [0 0 1 1], 'XLim', [0 1], 'YLim', [0 1], ...
        'Visible', 'off', 'HitTest', 'off');
    hold(H.ax, 'on');
    heads = gobjects(0);

    %% 1. Soft Vignette
    [xx, yy] = meshgrid(linspace(-1, 1, 64), linspace(-1, 1, 36));
    a = max(0, min(1, (sqrt(xx.^2 * 0.78 + yy.^2 * 1.18) - 0.55) * 0.85));
    image('Parent', H.ax, 'XData', [0 1], 'YData', [0 1], 'CData', zeros(36, 64, 3), ...
        'AlphaData', a * 0.72, 'AlphaDataMapping', 'none', 'HitTest', 'off');

    %% 2. Top Ribbon, Bottom Bar & Corner Brackets
    rectp(H.ax, 0, 0.872, 1, 0.128, dark, 0.78, 'none');
    rectp(H.ax, 0, 0.922, 1, 0.078, dark, 0.40, 'none');
    rectp(H.ax, 0, 0,     1, 0.076, dark, 0.82, 'none');
    line(H.ax, [0 1], [0.872 0.872], 'Color', gold * 0.90, 'LineWidth', 1.6);
    line(H.ax, [0 1], [0.865 0.865], 'Color', goldD,       'LineWidth', 0.8);
    line(H.ax, [0 1], [0.076 0.076], 'Color', goldD,       'LineWidth', 1.1);

    corner(H.ax, 0.008, 0.012,  1,  1, gold * 0.88, 0.036, 0.062);
    corner(H.ax, 0.992, 0.012, -1,  1, gold * 0.88, 0.036, 0.062);
    corner(H.ax, 0.008, 0.988,  1, -1, gold * 0.88, 0.036, 0.062);
    corner(H.ax, 0.992, 0.988, -1, -1, gold * 0.88, 0.036, 0.062);

    %% 3. Ancient Carved Title, Subtitle & Quest
    heads(end+1) = text(H.ax, 0.0225, 0.9515, 'M A T H   T E M P L E   R U N', 'Color', [0 0 0], ...
        'FontSize', 17, 'FontWeight', 'bold', 'Interpreter', 'none');
    H.title = text(H.ax, 0.020, 0.954, 'M A T H   T E M P L E   R U N', 'Color', gold, ...
        'FontSize', 17, 'FontWeight', 'bold', 'Interpreter', 'none');
    heads(end+1) = H.title;

    H.sub   = text(H.ax, 0.020, 0.902, '', 'Color', parchment, ...
        'FontSize', 11.5, 'FontWeight', 'bold', 'Interpreter', 'none');
    H.quest = text(H.ax, 0.020, 0.840, '', 'Color', gold, ...
        'FontSize', 12, 'FontWeight', 'bold', 'Interpreter', 'none');

    %% 4. Chamber Seals (Top Center — high-contrast stone & Roman numerals)
    H.pip = gobjects(1, 4);
    px = [0.425 0.475 0.525 0.575];
    rn = {'I', 'II', 'III', 'IV'};
    for k = 1:4
        H.pip(k) = diamond(H.ax, px(k), 0.948, 0.022, 0.038, [0.48 0.42 0.34], gold);
        heads(end+1) = text(H.ax, px(k), 0.948, rn{k}, 'Color', [0.05 0.04 0.04], ...
            'FontSize', 10, 'FontWeight', 'bold', 'HorizontalAlignment', 'center', 'Interpreter', 'none');
    end
    heads(end+1) = text(H.ax, 0.5, 0.892, 'THE FOUR SEALS  (IV IS THE HIDDEN VAULT)', ...
        'Color', [0.88 0.80 0.64], 'FontSize', 8.8, 'FontWeight', 'bold', ...
        'HorizontalAlignment', 'center', 'Interpreter', 'none');

    %% 5. Score, Stats & Camera Label
    H.score = text(H.ax, 0.98, 0.953, '', 'Color', [1.0 0.90 0.52], 'FontSize', 16.5, ...
        'FontWeight', 'bold', 'HorizontalAlignment', 'right', 'Interpreter', 'none');
    heads(end+1) = H.score;
    H.stats = text(H.ax, 0.98, 0.903, '', 'Color', parchment, 'FontSize', 11.5, ...
        'FontWeight', 'bold', 'HorizontalAlignment', 'right', 'Interpreter', 'none');
    H.view  = text(H.ax, 0.98, 0.102, '', 'Color', cyan, 'FontSize', 10.5, ...
        'FontWeight', 'bold', 'HorizontalAlignment', 'right', 'Interpreter', 'none');

    %% 6. Message & "Seal Broken" Banners
    H.msg = text(H.ax, 0.5, 0.80, '', 'Color', parchment, 'FontSize', 13, 'FontWeight', 'bold', ...
        'HorizontalAlignment', 'center', 'Interpreter', 'none', 'BackgroundColor', [0.07 0.06 0.05], ...
        'EdgeColor', gold * 0.85, 'Margin', 9, 'LineWidth', 1.3, 'Visible', 'off');
    heads(end+1) = H.msg;

    H.bannerShadow = text(H.ax, 0.503, 0.637, 'T H E   S E A L   I S   B R O K E N !', 'Color', [0 0 0], ...
        'FontSize', 27, 'FontWeight', 'bold', 'HorizontalAlignment', 'center', 'Interpreter', 'none', 'Visible', 'off');
    H.banner = text(H.ax, 0.500, 0.640, 'T H E   S E A L   I S   B R O K E N !', 'Color', gold, ...
        'FontSize', 27, 'FontWeight', 'bold', 'HorizontalAlignment', 'center', 'Interpreter', 'none', 'Visible', 'off');
    heads(end+1) = H.banner; heads(end+1) = H.bannerShadow;

    H.walk = text(H.ax, 0.5, 0.135, ['Approach the sign, seeker   ' mid '   W A S D or Arrow Keys'], ...
        'Color', parchment, 'FontSize', 12.5, 'FontWeight', 'bold', 'HorizontalAlignment', 'center', ...
        'Interpreter', 'none', 'BackgroundColor', [0.07 0.06 0.05], 'EdgeColor', gold * 0.80, 'Margin', 9, 'LineWidth', 1.3);

    %% 7. Clean Ancient Question & Answer Dialogue Box (Left Panel)
    x0 = 0.022; y0 = 0.108; w = 0.296; h = 0.472;
    cx = x0 + w / 2;
    P  = gobjects(1, 0);

    P(end+1) = tablet(H.ax, x0 + 0.005, y0 - 0.009, w, h, 0.012, [0 0 0], 0.50, 'none', 0.5);
    P(end+1) = grad_tablet(H.ax, x0, y0, w, h, 0.012, ...
        [0.14 0.12 0.10], [0.055 0.05 0.05], 0.96, gold * 0.90, 1.6);
    P(end+1) = tablet(H.ax, x0 + 0.008, y0 + 0.011, w - 0.016, h - 0.022, ...
        0.008, 'none', 0.0, goldD * 0.85, 0.8);

    H.cHead = text(H.ax, cx, y0 + h - 0.042, '', 'Color', gold, 'FontSize', 13.5, ...
        'FontWeight', 'bold', 'HorizontalAlignment', 'center', 'Interpreter', 'none');
    heads(end+1) = H.cHead; P(end+1) = H.cHead;

    H.cChamber = text(H.ax, cx, y0 + h - 0.076, '', 'Color', cyan, 'FontSize', 10.5, ...
        'FontWeight', 'bold', 'HorizontalAlignment', 'center', 'Interpreter', 'none'); P(end+1) = H.cChamber;

    H.cWhisper = text(H.ax, cx, y0 + h - 0.108, '', 'Color', [0.90 0.82 0.68], 'FontSize', 9.5, ...
        'FontWeight', 'bold', 'HorizontalAlignment', 'center', 'Interpreter', 'none'); P(end+1) = H.cWhisper;

    yd = y0 + h - 0.136;
    P(end+1) = line(H.ax, [x0 + 0.024, cx - 0.016], [yd yd], 'Color', goldD, 'LineWidth', 1.0);
    P(end+1) = line(H.ax, [cx + 0.016, x0 + w - 0.024], [yd yd], 'Color', goldD, 'LineWidth', 1.0);
    P(end+1) = diamond(H.ax, cx, yd, 0.006, 0.010, gold, gold);

    H.cA = text(H.ax, cx, y0 + 0.290, '', 'Color', [1.0 0.98 0.92], 'FontSize', 18.5, ...
        'FontWeight', 'bold', 'HorizontalAlignment', 'center', 'Interpreter', 'none'); P(end+1) = H.cA;
    H.cB = text(H.ax, cx, y0 + 0.238, '', 'Color', [1.0 0.98 0.92], 'FontSize', 18.5, ...
        'FontWeight', 'bold', 'HorizontalAlignment', 'center', 'Interpreter', 'none'); P(end+1) = H.cB;
    H.cAsk = text(H.ax, cx, y0 + 0.186, '', 'Color', gold, 'FontSize', 11.5, ...
        'FontWeight', 'bold', 'HorizontalAlignment', 'center', 'Interpreter', 'none'); P(end+1) = H.cAsk;

    P(end+1) = text(H.ax, cx, y0 + 0.146, 'TYPE ANSWER  &  PRESS ENTER', ...
        'Color', [0.76 0.88 0.94], 'FontSize', 9.0, 'FontWeight', 'bold', ...
        'HorizontalAlignment', 'center', 'Interpreter', 'none');

    P(end+1) = grad_tablet(H.ax, x0 + 0.024, y0 + 0.066, w - 0.048, 0.066, 0.006, ...
        [0.03 0.055 0.08], [0.06 0.10 0.14], 0.97, cyan * 0.95, 1.6);

    H.cAns = text(H.ax, cx, y0 + 0.099, '', 'Color', [1.0 0.98 0.92], 'FontSize', 18.5, ...
        'FontWeight', 'bold', 'HorizontalAlignment', 'center', 'Interpreter', 'none'); P(end+1) = H.cAns;

    H.cHint = text(H.ax, cx, y0 + 0.032, '', 'Color', [0.98 0.84 0.50], 'FontSize', 9.5, ...
        'FontWeight', 'bold', 'HorizontalAlignment', 'center', 'Interpreter', 'none'); P(end+1) = H.cHint;

    H.cardParts = P;

    %% 8. Fancy Carved-Gold Bottom Key Guide
    line(H.ax, [0 1], [0.068 0.068], 'Color', goldD * 0.70, 'LineWidth', 0.7);
    diamond(H.ax, 0.030, 0.036, 0.006, 0.011, gold, goldD);
    diamond(H.ax, 0.970, 0.036, 0.006, 0.011, gold, goldD);

    sep = ['   ' mid '   '];
    H.help = text(H.ax, 0.5, 0.036, ...
        ['MOVE [W A S D]' sep 'ANSWER [0-9]' sep 'CONFIRM [ENTER]' sep ...
         'CAMERA [V]' sep 'NEW RIDDLE [R]' sep 'SNAPSHOT [P]' sep 'LEAVE [ESC]'], ...
        'Color', [0.98 0.88 0.62], 'FontSize', 10.2, 'FontWeight', 'bold', ...
        'HorizontalAlignment', 'center', 'Interpreter', 'none');
    heads(end+1) = H.help;

    %% 9. Story Opening Screens (Chamber I & Chamber II — Gilded Ancient Scroll)
    nl = char(10);
    H.storyText = ['Long ago, the mathematicians of the Rift built a temple of stone' nl ...
        'and sealed every chamber behind a gate that listens for one thing:' nl ...
        'the right answer.' nl nl ...
        'You are Amani, an explorer who followed a torch-lit tunnel' nl ...
        'into the dark. Somewhere beyond three sealed gates lies the' nl ...
        'Crystal of Zero, the first number ever written.' nl nl ...
        'Walk to each sign, solve its puzzle, and the temple will let you pass.'];

    H.storyText2 = ['Beyond the Gate of Direction, the stone grows blistering hot.' nl ...
        'You descend into the Inferno — a volcanic rift where rivers of' nl ...
        'molten fire carve through blackened obsidian.' nl nl ...
        'Ahead stands the Iron Gate of the Crucible. Its molten seal' nl ...
        'demands the determinant of a 2x2 matrix to break.' nl nl ...
        'Cross the diagonals, subtract with care, and claim the second seal.'];
    
    H.storyText3 = ['Beyond the Crucible, the heat vanishes in an instant.' nl ...
        'The floor gives way to an endless, star-strewn chasm where' nl ...
        'broken obsidian stones drift in complete silence.' nl nl ...
        'Ahead floats the Astral Gate, orbiting a spinning singularity.' nl ...
        'Find the value of x that collapses the matrix determinant to zero,' nl ...
        'and the path to the Hidden Vault will open.'];

    I = gobjects(1, 0);
    % Solid dark backdrop (prevents HUD bleed-through)
    I(end+1) = rectp(H.ax, 0, 0, 1, 1, [0.015 0.012 0.016], 0.99, 'none');

    % Outer monumental gold frame + corner diamonds
    I(end+1) = grad_tablet(H.ax, 0.055, 0.065, 0.890, 0.870, 0.022, ...
        [0.095 0.078 0.068], [0.032 0.026 0.030], 0.98, gold, 2.2);
    I(end+1) = tablet(H.ax, 0.070, 0.085, 0.860, 0.830, 0.016, 'none', 0, goldD, 0.9);
    I(end+1) = diamond(H.ax, 0.095, 0.880, 0.008, 0.015, gold, gold);
    I(end+1) = diamond(H.ax, 0.905, 0.880, 0.008, 0.015, gold, gold);
    I(end+1) = diamond(H.ax, 0.095, 0.120, 0.008, 0.015, gold, gold);
    I(end+1) = diamond(H.ax, 0.905, 0.120, 0.008, 0.015, gold, gold);

    % Dynamic Title (with drop shadow) & Chapter Subtitle
    H.introTitleSh = text(H.ax, 0.5025, 0.842, 'T H E   T E M P L E   O F   N U M B E R S', ...
        'Color', [0 0 0], 'FontSize', 25, 'FontWeight', 'bold', ...
        'HorizontalAlignment', 'center', 'Interpreter', 'none');
    H.introTitle = text(H.ax, 0.500, 0.845, 'T H E   T E M P L E   O F   N U M B E R S', ...
        'Color', gold, 'FontSize', 25, 'FontWeight', 'bold', ...
        'HorizontalAlignment', 'center', 'Interpreter', 'none');
    heads(end+1) = H.introTitleSh; heads(end+1) = H.introTitle;

    % Ornamental divider
    I(end+1) = line(H.ax, [0.18 0.455], [0.785 0.785], 'Color', goldD, 'LineWidth', 1.2);
    I(end+1) = line(H.ax, [0.545 0.82], [0.785 0.785], 'Color', goldD, 'LineWidth', 1.2);
    I(end+1) = diamond(H.ax, 0.5, 0.785, 0.012, 0.022, gold, gold);
    I(end+1) = diamond(H.ax, 0.468, 0.785, 0.005, 0.009, goldD, goldD);
    I(end+1) = diamond(H.ax, 0.532, 0.785, 0.005, 0.009, goldD, goldD);

    H.introSub = text(H.ax, 0.5, 0.735, ['CHAPTER I   ' mid '   THE GATE OF DIRECTION'], ...
        'Color', [0.94 0.82 0.58], 'FontSize', 12.5, 'FontWeight', 'bold', ...
        'HorizontalAlignment', 'center', 'Interpreter', 'none');
    heads(end+1) = H.introSub;

    % Ornate recessed inner stone scroll tablet with filigree accents
    I(end+1) = grad_tablet(H.ax, 0.095, 0.225, 0.810, 0.480, 0.016, ...
        [0.13 0.105 0.085], [0.055 0.045 0.042], 0.96, gold * 0.85, 1.3);
    I(end+1) = tablet(H.ax, 0.105, 0.238, 0.790, 0.454, 0.012, 'none', 0, goldD * 0.7, 0.7);
    I(end+1) = line(H.ax, [0.30 0.70], [0.680 0.680], 'Color', goldD * 0.75, 'LineWidth', 0.8);
    I(end+1) = line(H.ax, [0.30 0.70], [0.252 0.252], 'Color', goldD * 0.75, 'LineWidth', 0.8);
    I(end+1) = diamond(H.ax, 0.5, 0.680, 0.005, 0.009, gold, gold);
    I(end+1) = diamond(H.ax, 0.5, 0.252, 0.005, 0.009, gold, gold);

    % Embossed ancient-manuscript story text (drop shadow + warm parchment)
    H.introBodySh = text(H.ax, 0.502, 0.652, '', 'Color', [0.02 0.01 0.01], 'FontSize', 17.5, ...
        'FontAngle', 'italic', 'HorizontalAlignment', 'center', ...
        'VerticalAlignment', 'top', 'Interpreter', 'none');
    H.introBody = text(H.ax, 0.500, 0.655, '', 'Color', [0.98 0.91 0.74], 'FontSize', 17.5, ...
        'FontAngle', 'italic', 'HorizontalAlignment', 'center', ...
        'VerticalAlignment', 'top', 'Interpreter', 'none');

    % Styled "Press Enter" button pill at bottom
    I(end+1) = grad_tablet(H.ax, 0.30, 0.125, 0.40, 0.072, 0.008, ...
        [0.05 0.085 0.11], [0.03 0.05 0.07], 0.96, cyan * 0.85, 1.3);
    H.introHint = text(H.ax, 0.5, 0.161, 'PRESS  [ENTER]  TO  BEGIN  YOUR  JOURNEY', ...
        'Color', cyan, 'FontSize', 11.5, 'FontWeight', 'bold', ...
        'HorizontalAlignment', 'center', 'Interpreter', 'none');
    heads(end+1) = H.introHint;

    H.intro = [I, H.introTitleSh, H.introTitle, H.introSub, H.introBodySh, H.introBody, H.introHint];
    set(H.intro, 'Visible', 'off');

    %% 10. Ancient Temple & Manuscript Typography
    try
        fonts = listfonts;
        ancient = pickfont(fonts, { ...
            'Cinzel', 'Trajan Pro', 'Copperplate Gothic Bold', 'Palatino Linotype', 'Georgia'});
        scrollFont = pickfont(fonts, { ...
            'Palatino Linotype', 'Book Antiqua', 'Georgia', 'Times New Roman'});
        bodySerif = pickfont(fonts, { ...
            'Georgia', 'Palatino Linotype', 'Cambria', 'Times New Roman'});

        t = findall(H.ax, 'Type', 'text');
        if ~isempty(bodySerif),  set(t, 'FontName', bodySerif); end
        if ~isempty(ancient),    set(heads(ishandle(heads)), 'FontName', ancient); end
        if ~isempty(scrollFont)
            set([H.introBody, H.introBodySh], 'FontName', scrollFont);
        end
    catch
    end
end

%% Local Helpers
function f = pickfont(fonts, wanted)
    f = '';
    for c = wanted
        if any(strcmp(fonts, c{1})), f = c{1}; return; end
    end
end

function h = rectp(ax, x, y, w, hgt, col, alpha, edge)
    h = patch('Parent', ax, 'XData', [x x+w x+w x], 'YData', [y y y+hgt y+hgt], ...
        'FaceColor', col, 'FaceAlpha', max(alpha, 0.001), 'EdgeColor', edge, 'HitTest', 'off');
end

function h = tablet(ax, x, y, w, hgt, c, col, alpha, edge, lw)
    cy = c * 1.5;
    X = [x+c, x+w-c, x+w, x+w, x+w-c, x+c, x, x];
    Y = [y, y, y+cy, y+hgt-cy, y+hgt, y+hgt, y+hgt-cy, y+cy];
    h = patch('Parent', ax, 'XData', X, 'YData', Y, 'FaceColor', col, ...
        'FaceAlpha', max(alpha, 0.001), 'EdgeColor', edge, 'LineWidth', lw, 'HitTest', 'off');
end

function h = grad_tablet(ax, x, y, w, hgt, c, topCol, botCol, alpha, edge, lw)
    cy = c * 1.5;
    X = [x+c, x+w-c, x+w, x+w, x+w-c, x+c, x, x]';
    Y = [y, y, y+cy, y+hgt-cy, y+hgt, y+hgt, y+hgt-cy, y+cy]';
    t = (Y - y) / max(hgt, eps);
    C = botCol .* (1 - t) + topCol .* t;
    h = patch('Parent', ax, 'Vertices', [X Y], 'Faces', 1:8, 'FaceVertexCData', C, ...
        'FaceColor', 'interp', 'FaceAlpha', alpha, 'EdgeColor', edge, ...
        'LineWidth', lw, 'HitTest', 'off');
end

function h = diamond(ax, x, y, dx, dy, col, edge)
    h = patch('Parent', ax, 'XData', [x x+dx x x-dx], 'YData', [y+dy y y-dy y], ...
        'FaceColor', col, 'EdgeColor', edge, 'LineWidth', 1.1, 'HitTest', 'off');
end

function corner(ax, x, y, sx, sy, col, lx, ly)
    line(ax, [x x + sx * lx], [y y], 'Color', col, 'LineWidth', 1.6);
    line(ax, [x x], [y y + sy * ly], 'Color', col, 'LineWidth', 1.6);
end