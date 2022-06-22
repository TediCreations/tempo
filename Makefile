#..............................................................................#

EXEC =                  TDD_Project

#..............................................................................#
# Documentation

PROJECT_NAME =          First embedded TDD project

PROJECT_BRIEF =         This is a clean 'hello world' and 'blink' C project for\
                        Test driven development in embedded systems

#..............................................................................#
# TTD

CPPUTEST_DIR =          ${HOME}/opt/cpputest/

#..............................................................................#
# STM32 CMSIS drivers

USER_TARGET_CPPFLAGS =\
                        -DSTM32F072xB

USER_LDFLAGS = -pthread

USER_TARGET_INCLUDES =\
                        -Ithirdparty/CMSIS/Device/ST/STM32F0xx/Include/\
                        -Ithirdparty/CMSIS/Include/

#..............................................................................#
# Actual Makefile
include common.mk
