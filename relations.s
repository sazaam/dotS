# Relationships
# $a > $b  means a depends on b
# $a < $b  means a is used by b
# $a ! $b  means a conflicts with b
# $a ~ $b  means a is related to b
$ffmpeg ~ $blender-python  # ffmpeg DSP feeds VSE timeline assembly
$rust ~ $python            # same conceptual spacing (collections, strings)
$rust ~ $node              # systems adjacent to JS runtimes
$rust ~ $javascript        # languages, syntax differ
$rust ~ $ponytail          # YAGNI discipline applies to Rust design
$blender-addon ~ $blender-python  # addon authoring leans on bpy API knowledge
$server-setup ~ $ssh              # hardening mix - ssh lockdown + key discipline feed server-setup
$server-setup ~ $linux            # same box, admin ground truth
$server-setup ~ $nginx            # deploy pipelines share the security posture
$terminal-tui ~ $sh               # shell/tty discipline underpins TUI work
$terminal-tui ~ $server-setup     # terminal-first admins operate hardened boxes
