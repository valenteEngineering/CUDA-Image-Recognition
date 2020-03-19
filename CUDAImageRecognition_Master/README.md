# EE451_Final_Project

1. ssh into USC HPC (make sure X11 forwarding is enabled)
2. setup CUDA toolchain "source /usr/usc/cuda/default/setup.sh"
3. setup OpenCV toolchain "source /usr/usc/opencv/default/setup.sh"
4. compilation "nvcc -O3 [sourceFile] -I/usr/usc/opencv/default/include -lopencv_core -lopencv_highgui -lopencv_imgcodecs -lopencv_imgproc -L/usr/usc/opencv/default/lib -o [outputFileName]"
4. run "srun -n[number of nodes] --x11 --gres=gpu:1 ./[outputFileName] [imageFile]"
