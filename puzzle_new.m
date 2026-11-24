function P = puzzle_new()
% PUZZLE_NEW  Make a new random chamber-1 puzzle (vectors: dot product).
% The numbers are random each time, so the answer is different every run.
% Authors: <add group member names>
a = randi([-4 6], 1, 3);
b = randi([-4 6], 1, 3);
P.answer = sum(a .* b);
P.title  = 'CHAMBER I : VECTORS';
P.place  = 'The Gate of Direction';
P.whisper = '"Multiply what matches, add what is left."';
P.line1  = sprintf('A = (%d, %d, %d)', a);
P.line2  = sprintf('B = (%d, %d, %d)', b);
P.ask    = 'A . B = ?';
P.hint   = sprintf('Hint: multiply matching parts, then add:  (%d)(%d) + (%d)(%d) + (%d)(%d)', ...
    a(1), b(1), a(2), b(2), a(3), b(3));
end
