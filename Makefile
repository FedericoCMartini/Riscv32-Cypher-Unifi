SRC=Cifrario.m4

SIDE=alloc.m4

SRC_PATTERN=.m4

RIPES_PATTERN=.s

NAME=$(SRC:%$(SRC_PATTERN)=%$(RIPES_PATTERN))

SIDE_NAME=$(SIDE:%$(SRC_PATTERN)=%$(RIPES_PATTERN))

COMPILED=$(NAME:%$(RIPES_PATTERN)=%)

SIDE_COMPILED=$(SIDE_NAME:%$(RIPES_PATTERN)=%)

REPLACE_SCRIPT=m4 -P macro_replace.m4

all: $(NAME)


%$(RIPES_PATTERN): %$(SRC_PATTERN)
	$(REPLACE_SCRIPT) $^ > $@ 


%: %.s	
	riscv64-linux-gnu-gcc -mabi="ilp32" -march="rv32im" -nostdlib -static $^ -o $@

diff:
ifneq ("$(wildcard $(NAME))","")
	${REPLACE_SCRIPT} ${SRC} | diff - ${NAME}
else
	@echo no $(NAME) file found
endif

ifneq ("$(wildcard $(SIDE_NAME))","")
	${REPLACE_SCRIPT} ${SIDE} | diff - ${SIDE_NAME}
else
	@echo no $(SIDE_NAME) file found
endif


clean:
	rm -rf $(NAME)
	rm -rf $(SIDE_NAME)

binclean:
	rm -rf $(COMPILED)
	rm -rf $(SIDE_COMPILED)

fclean: clean binclean

.PHONY: fclean binclean clean all diff