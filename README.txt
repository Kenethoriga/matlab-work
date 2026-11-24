================================================================================
MATH TEMPLE RUN — Milestone 2 Prototype
SCS3301 Computer Graphics, University of Nairobi
Authors: <add group member names>
================================================================================

HOW TO RUN (MATLAB — no toolboxes required)
--------------------------------------------------------------------------------
1. Open MATLAB and set the Current Folder to this project directory.
2. Run:
       run_project
3. Walk Amani toward the gate/sign, type the answer to the riddle, and press Enter.

Optional launch modes:
  - Lightweight mode (slower PCs; coarser rock, no halos/embers):
        run_project('lite')
  - Automated Milestone 2 screenshots (saved to the screenshots/ folder):
        run_project('shots')

WINDOW SIZE
--------------------------------------------------------------------------------
Default window size is 960 x 540 pixels. To change it, edit W and Hgt near the
top of run_project.m.

CONTROLS
--------------------------------------------------------------------------------
  W A S D / Arrow Keys   Walk the explorer (camera follows smoothly)
  0-9 and -              Type your numeric answer
  Backspace              Delete last character
  Enter                  Skip/start intro, or submit your answer
  R                      Generate a new riddle and reset the gate
  V                      Cycle camera view:
                           1. Follow (perspective)
                           2. Top map (orthographic)
                           3. Side view (orthographic)
  P                      Save a snapshot
  Esc                    Quit the game

MILESTONE 2 CHECKLIST (What the Prototype Demonstrates)
--------------------------------------------------------------------------------
  1. 3D Scene Modelling (build_scene.m)
     Built entirely from patch / surf primitives (prim_*.m) and MATLAB light():
     - Rough procedural rock corridor & ceiling (rock_noise.m) with warm-torch
       vs. cool-shadow color grading (bake_color.m).
     - Stone tiled floor with a royal crimson runner carpet and woven gold trim.
     - Carved cylindrical temple columns with stepped plinths, gold rings, and
       layered capitals, plus overhead stone beams and bronze torch sconces.
     - Monumental wooden & iron double gate with a stepped lintel, gilded
       keystone, gold-bezel glowing crimson rune, recessed door panels, and
       gold studs.
     - Floating cyan rune crystal, flickering multi-layer torch flames,
       drifting embers, and a glowing portal beyond the gate.

  2. Custom 4x4 Transformation Matrices (mtx_*.m)
     All transforms use our own homogeneous matrices (mtx_translate, mtx_scale,
     mtx_rotx, mtx_roty, mtx_rotz, mtx_apply) — no makehgtform or hgtransform.
     Used to animate flames, the floating crystal, the explorer's limbs, and
     the temple gate.

  3. Articulated Explorer Character (Amani)
     Hierarchical body rig (body -> thigh -> shin; body -> upper arm -> forearm)
     with bending knees and elbows, walking animation, and collision against
     the closed gate. Styled with a royal teal tunic, crimson scarf, leather
     belt with gold buckle, cross-body strap, feathered explorer hat, leather
     backpack with gold clasps and bedroll, and cuffed boots/gloves.

  4. 3-Level Transform Hierarchy (update_scene.m)
     The temple gate uses:   world = M_gate * M_leaf * M_bolt
       - Level 1: Gate frame placed in the corridor.
       - Level 2: Door leaves pivoting around their hinges: T(h) * Rz(a) * T(-h).
       - Level 3: Sliding iron/gold bolts moving with each door leaf.

  5. Working Interactive Control & Feedback
     Typing an answer and pressing Enter checks the riddle:
       - Correct: bolt slides back, gate leaves swing open, seal turns green,
         "THE SEAL IS BROKEN!" banner appears, and Amani can walk through.
       - Wrong: warning message appears, gate rattles, and a step-by-step
         hint unlocks after two misses.

  6. Cameras & Randomization
     Switchable perspective and orthographic cameras (V key) and randomized
     vector dot-product riddles every run (puzzle_new.m).

STORY
--------------------------------------------------------------------------------
In "The Temple of Numbers," you play as Amani, an explorer following a torch-lit
corridor in search of the Crystal of Zero. An animated opening screen introduces
the tale (press Enter to skip typing and begin). Each chamber is sealed by a
named gate with a whispered math riddle. Chamber I is The Gate of Direction
(Vectors); Chambers II–IV (Determinants, Transformations, and the Hidden Vault)
are planned for the final submission.

USER INTERFACE (hud_create.m, hud_update.m)
--------------------------------------------------------------------------------
Carved-gold & dark-stone temple HUD:
  - Soft screen vignette, gold corner brackets, and top/bottom gold trim bars.
  - Title bar with drop shadow, active chamber name, quest prompt, GLORY score
    (500 per riddle, -50 per miss, minimum 100), attempts counter, and timer.
  - Four Roman-numeral diamond seals (I–IV); the active seal pulses gold and
    turns emerald green when broken.
  - Ancient gradient stone-tablet riddle card on the left with a recessed
    cyan-trimmed answer input slot (the duplicate right-side 3D board is hidden
    to keep the view uncluttered).
  - Centered carved-gold bottom control bar with diamond accents.
  - dotchar.m provides the centred dot separator (falls back to '*' in Octave).

PERFORMANCE OPTIMIZATION
--------------------------------------------------------------------------------
  - Static geometry is merged into single patches (mesh_add.m, mesh_patch.m)
    to minimize MATLAB draw calls.
  - Vectorized vertex math (bake_color.m, mtx_apply.m) avoids unnecessary
    array allocations.
  - Dirty-checked HUD updates (hud_update.m) only touch graphics properties
    when values actually change, keeping animation smooth up to 60 FPS.

PROJECT FILES
--------------------------------------------------------------------------------
  run_project.m               Main entry point (game loop, input, screenshots)
  build_scene.m               Builds corridor, columns, gate, crystal & explorer
  update_scene.m              Per-frame animation & 3-level gate transforms
  view_set.m                  Perspective & orthographic camera setups
  hud_create.m / hud_update.m Carved-gold temple HUD & stone riddle tablet
  puzzle_new.m                Random vector dot-product puzzle generator
  bake_color.m, rock_noise.m  Procedural cave geometry & warm/cool lighting
  mtx_*.m                     Custom 4x4 homogeneous transform matrices
  prim_*.m                    3D primitives (box, cylinder, sphere, capsule,
                              crystal, surface of revolution)
  mesh_add.m, mesh_patch.m    Mesh merging and patch rendering helpers
  dotchar.m                   Cross-platform separator character helper

PLANNED FOR FINAL SUBMISSION (Beyond M2)
--------------------------------------------------------------------------------
  - Chambers II, III, and IV (Determinants, Transformations, and Hidden Vault)
  - Background ambient temple music & sound effects
  - Additional on-screen control
  - 60-second VideoWriter showcase recording

AI & EXTERNAL ASSISTANCE DISCLOSURE
--------------------------------------------------------------------------------
Parts of this prototype (code refactoring, visual polish, and UI refinement)
were developed with assistance from AI tools. This will be acknowledged in the
final report, and every group member can explain their respective modules.