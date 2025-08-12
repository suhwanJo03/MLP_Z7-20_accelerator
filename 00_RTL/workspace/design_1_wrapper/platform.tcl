# 
# Usage: To re-create this platform project launch xsct with below options.
# xsct C:\Users\junoh\vivado23\DSD25_Termprj\00_RTL_Skeleton\workspace\design_1_wrapper\platform.tcl
# 
# OR launch xsct and run below command.
# source C:\Users\junoh\vivado23\DSD25_Termprj\00_RTL_Skeleton\workspace\design_1_wrapper\platform.tcl
# 
# To create the platform in a different location, modify the -out option of "platform create" command.
# -out option specifies the output directory of the platform project.

platform create -name {design_1_wrapper}\
-hw {C:\Users\junoh\vivado23\DSD25_Termprj\00_RTL_Skeleton\design_1_wrapper.xsa}\
-out {C:/Users/junoh/vivado23/DSD25_Termprj/00_RTL_Skeleton/workspace}

platform write
domain create -name {standalone_ps7_cortexa9_0} -display-name {standalone_ps7_cortexa9_0} -os {standalone} -proc {ps7_cortexa9_0} -runtime {cpp} -arch {32-bit} -support-app {hello_world}
platform generate -domains 
platform active {design_1_wrapper}
domain active {zynq_fsbl}
domain active {standalone_ps7_cortexa9_0}
platform generate -quick
platform generate
platform clean
platform generate
platform clean
platform generate
platform clean
platform generate
platform clean
platform generate
platform generate -domains standalone_ps7_cortexa9_0,zynq_fsbl 
platform clean
platform generate
platform generate
platform active {design_1_wrapper}
platform config -updatehw {D:/DSD25_Termproject_Materials_Updated250519/00_RTL_Skeleton/final_demo_mak.xsa}
platform clean
platform generate
platform clean
platform generate
platform clean
platform generate
platform clean
platform generate
platform clean
platform generate
