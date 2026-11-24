MATH TEMPLE RUN - Milestone 2 prototype
SCS3301 Computer Graphics, University of Nairobi
Authors: <add group member names>

HOW TO RUN (MATLAB, no toolboxes needed)
  1. Open MATLAB and set the Current Folder to this folder.
  2. Type:   run_project
  3. Type the answer to the puzzle on the board and press Enter.
  Slow computer?   run_project('lite')   (coarser rock, no glow or embers)
  To save the six M2 screenshots automatically:   run_project('shots')
  (they are written to the screenshots folder)

WINDOW SIZE
  The game window is 960 x 540 pixels. To change it, edit W and Hgt near the top of run_project.m.

CONTROLS
  Arrows or WASD   walk the explorer (the camera follows). It walks freely until it
                   reaches the sign, then stops. Type the answer to go on.
  0-9 and -        type your answer        Backspace  delete
  Enter            check the answer        R          new puzzle, gate closes
  V                switch camera (player/perspective, top/orthographic, side/orthographic)
  P                save a screenshot       Esc        quit

WHAT THE PROTOTYPE SHOWS (Milestone 2 checklist)
  Scene modelled         build_scene.m: rock corridor, floor tiles, beams, six torches,
                         wooden double gate, puzzle board, floating crystal.
                         Built from patch / surf primitives (prim_*.m) and light().
  Own matrices           mtx_translate, mtx_scale, mtx_rotx, mtx_roty, mtx_rotz, mtx_apply.
                         They move the flames (scale), the crystal (rotate + translate)
                         and the whole gate. No makehgtform or hgtransform is used.
  Moving character       an explorer you walk with the arrow keys or WASD. Body is the root;
                         arms and legs swing about the shoulders and hips (same hierarchy idea).
                         The closed gate blocks the way, an open gate lets you walk through.
  3-level hierarchy      update_scene.m:  world = M_gate * M_leaf * M_bolt
                           level 1  gate frame, placed in the corridor
                           level 2  door leaf, turns about its hinge: T(h) * Rz(a) * T(-h)
                           level 3  bolt, slides along the leaf (moves with the leaf)
  One working control    typing the answer + Enter. Right answer: the bolt slides back, the
                         leaves swing open, the camera moves through. Wrong answer: red
                         message, the gate rattles, hint after two misses.
  Also already in        perspective and orthographic cameras (V key), puzzle numbers are
                         random each run.

STORY
  The Temple of Numbers: you play Amani, an explorer chasing the Crystal of Zero through
  chambers sealed by gates that open only for the right answer. An opening screen tells
  the story (Enter skips the typing, then starts). Each gate has a name and a whispered
  riddle on the puzzle card. Chamber 1 is The Gate of Direction (vectors); chamber 2, the
  Hall of Determinants, and chamber 3 come in the final version.

INTERFACE
  Carved-gold temple style: corner frames, a ribbon title bar, four Roman-numeral seals,
  GLORY (score), attempts and time, a quest line, a riddle card at the sign with the
  answer box, message banners, a "seal broken" banner and a key guide. Glory: 500 per
  riddle, minus 50 for each wrong answer (minimum 100). dotchar.m supplies the small dot
  separator (Octave falls back to a star).

SPEED AND LOOK
  Shapes are merged into a few big patches (mesh_add.m, mesh_patch.m), only the parts
  that moved are redrawn, and the loop runs up to 60 frames per second. The explorer has
  bending knees and elbows (body -> thigh -> shin, upper arm -> forearm), the camera
  glides after it, and the scene has a red carpet, stone blocks, rivets, glowing flames,
  drifting embers, a soft shadow and a dark vignette.

FILES
  run_project.m   main script (game loop, keys, screenshots)
  build_scene.m   models the scene          update_scene.m  moves it every frame
  view_set.m      the three cameras         hud_create.m / hud_update.m   on-screen interface (top bar, puzzle card, banners, key guide)
  puzzle_new.m    random vector puzzle      bake_color.m, rock_noise.m  look of the cave
  mtx_*.m         our own 4x4 matrices      prim_*.m        box, cylinder, sphere, capsule, crystal;  mesh_*.m  merge shapes

STILL TO DO FOR THE FINAL (not expected at M2)
  Chambers 2 and 3 with their own gates, determinant and transformation puzzles, the
  challenge-mode chamber, the 60 s VideoWriter video, a second on-screen control.

AI AND EXTERNAL CODE
  This prototype was written with help from an AI assistant (Claude). We will mark that
  in the final report, and every member must be able to explain their own part.
