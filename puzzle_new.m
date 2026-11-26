function P = puzzle_new(chamber)
% PUZZLE_NEW  Generate a randomized math riddle for Chamber I (Vectors),
%             Chamber II (2x2 Determinants), or Chamber III (The Void: det = 0).
    if nargin < 1, chamber = 1; end

    if chamber == 3
        % Medium mental-math Void puzzle: find x so det(M) = 0 (always a clean integer)
        k = randi([2, 4]);
        a = randi([2, 5]);
        b = a * k;
        c = randi([2, 5]);
        ansVal = c * k;

        P.title   = 'CHAMBER III: THE VOID';
        P.place   = 'The Astral Gate';
        P.topic   = 'Singularity (det = 0)';
        P.whisper = '"Balance the diagonals to collapse space to zero."';
        P.line1   = sprintf('M = [ %2d,  %2d ]', a, b);
        P.line2   = sprintf('    [ %2d,   x ]', c);
        P.ask     = 'Find x so  det(M) = 0';
        P.prefix  = 'x =  ';
        P.ans     = ansVal;
        P.answer  = P.ans;
        P.hint    = sprintf('Hint: %d*x = %d*%d, so x = %d / %d', a, b, c, b * c, a);

    elseif chamber == 2
        a = randi([-6, 6]); b = randi([-6, 6]);
        c = randi([-6, 6]); d = randi([-6, 6]);
        while (a*d - b*c) == 0
            a = randi([-6, 6]); d = randi([-6, 6]);
        end
        P.title   = 'CHAMBER II: DETERMINANTS';
        P.place   = 'The Inferno Gate';
        P.topic   = '2x2 Determinants';
        P.whisper = '"Cross the diagonals of fire, then take their difference."';
        P.line1   = sprintf('M = [ %2d,  %2d ]', a, b);
        P.line2   = sprintf('    [ %2d,  %2d ]', c, d);
        P.ask     = 'Find the determinant  det(M)';
        P.prefix  = 'det(M) =  ';
        P.ans     = a * d - b * c;
        P.answer  = P.ans;
        P.hint    = sprintf('Hint: det(M) = (%d*%d) - (%d*%d)', a, d, b, c);

    else
        A = randi([-6, 6], 1, 3);
        B = randi([-6, 6], 1, 3);
        P.title   = 'CHAMBER I: VECTORS';
        P.place   = 'The Gate of Direction';
        P.topic   = 'Vectors';
        P.whisper = '"Multiply what matches, add what is left."';
        P.line1   = sprintf('A = (%d, %d, %d)', A(1), A(2), A(3));
        P.line2   = sprintf('B = (%d, %d, %d)', B(1), B(2), B(3));
        P.ask     = 'Find the dot product  A . B';
        P.prefix  = 'A . B =  ';
        P.ans     = dot(A, B);
        P.answer  = P.ans;
        P.hint    = sprintf('Hint: (%d*%d) + (%d*%d) + (%d*%d)', ...
            A(1), B(1), A(2), B(2), A(3), B(3));
    end
end