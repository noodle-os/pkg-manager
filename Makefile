SCRIPT = src/noodle.sh
C-SCRIPT = src/noodle.sh.x.c
BIN = noodle
DIR = bin

.PHONY: all clean

all: $(BIN)

$(BIN): $(SCRIPT)
	mkdir -p $(DIR)
	shc -f $(SCRIPT) -o $(DIR)/$(BIN)
	rm $(C-SCRIPT)
	@echo "Binary built successfully at $(DIR)/$(BIN)."

clean:
	rm -rf $(DIR)
	@echo "Cleaned up build files."