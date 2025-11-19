# Makefile for Objective-C Learning Examples
# 使用 make 命令编译所有示例

CC = clang
FRAMEWORK = -framework Foundation
CFLAGS = -Wall -g -fobjc-arc

# 核心差异示例
DIFFERENCES = differences/01_message_passing differences/02_at_syntax differences/03_memory_management

# OC 特有特性示例
ESSENTIALS = essentials/01_property essentials/02_category essentials/03_block

# Foundation 框架示例
FOUNDATION = foundation/01_common_classes

# 设计模式示例
PATTERNS = patterns/01_delegate_pattern patterns/02_kvc_kvo

# 所有目标
ALL_TARGETS = $(DIFFERENCES) $(ESSENTIALS) $(FOUNDATION) $(PATTERNS)

.PHONY: all clean differences essentials foundation patterns examples

all: differences essentials foundation patterns examples

differences: $(DIFFERENCES)

essentials: $(ESSENTIALS)

foundation: $(FOUNDATION)

patterns: $(PATTERNS)

examples:
	$(CC) $(CFLAGS) $(FRAMEWORK) examples/calculator/Calculator.m examples/calculator/main.m -o examples/calculator/calculator

# 通用编译规则
%: %.m
	$(CC) $(CFLAGS) $(FRAMEWORK) $< -o $@
	@echo "已编译: $@"

clean:
	rm -f $(ALL_TARGETS)
	rm -f examples/calculator/calculator
	@echo "已清理所有编译文件"
