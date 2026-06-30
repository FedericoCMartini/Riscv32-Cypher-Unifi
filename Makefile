SHELL=/bin/bash

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

# 1 is all m4_commands. 2 is for flags
invoke_m4=echo -n $(1) | m4 -P $(if $2,$2 )-

m4_trace="m4_traceon(\`$1')"


m4_dump="m4_dumpdef(\`$1')"

READ_MACROS_COMMAND=read -p "Macros you want to trace: " macros && echo -n $$macros

define m4_divert_call=
$(call invoke_m4,$(1) "m4_divert(-1)",$(2)) $(4) <(echo "m4_divert" $(3))
endef

define trace_macros=
$(let args, $(shell $(READ_MACROS_COMMAND)),$\
	$(call m4_divert_call,$\
		$(M4_PROLOGUE)\
		$(M4_DEBUG)\
		$(foreach macro,$(args),$(call m4_trace,$(macro))),$\
		,\
		$(foreach macro,$(args),$(call m4_dump,$(macro))),$\
		$1$\
	)$(newline)$\
	$(foreach macro,$(args),grep -n $(macro) $1$(newline))$\
)
endef

M4_DEBUG_FLAGS=-daceflqt

M4_PROLOGUE="m4_changecom(\`/*', \`*/')"
M4_COMBINE="m4_define(COMBINE, 1)"
M4_DEBUG="m4_debugfile"
M4_TRACE="m4_traceon"

COMBINE_MACROS=$(M4_PROLOGUE) $(M4_COMBINE)

REPLACE_SCRIPT=$(call invoke_m4, $(M4_PROLOGUE),)

COMBINE_SCRIPT=$(call invoke_m4,$(COMBINE_MACROS),)

all: $(NAME)

$(ASM_DIR)/$(NAME)$(ASM_PATTERN): $(SRC_DIR)/$(NAME)$(SRC_PATTERN) $(SRC_DIR)/$(SIDE)$(SRC_PATTERN) | $(ASM_DIR)
	$(COMBINE_SCRIPT) $^ > $@


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



debug_m4_%: $(SRC_DIR)/%$(SRC_PATTERN)
	$(call invoke_m4, $(M4_PROLOGUE) $(M4_DEBUG), $(M4_DEBUG_FLAGS)) $< > /dev/null

trace_macro_%: $(SRC_DIR)/%$(SRC_PATTERN)

	$(call trace_macros, $<) 

testcompile_%: $(BIN_DIR)/%  ;
	
testcompile:
	make -is --no-print-directory testcompile_$(NAME) testcompile_$(SIDE)

test: testcompile

.PHONY: fclean binclean dirclean clean all diff test testcompile $(NAME) $(SIDE) %$(ASM_PATTERN) debug_m4_% trace_macro_%

#.PRECIOUS: $(ASM_DIR)/%$(ASM_PATTERN)

.IGNORE: testcompile testcompile_$(NAME) testcompile_$(SIDE) debug_m4_$(NAME) 

blank:=
define newline

$(blank)
endef