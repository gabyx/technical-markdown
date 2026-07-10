$warnings_as_errors = 'false';
$xelatex = 'xelatex -interaction=nonstopmode -shell-escape';
$pdf_mode = 5; # 5 = xelatex

# Never scatter build byproducts (.aux/.log/.fls/.fdb_latexmk/.pdf) next to the
# sources. Default everything into the gitignored `.output` dir. The build
# (`tools/scripts/build.nu`) overrides both with `-outdir`/`-auxdir` so its
# artifacts land under `.output/build/techmd/output-tex`.
$out_dir = '.output/manual';
$aux_dir = '.output/manual';
