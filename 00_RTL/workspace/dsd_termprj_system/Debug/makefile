#
# This file was created by Xilinx Vitis tool.
#


#
# tools
#

RM = rm -f
RMDIR = rm -rf



#
# variables
#

SDCARD_GEN = sdcard_gen
GENERATE_BIF = ::scw::generate_bif

XPFM_PATH = D:/DSD25_Termproject_Materials_Updated250519/00_RTL_Skeleton/workspace/design_1_wrapper/export/design_1_wrapper/design_1_wrapper.xpfm
SYS_CONFIG = design_1_wrapper
DOMAINS = standalone_ps7_cortexa9_0
BIF_PATH = D:/DSD25_Termproject_Materials_Updated250519/00_RTL_Skeleton/workspace/dsd_termprj_system/Debug/system.bif

BITSTREAM_PATH = D:/DSD25_Termproject_Materials_Updated250519/00_RTL_Skeleton/workspace/dsd_termprj/_ide/bitstream/final_demo_mak.bit
SD_FILES = --elf D:/DSD25_Termproject_Materials_Updated250519/00_RTL_Skeleton/workspace/dsd_termprj/Debug/dsd_termprj.elf,ps7_cortexa9_0

#
# primary build targets
#

package:
	-@echo Generating bif file for the system project
	generate_system_bif.bat 55624 ${XPFM_PATH} ${DOMAINS} ${BIF_PATH}
	${SDCARD_GEN} --xpfm ${XPFM_PATH} --sys_config ${SYS_CONFIG} --bif ${BIF_PATH} --bitstream ${BITSTREAM_PATH} ${SD_FILES}

clean:
	$(RMDIR) ./_sds
	${RMDIR} package
	${RM} system.bif

.PHONY: all package clean

all: package


