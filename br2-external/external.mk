# Optional hooks for the Antminer S9 external tree.

define ANTMINER_S9_UBOOT_PS7_INIT
	mkdir -p $(UBOOT_DIR)/board/xilinx/zynq/antminer_s9
	$(INSTALL) -D -m 0644 $(BR2_EXTERNAL_ANTMINER_S9_PATH)/board/antminer-s9/ps7_init_gpl.c \
		$(UBOOT_DIR)/board/xilinx/zynq/antminer_s9/ps7_init_gpl.c
	$(INSTALL) -D -m 0644 $(BR2_EXTERNAL_ANTMINER_S9_PATH)/board/antminer-s9/ps7_init_gpl.h \
		$(UBOOT_DIR)/board/xilinx/zynq/antminer_s9/ps7_init_gpl.h
endef
UBOOT_POST_PATCH_HOOKS += ANTMINER_S9_UBOOT_PS7_INIT
