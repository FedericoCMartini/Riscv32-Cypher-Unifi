SHELL=/bin/sh

SRC_PATTERN=.m4
ASM_PATTERN=.s

NAME=Cifrario
SIDE=alloc

BINARIES=$(NAME) $(SIDE)
ASM_DIR=./asm
SRC_DIR=./src
BIN_DIR=./bin

OPT_DIR=$(ASM_DIR) $(BIN_DIR)





define source_diff=
${REPLACE_SCRIPT} ${1:$(ASM_DIR)%${ASM_PATTERN}=$(SRC_DIR)%${SRC_PATTERN}} | diff - ${1}

endef

M4_PROLOGUE="m4_changecom(\`/*', \`*/')"
M4_COMBINE="m4_define(COMBINE, 1)"

REPLACE_SCRIPT=echo -n $(M4_PROLOGUE) | m4 -P -

all: $(NAME)

$(ASM_DIR)/$(NAME)$(ASM_PATTERN): $(SRC_DIR)/$(NAME)$(SRC_PATTERN) $(SRC_DIR)/$(SIDE)$(SRC_PATTERN) | $(ASM_DIR)
	echo -n $(M4_PROLOGUE) $(M4_COMBINE) | m4 -P - $^ > $@


#redirects asm to asm_dir
$(BINARIES:%=%$(ASM_PATTERN)): %$(ASM_PATTERN):
	@make --no-print-directory $(ASM_DIR)/$*$(ASM_PATTERN)

$(ASM_DIR)/%$(ASM_PATTERN): $(SRC_DIR)/%$(SRC_PATTERN) | $(ASM_DIR)
	$(REPLACE_SCRIPT) $^ > $@ 

$(OPT_DIR): %:
	mkdir $@

#redirects binary to bin_dir
$(BINARIES): % :
	@make --no-print-directory $(BIN_DIR)/$* 

$(BIN_DIR)/% : $(ASM_DIR)/%$(ASM_PATTERN) | $(BIN_DIR)
	riscv64-linux-gnu-gcc -mabi="ilp32" -march="rv32im" -nostdlib -static $^ -o $@

diff:
	$(foreach asm, $(wildcard $(ASM_DIR)/*$(ASM_PATTERN)), $(call source_diff,$(asm)))

clean:
	rm -rf $(BINARIES:%=$(ASM_DIR)/%${ASM_PATTERN})

binclean:
	rm -rf $(addprefix $(BIN_DIR)/, $(BINARIES))

dirclean:
	$(foreach dir, $(filter $(wildcard ./*), $(OPT_DIR)), \
	$(shell rm -d $(dir)))

fclean: clean binclean dirclean


testcompile_%: $(BIN_DIR)/%  ;
	
testcompile:
	make -is --no-print-directory testcompile_$(NAME) testcompile_$(SIDE)

test: testcompile

.PHONY: fclean binclean dirclean clean all diff test testcompile $(NAME) $(SIDE) %$(ASM_PATTERN)

#.PRECIOUS: $(ASM_DIR)/%$(ASM_PATTERN)

.IGNORE: testcompile testcompile_$(NAME) testcompile_$(SIDE)