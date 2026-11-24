function H = hud_create(fig)
% HUD_CREATE  Sleek ancient carved-stone & gold temple HUD with gradient
%             tablet dialogue box, soft drop shadow, and custom input slot.

    gold   = [0.96 0.80 0.44];
    goldD  = [0.55 0.42 0.19];
    cyan   = [0.56 0.90 1.00];
    dark   = [0.04 0.035 0.045];
    mid    = dotchar();

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
    rectp(H.ax, 0, 0.878, 1, 0.122, dark, 0.68, 'none');
    rectp(H.ax, 0, 0.922, 1, 0.078, dark, 0.38, 'none');
    rectp(H.ax, 0, 0,     1, 0.072, dark, 0.72, 'none');
    line(H.ax, [0 1], [0.878 0.878], 'Color', gold * 0.88, 'LineWidth', 1.6);
    line(H.ax, [0 1], [0.871 0.871], 'Color', goldD,       'LineWidth', 0.7);
    line(H.ax, [0 1], [0.072 0.072], 'Color', goldD,       'LineWidth', 1.0);

    corner(H.ax, 0.008, 0.012,  1,  1, gold * 0.85, 0.036, 0.062);
    corner(H.ax, 0.992, 0.012, -1,  1, gold * 0.85, 0.036, 0.062);
    corner(H.ax, 0.008, 0.988,  1, -1, gold * 0.85, 0.036, 0.062);
    corner(H.ax, 0.992, 0.988, -1, -1, gold * 0.85, 0.036, 0.062);

    %% 3. Title, Subtitle & Quest
    heads(end+1) = text(H.ax, 0.0225, 0.9515, 'MATH TEMPLE RUN', 'Color', [0 0 0], ...
        'FontSize', 19, 'FontWeight', 'bold', 'Interpreter', 'none');
    H.title = text(H.ax, 0.020, 0.954, 'MATH TEMPLE RUN', 'Color', gold, ...
        'FontSize', 19, 'FontWeight', 'bold', 'Interpreter', 'none');
    heads(end+1) = H.title;

    H.sub   = text(H.ax, 0.020, 0.906, '', 'Color', [0.90 0.85 0.74], ...
        'FontSize', 10.5, 'FontAngle', 'italic', 'Interpreter', 'none');
    H.quest = text(H.ax, 0.020, 0.844, '', 'Color', gold, ...
        'FontSize', 11, 'FontWeight', 'bold', 'Interpreter', 'none');

    %% 4. Chamber Seals (Top Center)
    H.pip = gobjects(1, 4);
    px = [0.425 0.475 0.525 0.575];
    rn = {'I', 'II', 'III', 'IV'};
    for k = 1:4
        H.pip(k) = diamond(H.ax, px(k), 0.948, 0.021, 0.036, [0.22 0.20 0.22], goldD);
        heads(end+1) = text(H.ax, px(k), 0.948, rn{k}, 'Color', [0.06 0.05 0.06], ...
            'FontSize', 8.5, 'FontWeight', 'bold', 'HorizontalAlignment', 'center', 'Interpreter', 'none');
    end
    heads(end+1) = text(H.ax, 0.5, 0.898, 'THE FOUR SEALS  (IV is the hidden vault)', ...
        'Color', [0.74 0.68 0.56], 'FontSize', 7.5, 'HorizontalAlignment', 'center', 'Interpreter', 'none');

    %% 5. Score, Stats & Camera Label
    H.score = text(H.ax, 0.98, 0.953, '', 'Color', [1.0 0.90 0.55], 'FontSize', 16, ...
        'FontWeight', 'bold', 'HorizontalAlignment', 'right', 'Interpreter', 'none');
    heads(end+1) = H.score;
    H.stats = text(H.ax, 0.98, 0.908, '', 'Color', [0.88 0.83 0.74], 'FontSize', 10.5, ...
        'HorizontalAlignment', 'right', 'Interpreter', 'none');
    H.view  = text(H.ax, 0.98, 0.098, '', 'Color', cyan, 'FontSize', 9.5, ...
        'FontAngle', 'italic', 'HorizontalAlignment', 'right', 'Interpreter', 'none');

    %% 6. Message & "Seal Broken" Banners
    H.msg = text(H.ax, 0.5, 0.80, '', 'Color', [0.98 0.94 0.84], 'FontSize', 12.5, 'FontWeight', 'bold', ...
        'HorizontalAlignment', 'center', 'Interpreter', 'none', 'BackgroundColor', [0.08 0.07 0.06], ...
        'EdgeColor', gold * 0.80, 'Margin', 9, 'LineWidth', 1.2, 'Visible', 'off');
    heads(end+1) = H.msg;

    H.bannerShadow = text(H.ax, 0.503, 0.637, 'THE SEAL IS BROKEN!', 'Color', [0 0 0], ...
        'FontSize', 31, 'FontWeight', 'bold', 'HorizontalAlignment', 'center', 'Interpreter', 'none', 'Visible', 'off');
    H.banner = text(H.ax, 0.500, 0.640, 'THE SEAL IS BROKEN!', 'Color', gold, ...
        'FontSize', 31, 'FontWeight', 'bold', 'HorizontalAlignment', 'center', 'Interpreter', 'none', 'Visible', 'off');
    heads(end+1) = H.banner; heads(end+1) = H.bannerShadow;

    H.walk = text(H.ax, 0.5, 0.135, ['Approach the sign, seeker   ' mid '   W A S D or Arrow Keys'], ...
        'Color', [0.96 0.94 0.88], 'FontSize', 12, 'FontWeight', 'bold', 'HorizontalAlignment', 'center', ...
        'Interpreter', 'none', 'BackgroundColor', [0.08 0.07 0.06], 'EdgeColor', gold * 0.75, 'Margin', 9, 'LineWidth', 1.2);

    %% 7. Clean Ancient Question & Answer Dialogue Box (Left Panel)
    x0 = 0.024; y0 = 0.110; w = 0.286; h = 0.460;
    cx = x0 + w / 2;
    P  = gobjects(1, 0);

    % Soft drop shadow
    P(end+1) = tablet(H.ax, x0 + 0.005, y0 - 0.009, w, h, 0.012, [0 0 0], 0.45, 'none', 0.5);

    % Main dark-stone tablet with subtle warm top-to-bottom gradient
    P(end+1) = grad_tablet(H.ax, x0, y0, w, h, 0.012, ...
        [0.13 0.11 0.095], [0.055 0.05 0.05], 0.94, gold * 0.85, 1.5);

    % Fine inner gold border
    P(end+1) = tablet(H.ax, x0 + 0.008, y0 + 0.011, w - 0.016, h - 0.022, ...
        0.008, 'none', 0.0, goldD * 0.8, 0.7);

    % Header: Title, Chamber, Whisper
    H.cHead = text(H.ax, cx, y0 + h - 0.040, '', 'Color', gold, 'FontSize', 12.5, ...
        'FontWeight', 'bold', 'HorizontalAlignment', 'center', 'Interpreter', 'none');
    heads(end+1) = H.cHead; P(end+1) = H.cHead;

    H.cChamber = text(H.ax, cx, y0 + h - 0.072, '', 'Color', cyan, 'FontSize', 9.5, ...
        'FontWeight', 'bold', 'HorizontalAlignment', 'center', 'Interpreter', 'none'); P(end+1) = H.cChamber;

    H.cWhisper = text(H.ax, cx, y0 + h - 0.102, '', 'Color', [0.82 0.75 0.62], 'FontSize', 8.5, ...
        'FontAngle', 'italic', 'HorizontalAlignment', 'center', 'Interpreter', 'none'); P(end+1) = H.cWhisper;

    % Ornamental divider
    yd = y0 + h - 0.128;
    P(end+1) = line(H.ax, [x0 + 0.024, cx - 0.016], [yd yd], 'Color', goldD, 'LineWidth', 0.9);
    P(end+1) = line(H.ax, [cx + 0.016, x0 + w - 0.024], [yd yd], 'Color', goldD, 'LineWidth', 0.9);
    P(end+1) = diamond(H.ax, cx, yd, 0.006, 0.010, gold, gold);

    % Question Section (Equations + Ask)
    H.cA = text(H.ax, cx, y0 + 0.285, '', 'Color', [0.99 0.97 0.93], 'FontSize', 17.5, ...
        'FontWeight', 'bold', 'HorizontalAlignment', 'center', 'Interpreter', 'none'); P(end+1) = H.cA;
    H.cB = text(H.ax, cx, y0 + 0.236, '', 'Color', [0.99 0.97 0.93], 'FontSize', 17.5, ...
        'FontWeight', 'bold', 'HorizontalAlignment', 'center', 'Interpreter', 'none'); P(end+1) = H.cB;
    H.cAsk = text(H.ax, cx, y0 + 0.186, '', 'Color', gold * 0.95, 'FontSize', 10.5, ...
        'FontWeight', 'bold', 'HorizontalAlignment', 'center', 'Interpreter', 'none'); P(end+1) = H.cAsk;

    % Answer Input Section (Label + Clean Recessed Input Box)
    P(end+1) = text(H.ax, cx, y0 + 0.146, 'TYPE ANSWER  &  PRESS ENTER', ...
        'Color', [0.65 0.78 0.85], 'FontSize', 7.5, 'FontWeight', 'bold', ...
        'HorizontalAlignment', 'center', 'Interpreter', 'none');

    P(end+1) = grad_tablet(H.ax, x0 + 0.028, y0 + 0.068, w - 0.056, 0.064, 0.006, ...
        [0.03 0.055 0.08], [0.055 0.095 0.135], 0.96, cyan * 0.9, 1.5);

    H.cAns = text(H.ax, cx, y0 + 0.100, '', 'Color', [1 1 1], 'FontSize', 18, ...
        'FontWeight', 'bold', 'HorizontalAlignment', 'center', 'Interpreter', 'none'); P(end+1) = H.cAns;

    % Hint at bottom
    H.cHint = text(H.ax, cx, y0 + 0.034, '', 'Color', [0.95 0.80 0.48], 'FontSize', 8.3, ...
        'FontAngle', 'italic', 'HorizontalAlignment', 'center', 'Interpreter', 'none'); P(end+1) = H.cHint;

    H.cardParts = P;

    %% 8. Fancy Carved-Gold Bottom Key Guide
    line(H.ax, [0 1], [0.066 0.066], 'Color', goldD * 0.65, 'LineWidth', 0.6);
    diamond(H.ax, 0.045, 0.035, 0.006, 0.011, gold, goldD);
    diamond(H.ax, 0.955, 0.035, 0.006, 0.011, gold, goldD);

    sep = ['   ' mid '   '];
    H.help = text(H.ax, 0.5, 0.035, ...
        ['MOVE [W A S D]' sep 'ANSWER [0-9]' sep 'CONFIRM [ENTER]' sep ...
         'CAMERA [V]' sep 'NEW RIDDLE [R]' sep 'SNAPSHOT [P]' sep 'LEAVE [ESC]'], ...
        'Color', [0.94 0.82 0.54], 'FontSize', 9.5, 'FontWeight', 'bold', ...
        'HorizontalAlignment', 'center', 'Interpreter', 'none');
    heads(end+1) = H.help;

    %% 9. Story Opening Screen
    nl = char(10);
    H.storyText = ['Long ago, the mathematicians of the Rift built a temple of stone' nl ...
        'and sealed every chamber behind a gate that listens for one thing:' nl ...
        'the right answer.' nl nl ...
        'You are Amani, an explorer who followed a torch-lit tunnel' nl ...
        'into the dark. Somewhere beyond three sealed gates lies the' nl ...
        'Crystal of Zero, the first number ever written.' nl nl ...
        'Walk to each sign, solve its puzzle, and the temple will let you pass.'];

    I = gobjects(1, 0);
    I(end+1) = rectp(H.ax, 0, 0, 1, 1, [0.012 0.010 0.015], 0.95, 'none');
    I(end+1) = tablet(H.ax, 0.060, 0.070, 0.880, 0.860, 0.020, 'none', 0, gold,  2.0);
    I(end+1) = tablet(H.ax, 0.072, 0.090, 0.856, 0.820, 0.015, 'none', 0, goldD, 0.8);
    I(end+1) = text(H.ax, 0.5, 0.835, 'THE TEMPLE OF NUMBERS', 'Color', gold, 'FontSize', 30, ...
        'FontWeight', 'bold', 'HorizontalAlignment', 'center', 'Interpreter', 'none');
    heads(end+1) = I(end);
    I(end+1) = line(H.ax, [0.22 0.46], [0.775 0.775], 'Color', goldD, 'LineWidth', 1.1);
    I(end+1) = line(H.ax, [0.54 0.78], [0.775 0.775], 'Color', goldD, 'LineWidth', 1.1);
    I(end+1) = diamond(H.ax, 0.5, 0.775, 0.012, 0.022, gold, gold);
    I(end+1) = text(H.ax, 0.5, 0.740, 'A Tale of Numbers and Stone', 'Color', [0.88 0.80 0.64], ...
        'FontSize', 13, 'FontAngle', 'italic', 'HorizontalAlignment', 'center', 'Interpreter', 'none');
    heads(end+1) = I(end);
    H.introBody = text(H.ax, 0.5, 0.680, '', 'Color', [0.94 0.92 0.86], 'FontSize', 14, ...
        'HorizontalAlignment', 'center', 'VerticalAlignment', 'top', 'Interpreter', 'none');
    heads(end+1) = H.introBody;
    H.introHint = text(H.ax, 0.5, 0.130, 'Press Enter to begin your journey', 'Color', cyan, ...
        'FontSize', 13, 'FontWeight', 'bold', 'HorizontalAlignment', 'center', 'Interpreter', 'none');
    H.intro = [I, H.introBody, H.introHint];
    set(H.intro, 'Visible', 'off');

    %% 10. Typography
    try
        fonts = listfonts;
        body  = pickfont(fonts, {'Segoe UI', 'Helvetica Neue', 'Helvetica', 'Arial'});
        fancy = pickfont(fonts, {'Palatino Linotype', 'Georgia', 'Cambria', 'Book Antiqua', 'Times New Roman'});
        t = findall(H.ax, 'Type', 'text');
        if ~isempty(body),  set(t, 'FontName', body); end
        if ~isempty(fancy), set(heads(ishandle(heads)), 'FontName', fancy); end
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