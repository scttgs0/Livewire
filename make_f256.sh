
mkdir -p obj/

# -------------------------------------

64tass  --m65c02 \
        --flat \
        --nostart \
        -D PGX=1 \
        -o obj/livewire.pgx \
        --list=obj/livewire.lst \
        --labels=obj/livewire.lbl \
        livewire.asm
