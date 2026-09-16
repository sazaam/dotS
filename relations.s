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
