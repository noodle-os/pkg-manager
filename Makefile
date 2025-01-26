SCRIPT = src/noodle.sh
BIN = noodle
DIR = build

.PHONY: all clean

all: $(BIN)

$(BIN): $(SCRIPT)
	mkdir -p $(DIR)
	shc -f $(SCRIPT) -o $(DIR)/$(BIN)
	@echo "Binary built successfully at $(DIR)/$(BIN)."

clean:
	rm -rf $(DIR)
	@echo "Cleaned up build files."