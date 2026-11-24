function view_set(ax, S, v, G)
% VIEW_SET  Choose one of three cameras.
%   1 = follow camera behind the explorer, perspective
%   2 = top-down map view, orthographic
%   3 = side view, orthographic
% Authors: <add group member names>
switch v
    case 1
        set(ax, 'CameraViewAngleMode', 'manual');
        set(ax, 'Projection', 'perspective');
        campos(ax, [G.camx, G.camy, 3.4]);
        camtarget(ax, [G.camx, G.camy + 14.5, 1.8]);
        camup(ax, [0 0 1]);
        camva(ax, 58);
    case 2
        set(ax, 'Projection', 'orthographic');
        campos(ax, [0, 6.5, 60]);
        camtarget(ax, [0, 6.5, 0]);
        camup(ax, [0 1 0]);
        set(ax, 'CameraViewAngleMode', 'auto');
    case 3
        set(ax, 'Projection', 'orthographic');
        campos(ax, [60, 6.5, 3]);
        camtarget(ax, [0, 6.5, 3]);
        camup(ax, [0 0 1]);
        set(ax, 'CameraViewAngleMode', 'auto');
end
vis = {'off', 'on'};
set(S.ceil,  'Visible', vis{(v == 1) + 1});   % hide the ceiling in the map views
set(S.wallR, 'Visible', vis{(v ~= 3) + 1});   % hide the near wall in the side view
end
