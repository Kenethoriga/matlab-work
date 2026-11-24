function c = dotchar()
% DOTCHAR  The small centred dot used as a separator in the on-screen text.
% (Octave cannot show it, so there it falls back to a plain star.)
% Authors: <add group member names>
if exist('OCTAVE_VERSION', 'builtin')
    c = '*';
else
    c = char(183);
end
end
