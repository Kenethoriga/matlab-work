function P = puzzle_new(chamber)
% PUZZLE_NEW  Generate a randomized math riddle for Chamber 1 (Vectors)
%             or Chamber 2 (2x2 Matrix Determinant).
    if nargin < 1, chamber = 1; end

    if chamber == 2
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