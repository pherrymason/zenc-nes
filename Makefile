# The Zen C compiler: `zc` from PATH, or make ZC=/path/to/zc
ZC      ?= zc
ZCFLAGS ?= -w

# C libraries: header and link paths (raylib from Homebrew)
LIBS := $(shell pkg-config --cflags --libs raylib)

BUILD := build
BIN   := $(BUILD)/zen-nes
SRCS  := $(wildcard src/*.zc src/*/*.zc)
TESTS := $(wildcard tests/*_test.zc)

# Arguments for the emulator: make run ARGS="-rom game.nes -scale 2"
ARGS ?=

.PHONY: all build run test clean

all: build

build: $(BIN)

$(BIN): $(SRCS)
	@mkdir -p $(BUILD)
	$(ZC) build $(ZCFLAGS) $(LIBS) src/main.zc -o $@

run: $(BIN)
	./$(BIN) $(ARGS)

test:
	@mkdir -p $(BUILD)
	@set -e; for t in $(TESTS); do \
		$(ZC) run $(ZCFLAGS) $(LIBS) $$t -o $(BUILD)/$$(basename $$t .zc); \
	done

clean:
	rm -rf $(BUILD)
