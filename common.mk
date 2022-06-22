################################################################################
#
#    GNU Make makefile for cross-compile and Test driven development in C for
#    dual-targeted environments
#
#    Maintainer: Elias Kanelis (hkanelhs@yahoo.gr)
#    License:    MIT
#

################################################################################
#	  _______          _             _     _
#	 |__   __|        | |           (_)   | |
#	    | | ___   ___ | |   _____  ___ ___| |_ ___
#	    | |/ _ \ / _ \| |  / _ \ \/ / / __| __/ __|
#	    | | (_) | (_) | | |  __/>  <| \__ \ |_\__ \
#	    |_|\___/ \___/|_|  \___/_/\_\_|___/\__|___/
#
#

GCC_EXISTS :=            $(shell command -v gcc 2> /dev/null)
GPP_EXISTS :=            $(shell command -v g++ 2> /dev/null)
GDB_EXISTS :=            $(shell command -v gdb 2> /dev/null)
VALGRIND_EXISTS :=       $(shell command -v valgrind 2> /dev/null)
SED_EXISTS :=            $(shell command -v sed 2> /dev/null)
PERL_EXISTS :=           $(shell command -v perl 2> /dev/null)
GIT_EXISTS :=            $(shell command -v git 2> /dev/null)
DOXYGEN_EXISTS :=        $(shell command -v doxygen 2> /dev/null)
DOT_EXISTS :=            $(shell command -v dot 2> /dev/null)
JLINK_EXISTS :=          $(shell command -v JLinkExe 2> /dev/null)
SALEAE_EXISTS :=         $(shell command -v Saleae 2> /dev/null)
PICOCOM_EXISTS :=        $(shell command -v picocom 2> /dev/null)
FIREFOX_EXISTS :=        $(shell command -v firefox 2> /dev/null)
FLINT_EXISTS :=          $(shell command -v flint 2> /dev/null)

# Check cppUtest path
ifeq ($(CPPUTEST_DIR),)
  $(error 'CPPUTEST_DIR' is not specified)
endif

# We need sed, check if it exists
ifndef SED_EXISTS
	$(error "Please install 'sed' scripting language!")
endif

################################################################################
#	  _____           _           _
#	 |  __ \         (_)         | |
#	 | |__) | __ ___  _  ___  ___| |_
#	 |  ___/ '__/ _ \| |/ _ \/ __| __|
#	 | |   | | | (_) | |  __/ (__| |_
#	 |_|   |_|  \___/| |\___|\___|\__|
#	                _/ |
#	               |__/
#

# Name of the build output
ifeq ($(EXEC),)
  $(error "EXEC" is not specified)
endif

# Build configuration options
CONF ?=                  dbg
ifneq ($(CONF),dbg)
  ifneq ($(CONF),rel)
    $(error "CONF" variable can not be "$(CONF)")
  endif
endif

# Project version
ifdef GIT_EXISTS
  PROJECT_NUMBER ?=      $(shell git describe --always \
                         --dirty=" (with uncommitted changes)" --long --tags)
endif

#..............................................................................#
# Machine

ifdef SYSTEMROOT
  MACHINE =              win32
  $(error Windows compatibility is not verified)
else
  ifeq ($(shell uname), Linux)
    MACHINE =            posix
  else
    $(error Makefile does not support this OS)
  endif
endif

#..............................................................................#
# Directories

BIN_DIR ?=               bin/
OBJ_DIR ?=               obj/
INC_DIR ?=               inc/
SRC_DIR ?=               src/
DOC_DIR ?=               doc/
TMP_DIR ?=               tmp/
LIB_DIR ?=               lib/
PORT_DIR ?=              port/

HOST_DIR ?=              $(MACHINE)_$(CONF)/

################################################################################
#	 _____           _
#	|_   _|__   ___ | |___
#	  | |/ _ \ / _ \| / __|
#	  | | (_) | (_) | \__ \
#	  |_|\___/ \___/|_|___/
#
#

#..............................................................................#
# Host toolchain
CC_HOST ?=               gcc
CXX_HOST ?=              g++
AS_HOST ?=               gcc -x assembler-with-cpp
CP_HOST ?=               objcopy
AR_HOST ?=               ar
SZ_HOST ?=               size
HEX_HOST ?=              objcopy -O ihex
BIN_HOST ?=              objcopy -O binary -S

#..............................................................................#
# Tools

ECHO ?=                  echo
ECHO_N ?=                echo -n
MKDIR_P ?=               @mkdir -p
RM_FR ?=                 @rm -fR
MV_F ?=                  @mv -f
TOUCH ?=                 touch
SED ?=                   sed
FLINT ?=                 flint

################################################################################
#	 _    _ _   _ _ _ _   _
#	| |  | | | (_) (_) | (_)
#	| |  | | |_ _| |_| |_ _  ___  ___
#	| |  | | __| | | | __| |/ _ \/ __|
#	| |__| | |_| | | | |_| |  __/\__ \
#	 \____/ \__|_|_|_|\__|_|\___||___/
#
#

COLORS ?= YES
ifneq ($(COLORS),YES)
  ifneq ($(COLORS),NO)
    $(error "COLORS" variable can not be "$(COLORS)")
  endif
endif

ifeq ($(COLORS),NO)

  # Messages
  BUILD_SUCCESS ?=       @$(ECHO) "\tBuild successful"
  FLASH ?=               @$(ECHO) "\tFlashing MCU"
  ERASE ?=               @$(ECHO) "\tErasing MCU"
  CLEANING ?=            @$(ECHO) "\tCleaning project\t"

  COMPILING ?=           @$(ECHO) "\tCompiling $<\t"
  BUILDING ?=            @$(ECHO) "\tBuilding  $@\t"
  RUNNING ?=             @$(ECHO) "\tRunning   $^"
  VERSION ?=             @$(ECHO) "\tVersion"
  DOCUMENTATION ?=       @$(ECHO) "\tDocumentation"


else

  # TPUT COLORS for Help function
  TPUT_GREEN =           $(shell tput -Txterm setaf 2)
  TPUT_WHITE =           $(shell tput -Txterm setaf 7)
  TPUT_YELLOW =          $(shell tput -Txterm setaf 3)
  TPUT_RESET =           $(shell tput -Txterm sgr0)


  RED =                  @tput bold && tput -Txterm setaf 1
  GREEN =                @tput bold && tput -Txterm setaf 2
  YELLOW =               @tput bold && tput -Txterm setaf 3
  BLUE =                 @tput bold && tput -Txterm setaf 4
  RESET =                tput -Txterm sgr0

  # Messages
  BUILD_SUCCESS ?=       $(GREEN)  && $(ECHO)   "\tBuild successful"    && $(RESET)
  FLASH ?=               $(YELLOW) && $(ECHO)   "\tFlashing MCU"        && $(RESET)
  ERASE ?=               $(RED)    && $(ECHO)   "\tErasing MCU"         && $(RESET)
  CLEANING ?=            $(RED)    && $(ECHO)   "\tCleaning project\t"  && $(RESET)

  COMPILING ?=           $(YELLOW) && $(ECHO_N) "\tCompiling"           && $(RESET) && $(ECHO) " $<\t"
  BUILDING ?=            $(YELLOW) && $(ECHO_N) "\tBuilding "           && $(RESET) && $(ECHO) " $@\t"
  RUNNING ?=             $(YELLOW) && $(ECHO_N) "\tRunning  "           && $(RESET) && $(ECHO) " $^"
  VERSION ?=             $(YELLOW) && $(ECHO)   "\tVersion"             && $(RESET)
  DOCUMENTATION ?=       $(YELLOW) && $(ECHO)   "\tDocumentation"       && $(RESET)

endif

#..............................................................................#

# Add the following 'help' target to your Makefile
# And add help text after each target name starting with '\#\#'
# A category can be added with @category
# Credits to: https://gist.github.com/prwhite/8168133
HELP_FUNC := \
        %help; \
        while(<>) { \
                if(/^([a-z0-9_-]+):.*\#\#(?:@(\w+))?\s(.*)$$/) { \
                        push(@{$$help{$$2}}, [$$1, $$3]); \
                } \
        }; \
        print "Usage: make $(TPUT_YELLOW)[target]$(TPUT_RESET)\n\n"; \
        for ( sort keys %help ) { \
                print "$(TPUT_WHITE)$$_:$(TPUT_RESET)\n"; \
                printf("  $(TPUT_YELLOW)%-20s$(TPUT_RESET) \
                        $(TPUT_GREEN)%s$(TPUT_RESET)\n", $$_->[0], \
                        $$_->[1]) for @{$$help{$$_}}; \
                print "\n"; \
        }

################################################################################
#	 _____                            _                 _
#	|  __ \                          | |               (_)
#	| |  | | ___ _ __   ___ _ __   __| | ___ _ __   ___ _  ___  ___
#	| |  | |/ _ \ '_ \ / _ \ '_ \ / _` |/ _ \ '_ \ / __| |/ _ \/ __|
#	| |__| |  __/ |_) |  __/ | | | (_| |  __/ | | | (__| |  __/\__ \
#	|_____/ \___| .__/ \___|_| |_|\__,_|\___|_| |_|\___|_|\___||___/
#	            | |
#	            |_|
#
#

# Auxiliary files that build depends on
AUX =                    Makefile common.mk

#..............................................................................#

# C++ source files
HOST_CXX_SRCs =          $(shell find $(SRC_DIR) ! -name "*main.cpp" -name "*.cpp")

HOST_CXX_SRCs +=         $(USER_HOST_CXX_SRCs)
HOST_CXX_SRCs +=         $(USER_CXX_SRCs)

# C source files
HOST_C_SRCs =            $(shell find $(SRC_DIR) ! -name "*main.c" -name "*.c")
HOST_C_SRCs +=           $(USER_HOST_C_SRCs)
HOST_C_SRCs +=           $(USER_C_SRCs)

# Assembly source files
HOST_AS_SRCs =           $(shell find $(SRC_DIR) ! -name "*main.s" -name "*.s")
HOST_AS_SRCs +=          $(USER_HOST_AS_SRCs)
HOST_AS_SRCs +=          $(USER_AS_SRCs)

# Main sources
HOST_CXX_MAIN =          $(shell find $(SRC_DIR) -name "*main.cpp")
HOST_C_MAIN =            $(shell find $(SRC_DIR) -name "*main.c")
HOST_AS_MAIN =           $(shell find $(SRC_DIR) -name "*main.s")

# Object files for main
HOST_OBJ_MAIN =          $(addprefix $(OBJ_DIR)$(HOST_DIR),$(HOST_CXX_MAIN:%.cpp=%.o))
HOST_OBJ_MAIN +=         $(addprefix $(OBJ_DIR)$(HOST_DIR),$(HOST_C_MAIN:%.c=%.o))
HOST_OBJ_MAIN +=         $(addprefix $(OBJ_DIR)$(HOST_DIR),$(HOST_AS_MAIN:%.s=%.o))

# Object files
HOST_OBJS =              $(addprefix $(OBJ_DIR)$(HOST_DIR),$(HOST_CXX_SRCs:%.cpp=%.o))
HOST_OBJS +=             $(addprefix $(OBJ_DIR)$(HOST_DIR),$(HOST_C_SRCs:%.c=%.o))
HOST_OBJS +=             $(addprefix $(OBJ_DIR)$(HOST_DIR),$(HOST_AS_SRCs:%.s=%.o))

#..............................................................................#

# C++ test source files
TEST_CXX_SRCs =          $(shell find $(TESTS_DIR) -name "*.cpp")
TEST_CXX_SRCs +=         $(USER_TEST_CXX_SRCs)
TEST_CXX_SRCs +=         $(HOST_CXX_SRCs)

# C source files
TEST_C_SRCs =            $(shell find $(TESTS_DIR) -name "*.c")
TEST_C_SRCs +=           $(USER_TEST_C_SRCs)
TEST_C_SRCs +=           $(HOST_C_SRCs)

# Assembly source files
TEST_AS_SRCs =           $(shell find $(TESTS_DIR) -name "*.s")
TEST_AS_SRCs +=          $(USER_TEST_AS_SRCs)
TEST_AS_SRCs +=          $(HOST_AS_SRCs)

# Test object files
TEST_OBJS =              $(addprefix $(OBJ_DIR)$(TESTS_DIR),$(TEST_CXX_SRCs:%.cpp=%.o))
TEST_OBJS +=             $(addprefix $(OBJ_DIR)$(TESTS_DIR),$(TEST_C_SRCs:%.c=%.o))
TEST_OBJS +=             $(addprefix $(OBJ_DIR)$(TESTS_DIR),$(TEST_AS_SRCs:%.s=%.o))

################################################################################
#	  ____              _____ _
#	 / ___| _     _    |  ___| | __ _  __ _ ___
#	| |   _| |_ _| |_  | |_  | |/ _` |/ _` / __|
#	| |__|_   _|_   _| |  _| | | (_| | (_| \__ \
#	 \____||_|   |_|   |_|   |_|\__,_|\__, |___/
#	                                  |___/
#

# Default compiler C++ flags
CXXFLAGS =               -std=c++98

#..............................................................................#
# Host C++ flags
HOST_CXXFLAGS =          $(CXXFLAGS)\
                         $(USER_HOST_CXXFLAGS)\
                         $(USER_CXXFLAGS)

#..............................................................................#
# Test C++ flags
TEST_CXXFLAGS =          -I"$(CPPUTEST_DIR)/include/"\
                         -I"$(CPPUTEST_DIR)/include/CppUTest/MemoryLeakDetectorNewMacros.h"

TEST_CXXFLAGS +=         $(CXXFLAGS)\
                         $(USER_TEST_CXXFLAGS)\
                         $(USER_CXXFLAGS)

################################################################################
#	  ____   _____ _
#	 / ___| |  ___| | __ _  __ _ ___
#	| |     | |_  | |/ _` |/ _` / __|
#	| |___  |  _| | | (_| | (_| \__ \
#	 \____| |_|   |_|\__,_|\__, |___/
#	                       |___/
#

# Default compiler C flags
CFLAGS =

#..............................................................................#
# Host C flags
HOST_CFLAGS =            -std=c99

HOST_CFLAGS +=           $(CFLAGS)\
                         $(USER_HOST_CFLAGS)\
                         $(USER_CFLAGS)

#..............................................................................#
# Test C flags
TEST_CFLAGS =            -std=gnu99

TEST_CFLAGS +=           -I"$(CPPUTEST_DIR)/include/"\
                         -I"$(CPPUTEST_DIR)/include/CppUTest/MemoryLeakDetectorMallocMacros.h"

TEST_CFLAGS +=           $(CFLAGS)\
                         $(USER_TEST_CFLAGS)\
                         $(USER_CFLAGS)

################################################################################
#	    _                           _     _             _____ _
#	   / \   ___ ___  ___ _ __ ___ | |__ | | ___ _ __  |  ___| | __ _  __ _ ___
#	  / _ \ / __/ __|/ _ \ '_ ` _ \| '_ \| |/ _ \ '__| | |_  | |/ _` |/ _` / __|
#	 / ___ \\__ \__ \  __/ | | | | | |_) | |  __/ |    |  _| | | (_| | (_| \__ \
#	/_/   \_\___/___/\___|_| |_| |_|_.__/|_|\___|_|    |_|   |_|\__,_|\__, |___/
#	                                                                  |___/
#

# Default assembler flags
ASFLAGS =

#..............................................................................#
# Host assembler flags
HOST_ASFLAGS =           $(ASFLAGS)\
                         $(USER_HOST_ASFLAGS)\
                         $(USER_ASFLAGS)

#..............................................................................#
# Test assembler flags
TEST_ASFLAGS =           $(ASFLAGS)\
                         $(USER_TEST_ASFLAGS)\
                         $(USER_ASFLAGS)

################################################################################
#	 ____                   __                _____ _
#	|  _ \ _ __ ___ _ __   / /__  ___  _ __  |  ___| | __ _  __ _ ___
#	| |_) | '__/ _ \ '_ \ / / __|/ _ \| '__| | |_  | |/ _` |/ _` / __|
#	|  __/| | |  __/ |_) / /\__ \ (_) | |    |  _| | | (_| | (_| \__ \
#	|_|   |_|  \___| .__/_/ |___/\___/|_|    |_|   |_|\__,_|\__, |___/
#	               |_|                                      |___/
#

# Warnings and error notification
CPPFLAGS =               -w\
                         -Wall\
                         -Werror\
                         -pedantic-errors

# Debug flags
ifeq ($(CONF),rel)
  # Optimization
  CPPFLAGS +=            -O3
  CPPFLAGS +=            -DNDEBUG
else
  # Debug flags
  CPPFLAGS +=            -g -gdwarf-2
  CPPFLAGS +=            -DDEBUG

  # Optimization
  CPPFLAGS +=            -Og
endif

# Compilation options
CPPFLAGS +=              -fdata-sections\
                         -ffunction-sections

#..............................................................................#
# Host compiler preprossesor flags
HOST_CPPFLAGS =          $(CPPFLAGS)\
                         $(USER_HOST_CPPFLAGS)\
                         $(USER_CPPFLAGS)

#..............................................................................#
# Test compiler preprossesor flags
TEST_CPPFLAGS =          $(CPPFLAGS)\
                         $(USER_TEST_CPPFLAGS)\
                         $(USER_CPPFLAGS)

################################################################################
#	 ____                 __ _
#	|  _ \  ___ _ __     / _| | __ _  __ _ ___
#	| | | |/ _ \ '_ \   | |_| |/ _` |/ _` / __|
#	| |_| |  __/ |_) |  |  _| | (_| | (_| \__ \
#	|____/ \___| .__(_) |_| |_|\__,_|\__, |___/
#	           |_|                   |___/
#

HOST_DEPFLAGS =          -MT"$(@:%.o=%.d)" -MMD -MP -MF $(OBJ_DIR)$(HOST_DIR)$*.Td

################################################################################
#	 ___            _           _         __ _
#	|_ _|_ __   ___| |_   _  __| | ___   / _| | __ _  __ _ ___
#	 | || '_ \ / __| | | | |/ _` |/ _ \ | |_| |/ _` |/ _` / __|
#	 | || | | | (__| | |_| | (_| |  __/ |  _| | (_| | (_| \__ \
#	|___|_| |_|\___|_|\__,_|\__,_|\___| |_| |_|\__,_|\__, |___/
#	                                                 |___/
#

# Include directories
INCLUDES =               -I$(SRC_DIR) -I$(HOST_DIR) -I$(INC_DIR)

#..............................................................................#
# Host include directories
HOST_INCLUDES =          $(INCLUDES)\
                         $(USER_HOST_INCLUDES)\
                         $(USER_INCLUDES)

#..............................................................................#
# Test include directories
TEST_INCLUDES =          $(INCLUDES)\
                         $(USER_TEST_INCLUDES)\
                         $(USER_INCLUDES)

################################################################################
#	 _     _       _               _____ _
#	| |   (_)_ __ | | _____ _ __  |  ___| | __ _  __ _ ___
#	| |   | | '_ \| |/ / _ \ '__| | |_  | |/ _` |/ _` / __|
#	| |___| | | | |   <  __/ |    |  _| | | (_| | (_| \__ \
#	|_____|_|_| |_|_|\_\___|_|    |_|   |_|\__,_|\__, |___/
#	                                             |___/
#

# Linker flags
LDFLAGS =                -L$(LIB_DIR)\
                         -lc\
                         -lm

LDFLAGS +=               -Wl,-u\
                         -Wl,_printf_float\
                         -Wl,--gc-sections

#..............................................................................#
# Host compiler linker flags
HOST_LDFLAGS =           $(LDFLAGS)\
                         $(USER_HOST_LDFLAGS)\
                         $(USER_LDFLAGS)

#..............................................................................#
# Test compiler linker flags
TEST_LDFLAGS =           -L"$(CPPUTEST_DIR)/cpputest_build/lib/"\
                         -lCppUTest\
                         -lCppUTestExt

TEST_LDFLAGS +=          $(LDFLAGS)\
                         $(USER_TEST_LDFLAGS)\
                         $(USER_LDFLAGS)

################################################################################
#	    _             _        __ _
#	   / \   _ __ ___| |__    / _| | __ _  __ _ ___
#	  / _ \ | '__/ __| '_ \  | |_| |/ _` |/ _` / __|
#	 / ___ \| | | (__| | | | |  _| | (_| | (_| \__ \
#	/_/   \_\_|  \___|_| |_| |_| |_|\__,_|\__, |___/
#	                                      |___/
#

FPU ?=
FLOAT_ABI ?=

ARCHFLAGS +=             -mcpu=$(CPU)\
                         -mthumb $(FPU)\
                         $(FLOAT_ABI)

################################################################################
#	 _____  _                                    _
#	|  __ \| |                                  | |
#	| |__) | |__   ___  _ __  _   _   _ __ _   _| | ___  ___
#	|  ___/| '_ \ / _ \| '_ \| | | | | '__| | | | |/ _ \/ __|
#	| |    | | | | (_) | | | | |_| | | |  | |_| | |  __/\__ \
#	|_|    |_| |_|\___/|_| |_|\__, | |_|   \__,_|_|\___||___/
#	                           __/ |
#	                          |___/
#

.PHONY: default
default: ##@build Default rule (same as build).
default: build

.PHONY: all
all: ##@build Builds project and its documentation.
all: doc build

.PHONY: rebuild
rebuild: ##@build Rebuilds project without documentation.
rebuild: clean build

.PHONY: build
build: ##@build Builds project without documentation.
build: host
	$(BUILD_SUCCESS)

.PHONY: clean
clean:
	$(CLEANING)
	$(RM_FR)              $(OBJ_DIR)
	$(RM_FR)              $(BIN_DIR)
	$(RM_FR)              $(DOC_DIR)
	$(RM_FR)              $(INC_DIR)version.h

.PHONY: help
help: ##@options Shows a list of all available make options.
ifndef PERL_EXISTS
	$(warning "Please set variable 'COLOR' to NO!")
endif
	@perl                 -e '$(HELP_FUNC)' $(MAKEFILE_LIST)

.PHONY: tools
tools: ##@options Checks if tools used in this Makefile are installed.
	@$(ECHO_N)            "\tChecking tools:\t"
ifndef GCC_EXISTS
	$(warning "Please install 'gcc' compiler!")
endif
ifndef GPP_EXISTS
	$(warning "Please install 'g++' compiler!")
endif
ifndef GDB_EXISTS
	$(warning "Please install 'gdb' debugger!")
endif
ifndef VALGRIND_EXISTS
	$(warning "Please install 'valgrind' dynamical analyser!")
endif
ifndef PERL_EXISTS
	$(warning "Please install 'perl' stream editor!")
endif
ifndef SED_EXISTS
	$(warning "Please install 'sed' scripting language!")
endif
ifndef GIT_EXISTS
	$(warning "Please install 'git' version control!")
endif
ifndef DOXYGEN_EXISTS
	$(warning "Please install 'doxygen' documentation generator!")
endif
ifndef DOT_EXISTS
	$(warning "Please install 'dot' graphing tool!")
endif
ifndef JLINK_EXISTS
	$(warning "Please install Segger J-Link drivers!")
endif
ifndef SALEAE_EXISTS
	$(warning "Please install Saleae logic analyser!")
endif
ifndef PICOCOM_EXISTS
	$(warning "Please install 'picocom' terminal emulation!")
endif
ifndef FIREFOX_EXISTS
	$(warning "Please install 'firefox'!")
endif
ifndef FLINT_EXISTS
	$(warning "Please install 'flint'!")
endif

#..............................................................................#
#	Test driven development

.PHONY: runTests
runTests: ##@tests Run all tests.
runTests: $(BIN_DIR)$(HOST_DIR)$(EXEC)_runTests
	@$(ECHO)
	@./$< -c | $(SED) 's/^/\t/'

#..............................................................................#
#	Documentation

# Get version number from git
# https://christianhujer.github.io/Git-Version-in-Doxygen/
.PHONY: doc
doc: ##@doc Generates documentation.
doc: export PROJECT_NUMBER ?= "Beta"
doc: export PROJECT_NAME ?=   "Untitled"
doc: export PROJECT_BRIEF ?=  ""
doc:
	$(DOCUMENTATION)
	$(MKDIR_P)            $(DOC_DIR)html
	@(cd conf/doxygen/ && doxygen)

.PHONY: show
show: ##@doc Shows documentation.
show: doc
ifdef FIREFOX_EXISTS
	@firefox $(DOC_DIR)html/index.html >>/dev/null
else
	$(warning "Please install 'chromium-browser'!")
endif

#..............................................................................#
#	Analysis

#TODO: Build with the same flags gcc compiler!
.PHONY: lint
lint: ##@analysis Lint static analysis (flexelint).
lint: version
ifndef FLINT_EXISTS
	$(error "Please install 'flint'!")
endif
	@$(ECHO)
	@$(MKDIR_P)           $(TMP_DIR)
	@make                 -C $(TMP_DIR) \
                              -f $(PC_LINT_DIR)/config/compiler/co-gcc.mak \
                              CC_BIN=$(CC_HOST) \
                              GXX_BIN=$(CXX_HOST) \
                              CFLAGS=$(HOST_CFLAGS) \
                              CXXFLAGS=$(HOST_CXXFLAGS) \
                              CPPFLAGS= \
                              COMMON_FLAGS= \
                              > /dev/null
	@$(FLINT)	      -w1 -t4 \
                              -i$(TMP_DIR) \
                              -i$(PC_LINT_DIR)/config/author \
                              -i$(PC_LINT_DIR)/config/compiler \
                              -i$(PC_LINT_DIR)/config/environment \
                              co-gcc.lnt \
                              env-posix.lnt \
                              $(INCLUDES) \
                              $(HOST_C_SRCs)
	@$(ECHO)

.PHONY: valgrind
valgrind: ##@analysis Valgrind dynamic analysis.
valgrind: build
ifndef VALGRIND_EXISTS
	$(error "Please install 'valgrind' dynamical analyser!")
endif
	@valgrind             $(BIN_DIR)$(HOST_DIR)$(EXEC)

.PHONY: todo
todo: ##@analysis Check for programmer notes in code.
	@egrep                -nr -Rw --color 'bug|BUG|Bug'    $(SRC_DIR) $(INC_DIR) port/ || true
	@egrep                -nr -Rw --color 'todo|TODO|Todo' $(SRC_DIR) $(INC_DIR) port/ || true
	@egrep                -nr -Rw --color 'test|TEST|Test' $(SRC_DIR) $(INC_DIR) port/ || true

#..............................................................................#
#	Run, serial, flash, erase, debug

.PHONY: run
run: ##@live Runs the host program.
run: build
	$(RUNNING)
	@$(ECHO)
	@./$(BIN_DIR)$(HOST_DIR)$(EXEC)

.PHONY: serial
serial: ##@live Connects through serial with the target.
serial: build
  ifndef PICOCOM_EXISTS
	$(error "Please install 'picocom' terminal emulation!")
  endif
	@sudo                 -v
	@sudo chmod           777 /dev/ttyACM0
	clear
	@picocom              -b 115200 --flow=none --echo --imap lfcrlf --omap crlf /dev/ttyACM0

.PHONY: flash
flash: ##@live Flashes the mcu.
flash: build
ifndef JLINK_EXISTS
	$(error "Please install Segger J-Link drivers!")
endif
	@$(ECHO)
	$(FLASH)
	@JLinkExe             -commanderscript conf/jlink/download_$(CONF).jlink | $(SED) 's/^/\t/'

.PHONY: erase
erase: ##@live Erases the mcu.
ifndef JLINK_EXISTS
	$(error "Please install Segger J-Link drivers!")
endif
	@$(ECHO)
	$(ERASE)
	@JLinkExe             -commanderscript conf/jlink/erase.jlink | $(SED) 's/^/\t/'

.PHONY: debug_host
debug_host: ##@live Debug the host program.
debug_host: build
ifndef GDB_EXISTS
	$(error "Please install 'gdb' debugger!")
endif
	@gdb                  $(BIN_DIR)$(HOST_DIR)$(EXEC)

.PHONY: debug_target
debug_target: ##@live Debug the target program.
debug_target: build
	$(error "Not implemented for target!")

.PHONY: show_flags
show_flags:
	@$(ECHO)              "Host"
	@$(ECHO)              "PP :  $(HOST_CPPFLAGS)"
	@$(ECHO)              "INC:  $(HOST_INCLUDES)"
	@$(ECHO)              "DEP:  $(HOST_DEPFLAGS)"
	@$(ECHO)              "C++:  $(HOST_CXXFLAGS)"
	@$(ECHO)              "C  :  $(HOST_CFLAGS)"
	@$(ECHO)              "ASM:  $(HOST_ASFLAGS)"
	@$(ECHO)              "OBJ:  $(HOST_OBJ_MAIN) $(HOST_OBJS)"
	@$(ECHO)              "PP :  $(TEST_CPPFLAGS)"
	@$(ECHO)              "INC:  $(TEST_INCLUDES)"
	@$(ECHO)              "DEP:  $(TEST_DEPFLAGS)"
	@$(ECHO)              "C++:  $(TEST_CXXFLAGS)"
	@$(ECHO)              "C  :  $(TEST_CFLAGS)"
	@$(ECHO)              "ASM:  $(TEST_ASFLAGS)"
	@$(ECHO)              "OBJ:  $(TEST_OBJS)"

################################################################################
#	 _   _           _
#	| | | | ___  ___| |_
#	| |_| |/ _ \/ __| __|
#	|  _  | (_) \__ \ |_
#	|_| |_|\___/|___/\__|
#

.PHONY: host
host: ##@build Builds the host.
host: $(BIN_DIR)$(HOST_DIR)$(EXEC) \
      $(BIN_DIR)$(HOST_DIR)$(EXEC).hex \
      $(BIN_DIR)$(HOST_DIR)$(EXEC).bin \
      $(BIN_DIR)$(HOST_DIR)lib$(EXEC).a \
      $(BIN_DIR)$(HOST_DIR)$(EXEC).size

# Create host elf executable
$(BIN_DIR)$(HOST_DIR)$(EXEC): $(HOST_OBJ_MAIN) $(HOST_OBJS)
	$(BUILDING)
	$(MKDIR_P)            $(dir $@)
	@$(CC_HOST)           $^ $(HOST_LDFLAGS) -Wl,-Map=$@.map,--cref -o $@

# Create host hex program
$(BIN_DIR)$(HOST_DIR)%.hex: $(BIN_DIR)$(HOST_DIR)$(EXEC)
	$(BUILDING)
	$(MKDIR_P)            $(dir $@)
	@$(HEX_HOST)          $< $@

# Create host bin program
$(BIN_DIR)$(HOST_DIR)%.bin: $(BIN_DIR)$(HOST_DIR)$(EXEC)
	$(BUILDING)
	$(MKDIR_P)            $(dir $@)
	@$(BIN_HOST)          $< $@

# Create host lib
$(BIN_DIR)$(HOST_DIR)lib$(EXEC).a: $(HOST_OBJS)
	$(BUILDING)
	$(MKDIR_P)            $(dir $@)
	@$(AR_HOST)           rcs $@ $<

# Size the generated program
$(BIN_DIR)$(HOST_DIR)$(EXEC).size: $(BIN_DIR)$(HOST_DIR)$(EXEC).hex
	@$(ECHO)
	@$(SZ_HOST)           $^ | sed 's/^/\t/'
	$(MKDIR_P)            $(dir $@)
	@$(SZ_HOST)           $^ --format=sysv 1>$@
	@$(ECHO)

# Create host object from C++ source code
$(OBJ_DIR)$(HOST_DIR)%.o: %.cpp $(OBJ_DIR)$(HOST_DIR)%.d $(AUX)
	$(COMPILING)
	$(MKDIR_P)            $(dir $@)
	@$(CXX_HOST)          $< -c $(HOST_CXXFLAGS) $(HOST_CPPFLAGS) $(HOST_INCLUDES) $(HOST_DEPFLAGS) -Wa,-a,-ad,-alms=$(dir $(OBJ_DIR)$(HOST_DIR)$<)$(notdir $(<:.cpp=.lst)) -o $@
	$(MV_F)               $(OBJ_DIR)$(HOST_DIR)$*.Td $(OBJ_DIR)$(HOST_DIR)$*.d && $(TOUCH) $@

# Create object from C source code
$(OBJ_DIR)$(HOST_DIR)%.o: %.c $(OBJ_DIR)$(HOST_DIR)%.d $(AUX)
	$(COMPILING)
	$(MKDIR_P)            $(dir $@)
	@$(CC_HOST)           $< -c $(HOST_CFLAGS) $(HOST_CPPFLAGS) $(HOST_INCLUDES) $(HOST_DEPFLAGS) -Wa,-a,-ad,-alms=$(dir $(OBJ_DIR)$(HOST_DIR)$<)$(notdir $(<:.c=.lst)) -o $@
	$(MV_F)               $(OBJ_DIR)$(HOST_DIR)$*.Td $(OBJ_DIR)$(HOST_DIR)$*.d && $(TOUCH) $@

# Create object from Assembly source code
$(OBJ_DIR)$(HOST_DIR)%.o: %.s $(OBJ_DIR)$(HOST_DIR)%.d $(AUX)
	$(COMPILING)
	$(MKDIR_P)            $(dir $@)
	@$(AS_HOST)           $< -c $(HOST_ASFLAGS) $(HOST_CPPFLAGS) $(HOST_INCLUDES) $(HOST_DEPFLAGS) -o $@
	$(MV_F)               $(OBJ_DIR)$(HOST_DIR)$*.Td $(OBJ_DIR)$(HOST_DIR)$*.d && $(TOUCH) $@

# Manage auto-depedencies
.PRECIOUS: $(OBJ_DIR)$(HOST_DIR)%.d
$(OBJ_DIR)$(HOST_DIR)%.d: ;

#..............................................................................#
#	WARNING!!! This must be at the end for auto-dependency to work

#..............................................................................#
# For host
-include $(wildcard $(patsubst %,$(OBJ_DIR)$(HOST_DIR)%.d,$(basename $(HOST_CΧΧ_SRCs))))
-include $(wildcard $(patsubst %,$(OBJ_DIR)$(HOST_DIR)%.d,$(basename $(HOST_C_SRCs))))
-include $(wildcard $(patsubst %,$(OBJ_DIR)$(HOST_DIR)%.d,$(basename $(HOST_AS_SRCs))))
# For host main
-include $(wildcard $(patsubst %,$(OBJ_DIR)$(HOST_DIR)%.d,$(basename $(HOST_CXX_MAIN))))
-include $(wildcard $(patsubst %,$(OBJ_DIR)$(HOST_DIR)%.d,$(basename $(HOST_C_MAIN))))
-include $(wildcard $(patsubst %,$(OBJ_DIR)$(HOST_DIR)%.d,$(basename $(HOST_AS_MAIN))))
