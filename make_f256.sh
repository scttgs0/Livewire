
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


64tass  --m65c02 \
        --flat \
        --nostart \
        -D PGX=0 \
        -o obj/livewire.bin \
        --list=obj/livewireB.lst \
        --labels=obj/livewireB.lbl \
        livewire.asm
